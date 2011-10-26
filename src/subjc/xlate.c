#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "subjc.h"
#include "classinf.h"
#include "error.h"
#include "xlate.h"

MethodType gMethodType = methodType_instance; /* Global */

static char class_name[MY_BUFSIZ];
static char superclass_name[MY_BUFSIZ];
static ClassInfo *class_info;

static void PrintArgList(LIST *l1, LIST *l2);
static void PrintXlatedFuncName(char *func_name);
static int GetNextIvarCommentChar(char **origLinePtr);
static void UngetNextIvarCommentChar(char c, char **origLinePtr);

/*
** Translate an "@interface Foo : SuperFoo {instance vars}" into a C structure.
*/
void
DoInterface()
{
	int c;
	char buf[MY_BUFSIZ];

	/* Get class and superclass names */
	GetWord(class_name);				/* Class name */
	if (class_name[0] == '\0') {
		Error("no class specified in @interface statement");
		return;
	}

	c = NextNonWhitespace();
	if (c == ':') {				/* Must be superclass name next */
		GetWord(superclass_name);
		if (superclass_name[0] == '\0') {
			Error("no class specified in @interface statement after ':'");
			strcpy(superclass_name, "NULL");
		}
	}
	else {						/* No superclass: set to NULL */
		ungetc(c, stdin);
		strcpy(superclass_name, "NULL");
	}

	if ((class_info = LookupClassInfo(class_name)) != NULL) {
		/* Not much to do; already defined */
		gCodeState = codeState_Interface;
		return;
	}

	/* Register the class (and the metaclass) */
	class_info = NewClassInfo(class_name, superclass_name);

	/* Print typedef header and all superclass variables */
	printf("typedef struct _%s {\n", class_name);
	PrintSuperclassVars(class_info);
	PrintLineNumber();

	/* Print the ivars of this class, collecting them in class_info */
	c = NextNonWhitespace();
	if (c == '{') {
		while (fgets(buf, MY_BUFSIZ, stdin) != NULL) {
			char *p, *startOfComment = NULL;

			IncrLineNumber();

			/* Attempt to strip comments from line. NOTE: big hack here. */
			/* Don't print comment, 'cause it'll come out in wrong place */
			if ((p = strstr(buf, "//")) != 0) {
				--p;
				while (p >= buf && isspace(*p)) --p;
				*++p = '\n';
				*++p = '\0';
			}
			else if ((p = strstr(buf, "/*")) != 0) {
				startOfComment = p + 2;
				--p;
				while (p >= buf && isspace(*p)) --p;
				*++p = '\n';
				*++p = '\0';
			}
			
			p = buf;
			BufSkipWhitespace(p);
			if (*p == '}')
				break;
			if (*p && *p != '\n') {
				/*
				 * Note: printf must be before AddClassVarText(), which
				 * munges buf 'cause it uses strtok().
				 */
				printf(buf);
				AddClassVarText(class_info, p);
			}

			if (startOfComment) {
				for (;;) {
					c = GetNextIvarCommentChar(&startOfComment);
					if (c == EOF)
						FatalError("runaway comment");
					if (c == '*') {
						c = GetNextIvarCommentChar(&startOfComment);
						if (c == '/')
							break;
						else
							UngetNextIvarCommentChar(c, &startOfComment);
					}
					else if (c == '\n' && startOfComment != NULL)
						IncrLineNumber();
				}
				c = GetNextIvarCommentChar(&startOfComment);
				while (isspace(c)) {
					if (c == '\n') {
						if (startOfComment != NULL) IncrLineNumber();
						break;
					}
					UngetNextIvarCommentChar(c, &startOfComment);
				}
				UngetNextIvarCommentChar(c, &startOfComment);
				startOfComment = NULL;
			}
		}
	}
	else
		ungetc(c, stdin);
	printf("} %s;\n", class_name);

	/* Declare the class object and metaclass object */
	printf("extern struct _Class *%sClass, *_%s;\n", class_name, class_name);
	printf("extern struct _Class Rep%s, Rep_%s;\n", class_name, class_name);

	PrintLineNumber();

	gCodeState = codeState_Interface;
}

