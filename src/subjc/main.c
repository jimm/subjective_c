/*
** subjc translates already-preprocessed .m files into .c files by changing
** Subjective-C declarations, definitions, and statements into C statements.
** It also strips out '//' style comments.
**
** Version 1.0 by Jim Menard, December 1993.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "subjc.h"
#include "bracket.h"
#include "classinf.h"
#include "error.h"
#include "xlate.h"
#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */
#include "FullPathName.h"
#endif /* macintosh */

#define NO_OTHER_LINE_NUM (-1)

static char *usage = "usage: %s [-c c_output] [-t table_output] [infile]\n";
static int forceLineNum = FALSE;

CodeState gCodeState = codeState_C;
int gLineNum = 0;
static char gFileName[MY_BUFSIZ];
static int gOtherLineNum = NO_OTHER_LINE_NUM;

static int DoKeyword();
static void ReallyPrintLineNumber(void);
static int is_reserved(char *word);
static void CloseFiles();

#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */
static OSErr OpenFiles(FSSpec *inMacFSSpec);
#else /* not macintosh */
static int OpenFiles(char *fileName);
#endif /* not macintosh */

#if !defined(__THINK__) && !defined(__MWERKS__)	/* not macintosh */

extern int getopt();
extern int optind;
extern char *optarg;

/*
** Handle option switches and pass responsibility on to MungeFile().
*/
int
main(int argc, char *argv[])
{
    if (argc == 1)
		MungeFile(NULL);
    else {
		int i;
		for (i = 1; i < argc; ++i)
			MungeFile(argv[i]);
    }

    exit(0);
    return 0;
}

#endif /* not macintosh */