static int
GetNextIvarCommentChar(char **origLinePtr)
{
	int c;

	if (*origLinePtr) {
		c = **origLinePtr;
		++*origLinePtr;
		if (c == '\0') {
			*origLinePtr = NULL;
			c = getchar();
		}
	}
	else
		c = getchar();

	return c;
}

static void
UngetNextIvarCommentChar(char c, char **origLinePtr)
{
	if (*origLinePtr != NULL)
		--*origLinePtr;
	else
		ungetc(c, stdin);
}

/*
** Translate an "@interface Foo : SuperFoo {instance vars}" into some C code
** This creates an instance of the Foo class, called RepFooClass, and a
** pointer to it called FooClass.
*/
void
DoImplementation()
{
	int err = 0;

	/* Read class name */
	GetWord(class_name);

	/* Find class. Fatal error if not found */
	class_info = LookupClassInfo(class_name);
	if (class_info == NULL) {
		char errmsg[MY_BUFSIZ];
		sprintf(errmsg, "@implementation -- class '%s' not found", class_name);
		Error(errmsg);
		err = -1;
	}
	if (class_info->superclass_info == NULL)
		strcpy(superclass_name, "NULL");
	else
		strcpy(superclass_name, class_info->superclass_info->name);

	PrintLineNumber();

	gCodeState = codeState_Implementation;
}

/*
** Munge a line in an @interface or @implementation section
** that starts with a '+' or '-'.
*/
void
DoFuncHeader(int type)
{
	int c;
	char buf[MY_BUFSIZ], funcName[MY_BUFSIZ], returnType[MY_BUFSIZ],
		argTypeBuf[MY_BUFSIZ], argNameBuf[MY_BUFSIZ], *p;
	LIST *argTypes, *argNames;

	argTypes = argNames = NULL; /* Lazily instantiate later, if needed */

	/* Collect function return type */
	c = NextNonWhitespace();
	if (c == '(') {
		CollectDelims('(', ')',  returnType, "function return type");
		c = NextNonWhitespace();
	}
	else
		strcpy(returnType, "id");

	/* Collect method name and args */
	funcName[0] = c;				/* First letter of method name */
	funcName[1] = '\0';
	if (c == ':')
		goto GOT_METHOD_NAME_PART;

	while (GetWord(buf), *buf) {
		strcat(funcName, buf);

GOT_METHOD_NAME_PART:

		if (funcName[strlen(funcName) - 1] == ':') {
			c = NextNonWhitespace();

			/* Read arg type */
			if (c == '(')
				CollectDelims('(', ')', argTypeBuf, "arg type");
			else {
				ungetc(c, stdin);
				strcpy(argTypeBuf, "id");
			}

			/* Read arg name */
			GetWord(argNameBuf);

			if (argTypes == NULL) /* Lazy instantiation */
				argTypes = ListNew();
			if (argNames == NULL)
				argNames = ListNew();
			p = malloc(strlen(argTypeBuf) + 1);
			strcpy(p, argTypeBuf);
			ListAddObject(argTypes, p);
			p = malloc(strlen(argNameBuf) + 1);
			strcpy(p, argNameBuf);
			ListAddObject(argNames, p);
		}
	}

	gMethodType = (type == '+') ? methodType_class : methodType_instance;

	if (gCodeState == codeState_Interface) {
		if (gMethodType == methodType_class) {
			sprintf(buf, "_%s", class_name);
			AddMethod(buf, funcName, returnType);
		}
		else
			AddMethod(class_name, funcName, returnType);

		/* Eat following ';' */
		c = NextNonWhitespace();
		if (c != ';') {
			sprintf(buf, "';' missing after method '%s' declaration\n",
					funcName);
			Error(buf);
		}
	}

	/* Print method prototype (interface) or definition (implementation) */
	if (gCodeState == codeState_Interface) /* "extern", if needed */
		printf("extern ");
	printf("%s ", returnType);		/* Function return type */
	if (gMethodType == methodType_class)
		putchar('_');				/* Class methods start with '_' */
	printf("%s_", class_name);
	PrintXlatedFuncName(funcName); /* Munged method name */
	if (gMethodType == methodType_class) /* Class method receiver */
		printf("(Class self");
	else						/* Instance method receiver */
		printf("(%s *self", class_name);
	printf(", SEL _cmd");
	PrintArgList(argTypes, argNames); /* Arguments */
	if (gCodeState == codeState_Interface)		/* Close parens */
		printf(");\n");
	else /* codeState_Implementation */
		printf(")\n");

	PrintLineNumber();

	if (argTypes) {
		ListFreeArrayObjects(argTypes);
		ListFree(argTypes);
	}
	if (argNames) {
		ListFreeArrayObjects(argNames);
		ListFree(argNames);
	}
}

/*
** Handle "@end"
*/
void
DoEnd()
{
	char *metaclass_name;

	if (gCodeState == codeState_Implementation) {
		metaclass_name = malloc(strlen(class_name) + 2);
		sprintf(metaclass_name, "_%s", class_name);

		/* Create the list of metaclass methods */
		printf("\nstatic struct _Method %s_meta_methods[] = {\n", class_name);
		PrintMethodList(metaclass_name);
		puts("};");

		/* Create the metaclass */
		printf("\nstruct _Class Rep%s = {\n", metaclass_name);
		puts("	(Class)0,");
		if (strcmp(superclass_name, "NULL") == 0)
			puts("	(Class)0,");
		else
			printf("	&Rep_%s,\n", superclass_name);
		puts("	sizeof(struct _Class),");
		printf("	\"%s\",\n", metaclass_name);
		printf("	{%d, %s_meta_methods}\n", ClassNMethods(metaclass_name),
			   class_name);
		puts("};");
		printf("struct _Class *%s = &Rep%s;\n", metaclass_name,
			   metaclass_name);

		/* Create the list of class methods */
		printf("\nstatic struct _Method %s_class_methods[] = {\n", class_name);
		PrintMethodList(class_name);
		puts("};");

		/* Create the class */
		printf("\nstruct _Class Rep%s = {\n", class_name);
		printf("	&Rep_%s,\n", class_name);
		if (strcmp(superclass_name, "NULL") == 0)
			puts("	(Class)0,");
		else
			printf("	&Rep%s,\n", superclass_name);
		printf("	sizeof(struct _%s),\n", class_name);
		printf("	\"%s\",\n", class_name);
		printf("	{%d, %s_class_methods}\n", ClassNMethods(class_name),
			   class_name);
			   
		puts("};");
		printf("struct _Class *%sClass = &Rep%s;\n", class_name, class_name);

		free(metaclass_name);
	}

	gCodeState = codeState_C;
}

/*
** Handle "@class"
*/
void
DoClass()
{
	int c;
	char buf[MY_BUFSIZ];

	do {
		GetWord(buf);
		printf("extern struct _%s *%s;\n", buf, buf);
		c = NextNonWhitespace();
		if (c != ',' && c != ';') {
			ungetc(c, stdin);
			sprintf(buf, "unknown char '%c' in @class statement", c);
			Error(buf);
			break;
		}
	} while (c == ',');
}

/*
** Translate @selector(message_name) into a SEL.
*/
void
DoSelector()
{
	int c;
	char buf[MY_BUFSIZ];

	c = NextNonWhitespace();
	if (c != '(') {
		if (c == '\n')
			IncrLineNumber();
		Error("left parenthesis missing after @selector\n");
		exit(1);
	}
	CollectDelims('(', ')', buf, "@selector args");

	printf("((SEL)\"%s\")", buf);
}