/*
** The workhorse: looks over the input file for possible statements to munge.
** It traverses the file character by character, looking for interesting
** characters. For example, when it sees a single or double quote, it passes
** the character or string constant right through.
**
** The interesting things happen when we see one of '@', '+', '-', or '['.
*/
#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */
OSErr
MungeFile(FSSpec *inMacFSSpec)
#else /* not macintosh */
int
MungeFile(char *fileName)
#endif /* macintosh */
{
	int c, prev_char = '\n', prev_nonspace = '\n', bracketCount = 0;
	char buf[MY_BUFSIZ], prev_word[MY_BUFSIZ];

#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */

	OSErr err;

	if ((err = OpenFiles(inMacFSSpec)) != noErr)
			return err;

#else /* not macintosh */

	if (OpenFiles(fileName) != 0)
		return -1;

#endif /* not macintosh */

	prev_word[0] = '\0';
	while ((c = getchar()) != EOF) {
		switch (c) {
		case '@':				/*  @keyword */
			c = DoKeyword();		/* Force a new prev_char value */
			break;
		case '[':				/* Possibly a bracket statement */
			/*
			** If the previous character is alphanumeric or one of a few
			** others, than this *can't* be a Subjective-C bracket statement.
			*/
			if ((is_id_char(prev_nonspace) || prev_nonspace == ']') &&
				!is_reserved(prev_word))
				/* PassDelims('[', ']', "bracket"); */
				goto DEFAULT;
			else
				DoBracket();		/* It is! */
			c = ']';
			break;
		case '+':				/* Possible method declaration/definition */
		case '-':
			if (prev_char == '\n' && bracketCount == 0) {
				DoFuncHeader(c);
				c = '\n';
			}
			else
				putchar(c);
			break;
		case '{':
			if (gCodeState != codeState_C)
				++bracketCount;
			putchar('{');
			break;
		case '}':
			if (gCodeState != codeState_C)
				--bracketCount;
			putchar('}');
			break;
		case S_QUOTE:				/* Pass character constants */
			PassDelims(S_QUOTE, S_QUOTE, "char constant");
			break;
		case D_QUOTE:				/* Pass strings */
			PassDelims(D_QUOTE, D_QUOTE, "string constant");
			break;
		case '#':				/* Possible preprocessor directives */
			putchar('#');
			if (prev_char == '\n') {
				PassPreprocLine();
				c = '\n';		/* Force prev_char to be newline */
			}
			break;
		case '\n':				/* Keep input file line number up to date */
			IncrLineNumber();
			putchar('\n');
			if (forceLineNum)
				ReallyPrintLineNumber();
			break;
		case '/':				/* Possibly a '//' style comment */
			switch (c = getchar()) {
			case '/':						/* A C++-style comment */
				fgets(buf, MY_BUFSIZ, stdin);
				putchar('\n');
				IncrLineNumber();
				c = '\n';				/* So prev_char is set */
				break;
			case '*':						/* A C-style comment */
				printf("/*");
				for (;;) {
					if ((c = getchar()) == EOF)
						break;
					if (c == '*') {
						c = getchar();
						if (c == '/') {
							printf("*/");
							break;
						}
						else {
							putchar('*');
							ungetc(c, stdin);
						}
					}
					else {
						if (c == '\n')
							IncrLineNumber();
						putchar(c);
					}
				}
				break;
			default:
				putchar('/');
				ungetc(c, stdin);
				break;
			}
			break;
		default:				/* Default: pass char through unchanged */
DEFAULT:
			if (is_starting_id_char(c) && !isdigit(prev_char)) {
				int i;

				for (i = 0; is_id_char(c); ++i, c = getchar())
					prev_word[i] = c;
				prev_word[i] = '\0';
#if EXTRANEOUS_SPACES
				if (gCodeState == codeState_Implementation &&
					prev_nonspace != '>' &&
#else /* !EXTRANEOUS_SPACES */
				if (gCodeState == codeState_Implementation &&
					prev_char != '>' &&
#endif
					is_ivar(CurrClassName(), prev_word)) {
						printf("self->%s", prev_word);
				}
				else
                  printf("%s", prev_word);
				ungetc(c, stdin);
				c = prev_word[i - 1];
			}
			else {
				if (!isspace(c))
					prev_word[0] = '\0';
				putchar(c);
			}
			break;
		}
		prev_char = c;
		if (!isspace(c))
			prev_nonspace = c;
	}
	CloseFiles();
	FreeClassInfo();
	if (gCodeState != codeState_C)
		Error("missing @end\n");

	return 0;
}

/*
** Reads a word (alphanumeric chars, possibly ending with ':') from stdin
** into a buffer. The buffer is assumed to be big enough.
*/
void
GetWord(char *buf)
{
	int c;

	c = NextNonWhitespace();
	while (is_id_char(c)) {
		*buf++ = c;
		if ((c = getchar()) == '\n')
			IncrLineNumber();
	}
	if (c == ':')
		*buf++ = ':';
	else
		ungetc(c, stdin);
	*buf = '\0';
}

/*
** Return the next non-whitespace character from stdin.
*/
int
NextNonWhitespace()
{
	int c, prev_char = '\0';

	do {
		c = getchar();
		if (c == '\n')
			IncrLineNumber();
		else if (c == '#' && prev_char == '\n') {
			printf("\n#");
			PassPreprocLine();
			c = '\n';
		}
		prev_char = c;
	} while (isspace(c));

	if (c == EOF)
		FatalError("unexpected EOF while skipping spaces\n");

	return c;
}

/*
** We've got a preprocessor line (starting *after* the '#'). If it's a
** "#line" or "#" directive, parse it and save the line number and file name.
*/
void
PassPreprocLine()
{
	int nScanned;
	char buf[MY_BUFSIZ], preprocFileName[MY_BUFSIZ], *p;

	fgets(buf, MY_BUFSIZ, stdin);
	nScanned = sscanf(buf+1, "%d %s %d", &gLineNum, gFileName, &gOtherLineNum);
	SetPreprocFileName(preprocFileName);
	if (nScanned < 3)
		gOtherLineNum = NO_OTHER_LINE_NUM;
	if ((p = strstr(buf, "//")) != NULL) { /* C++ comment */
		*p++ = '\n';
		*p = '\0';
	}
	printf("%s", buf);
}

/*
** Doesn't really print the input file line number, just gets ready to.
*/
void
PrintLineNumber()
{
	forceLineNum = TRUE;
}

/*
** Prints the input file line number. Called by MungeFile() when a newline
** is seen in the input file.
*/
static
void
ReallyPrintLineNumber()
{
#if 0								/* NOT WORKING YET */
	printf("# %d %s", gLineNum, gFileName);
	if (gOtherLineNum == NO_OTHER_LINE_NUM)
		putchar('\n');
	else
		printf(" %d\n", gOtherLineNum);
#endif
	forceLineNum = FALSE;
}

/*
** Read in a '@' Subjective-C keyword and handle it. We've already seen
** the '@' and have to collect the keyword first. Return a new value
** for prev_char.
**
** @interface, @implementation, @end, and @class must appear at the
** beginning of a line, but @selector can appear anywhere.
*/
static
int
DoKeyword()
{
	int c;
	char buf[MY_BUFSIZ];

	if ((c = getchar()) == 's') {
		/*
		** Check for "selector," which can be anywhere (not just at the
		** beginning of a line).
		*/
		buf[0] = 's';
		GetWord(buf+1);
		if (strcmp(buf, "selector") == 0) {
			DoSelector();
			return ')';
		}
		else {						/* Not @selector: just pass '@' through */
			printf("@%s", buf);
			return *(buf + strlen(buf) - 1);
		}
	}

	buf[0] = c;
	GetWord(buf + 1);
	c = '\n';
	if (strcmp(buf, "interface") == 0)
		DoInterface();
	else if (strcmp(buf, "implementation") == 0)
		DoImplementation();
	else if (strcmp(buf, "end") == 0)
		DoEnd();
	else if (strcmp(buf, "class") == 0)
		DoClass();
	else {						/* None of the above: just pass '@' through */
		printf("@%s", buf);
		c = *(buf + strlen(buf) - 1);
	}

	return c;
}

static
int
is_reserved(char *word)
{
	char **p;
	static char *list[] = {
		"return", "else", "if", "for", "do", "while", "switch", "default",
		"case", "int", "char", "float", "double", "long", "short", "sizeof",
		"continue", "break", "struct", "enum", "union", "typedef",
		"volatile", "auto", "static", "extern", "register",
		NULL
	};

	if (*word == '\0')
		return FALSE;

	for (p = list; *p != NULL; ++p)
		if (strcmp(*p, word) == 0)
			return TRUE;

	return FALSE;
}

#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */

static OSErr
OpenFiles(FSSpec *inMacFSSpec)
{
	Str255 dirName;
	char fileName[256], *p;

	PathNameFromDirID(inMacFSSpec->parID, inMacFSSpec->vRefNum, dirName);
	memcpy((void *)fileName, (void *)&dirName[1], (size_t)dirName[0]);
	memcpy((void *)(fileName + dirName[0]), (void *)&inMacFSSpec->name[1],
			   (size_t)inMacFSSpec->name[0]);
	fileName[(int)dirName[0] + (int)inMacFSSpec->name[0]] = '\0';
	if (freopen(fileName, "r", stdin) == NULL)
		return fnfErr;
	SetIncludeFileName(fileName);

	if ((p = strrchr(fileName, '.')) == 0)
		strcat(fileName, ".c");
	else
		strcpy(p, ".c");
	if (freopen(fileName, "w", stdout) == NULL) {
		fclose(stdin);
		return wrPermErr;		/* HACK: what should this be? */
	}

	return noErr;
}

#else /* not macintosh */

static int
OpenFiles(char *fileName)
{
	char *outputFileName, *p;

	if (freopen(fileName, "r", stdin) == NULL)
		return -1;
	SetIncludeFileName(fileName);

	outputFileName = malloc(strlen(fileName) + 1);
	strcpy(outputFileName, fileName);
	if ((p = strrchr(outputFileName, '.')) == 0)
		strcat(outputFileName, ".c");
	else
		strcpy(p, ".c");
	if (freopen(outputFileName, "w", stdout) == NULL) {
		fclose(stdin);
		free(outputFileName);
		return -1;
	}

	free(outputFileName);
	return 0;
}

#endif /* not macintosh */

static void
CloseFiles()
{
	fclose(stdin);
	fclose(stdout);
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