/*
** Collect text between delimeters (like open/close parens, open/close
** curlies, etc.) into a string.
*/
void
CollectDelims(int open, int close, char *buf, char *errType)
{
	int c, nOpenDelims;
	int inString = FALSE, inCharConst = FALSE;

	if (buf == NULL)
		return;

	nOpenDelims = 1;
	if (open == D_QUOTE)
		inString = TRUE;
	else if (open == S_QUOTE)
		inCharConst = TRUE;
	for (;;) {
		switch (c = getchar()) {
		case S_QUOTE:
			if (close == S_QUOTE)
				goto CLOSE;
			if (!inString)
				inCharConst = !inCharConst;
			goto PASSTHRU;
		case D_QUOTE:
			if (close == D_QUOTE)
				goto CLOSE;
			if (!inCharConst)
				inString = !inString;
			goto PASSTHRU;
		case BACKSLASH:
			*buf++ = BACKSLASH;
			c = getchar();
			goto PASSTHRU;
		case EOF:
			sprintf(buf, "unexpected EOF in %s", errType);
			FatalError(buf);
			break;
		case '\n':
			IncrLineNumber();
			PrintLineNumber();
			/* fall through... */
		default:
			if (c == close) {
				if (inString || inCharConst)
					goto PASSTHRU;
CLOSE:
				if (--nOpenDelims == 0) {
					*buf = '\0';
					return;
				}
			}
			else if (c == open && !inCharConst && !inString)
				++nOpenDelims;
PASSTHRU:
			*buf++ = c;
			break;
		}
	}
}

/*
** Print text between delimeters (like open/close parens, open/close
** curlies, etc.), and the delimeters themselves.
*/
void
PassDelims(int open, int close, char *errType)
{
	int c, nOpenDelims;
	int inString = FALSE, inCharConst = FALSE;
	char *errmsg;

	putchar(open);
	nOpenDelims = 1;
	if (open == D_QUOTE)
		inString = TRUE;
	else if (open == S_QUOTE)
		inCharConst = TRUE;
	for (;;) {
		switch (c = getchar()) {
		case S_QUOTE:
			if (close == S_QUOTE)
				goto CLOSE;
			if (!inString)
				inCharConst = !inCharConst;
			goto PASSTHRU;
		case D_QUOTE:
			if (close == D_QUOTE)
				goto CLOSE;
			if (!inCharConst)
				inString = !inString;
			goto PASSTHRU;
		case BACKSLASH:
			putchar(BACKSLASH);
			c = getchar();
			goto PASSTHRU;
		case EOF:
			errmsg = malloc(MY_BUFSIZ);
			sprintf(errmsg, "unexpected EOF in %s", errType);
			FatalError(errmsg);
			free(errmsg);			/* Will never get here */
			break;
		case '\n':
			IncrLineNumber();
			PrintLineNumber();
			/* fall through... */
		default:
			if (c == close) {
				if (inString || inCharConst)
					goto PASSTHRU;
CLOSE:
				if (--nOpenDelims == 0) {
					putchar(close);
					return;
				}
			}
			else if (c == open && !inCharConst && !inString)
				++nOpenDelims;
PASSTHRU:
			putchar(c);
			break;
		}
	}
}

/*
** Print argument type/name pairs, using the format string fmt.
*/
static
void
PrintArgList(LIST *typeList, LIST *nameList)
{
	int i;

	for (i = 0; i < ListCount(typeList); ++i)
		printf(", %s %s", (char *)ListObjectAt(typeList, i),
				(char *)ListObjectAt(nameList, i));
}

char *
CurrClassName()
{
	return class_name;
}

char *
CurrSuperclassName()
{
	return superclass_name;
}

static
void
PrintXlatedFuncName(char *func_name)
{
	if (func_name == NULL)
		return;

	while (*func_name) {
		if (*func_name == ':')
			putchar('_');
		else
			putchar(*func_name);
		++func_name;
	}
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
