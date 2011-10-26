#include <stdio.h>
#include <string.h>
#include "subjc.h"
#include "msgargs.h"
#include "bracket.h"
#include "classinf.h"
#include "error.h"
#include "xlate.h"

static char *GetDelimsFromString(int open, int close, int printDelims,
								 char *inBuf, char *outBuf, char *errType);

/*
** We've just seen a "foo:" method name part. Collect the next argument. If
** the next argument contains a bracket statement, recursively translate it.
** If it contains a @selector expression, evaluate it. inBuf may contain more
** of the method name (e.g., "3 * [self foo] + 1 bar: 42 : lastArg")
**
** NOTE: this routine may destructively modify the input buffer.
**
** NOTE: this is perhaps the weakest code in this entire program. Since
** it doesn't use lex/yacc, I'm sure that I haven't handled all cases
** properly.
**
** Returns a pointer to the char after the method argument part (e.g., to the
** 'b' in the example above).
*/
char *
CollectMessageArgs(char *inBuf, char *outBuf)
{
	register char *p;
	int seen_qmark = FALSE, prev_char = ' ', prev_nonspace = ' ', did_spew = 0,
		save_me;

	*outBuf = '\0';

	BufSkipWhitespace(inBuf);
	for (;;) {
		switch (*inBuf) {
		case '@':				/* Collect "@selector(foo:bar)" */
			if (strncmp(inBuf, "@selector", 9) == 0) {
				inBuf += 9;
				/* This is close to DoSelector(), but operates from inBuf */
				while (*inBuf && *inBuf != '(')
					++inBuf;
				if (*inBuf != '(') {
					Error("missing left paren after @selector\n");
					return inBuf;
				}
				strcat(outBuf, "(SEL)(\"");
				outBuf += strlen(outBuf);
				for (++inBuf; *inBuf && *inBuf != ')'; ++inBuf) {
					if (*inBuf != ' ')
						*outBuf++ = *inBuf;
				}
				*outBuf++ = '"';
				*outBuf++ = ')';
				*outBuf = '\0';
				++inBuf;		/* We don't need the right paren */
				prev_char = prev_nonspace = ')';
				++did_spew;
			}
			else {				/* "@" seen, but it's not "@selector" */
				Error("unknown or inappropriate @ keyword seen\n");
				return inBuf;
			}
			break;
		case '[':				/* Collect a bracket statement */
			if (is_id_char(prev_nonspace) || prev_nonspace == ']') {
				*outBuf++ = *inBuf++;
				*outBuf = '\0';
				prev_char = prev_nonspace = '[';
			}
			else {
				char buf[MY_BUFSIZ];
				inBuf =
					GetDelimsFromString('[', ']', FALSE, inBuf + 1, buf,
										"collect arg (bracket inside bracket)");
				XlateBracketBuf(buf, outBuf);
				outBuf += strlen(outBuf);
				prev_char = prev_nonspace = ']';
			}
			++did_spew;
			break;
		case S_QUOTE:				/* Collect string or char constant */
		case D_QUOTE:
			prev_char = prev_nonspace = *inBuf;
			inBuf = GetDelimsFromString(*inBuf, *inBuf, TRUE, inBuf + 1,
										 outBuf,
										"collect arg (char or string)");
			outBuf += strlen(outBuf);
			++did_spew;
			break;
		case '(':
			prev_char = prev_nonspace = '(';
			inBuf = GetDelimsFromString('(', ')', TRUE, inBuf + 1,
										 outBuf,
										"collect arg (paren expression)");
			outBuf += strlen(outBuf);
			++did_spew;
			break;
		case '?':
			seen_qmark = TRUE;
			prev_char = prev_nonspace = '?';
			*outBuf++ = *inBuf++;
			*outBuf = '\0';
			++did_spew;
			break;
		case ':':
			if (seen_qmark) {		/* We've got part of a "?:" trinary op */
				seen_qmark = FALSE;
				*outBuf++ = *inBuf++;
				*outBuf = '\0';
				++did_spew;
				prev_char = prev_nonspace = ':';
			}
			else				/* Next part of method name; we're done */
				return inBuf;
			break;
		case '\0':				/* Done */
			return inBuf;
		default:
			save_me = *inBuf;
			if (is_starting_id_char(*inBuf)) {
				int i;
				char ivar_name[MY_BUFSIZ];

				/* Check for next part of method name */
#if EXTRANEOUS_SPACES /* on some systems, must handle spaces before colons */
				int seen_space = 0;

				for (i = 0, p = inBuf; is_id_char(*p) || *p == ' '; ++p, ++i) {
					if (*p == ' ')
						seen_space = 1;
					else if (seen_space)
						break;
					ivar_name[i] = *p;
				}
				ivar_name[i] = '\0';
#else
				for (i = 0, p = inBuf; is_id_char(*p); ++p, ++i)
					ivar_name[i] = *p;
				ivar_name[i] = '\0';
#endif

				if (*p == ':' && did_spew) {
					/* Method name part; return without collecting it */
					*outBuf = '\0';
					return inBuf;
				}

				/* If it's an ivar, make it "self->ivar" */
				if (gCodeState == codeState_Implementation &&
					prev_nonspace != '>' && is_ivar(CurrClassName(),
													ivar_name))
				{
					strcat(outBuf, "self->");
					outBuf += strlen(outBuf);
				}

				/* Copy what we've just skipped over to the output buffer */
				while (inBuf != p)
					*outBuf++ = *inBuf++;
				*outBuf = '\0';
				++did_spew;
				/*
				 * So if next char is space, return. (We may not be done yet;
				 * this could be "arrayName[42]" and we've just seen
				 * "arrayName" and want to see the "[".
				 */
			}
			else {
				*outBuf++ = *inBuf++;
				*outBuf = '\0';
				++did_spew;
			}
			prev_char = save_me;
			if (prev_char != ' ')
				prev_nonspace = prev_char;
			break;
		}
	}
}

/*
** Collect text between delimeters (like open/close parens, open/close
** curlies, etc.). Print_delims and print_contents are booleans which determine
** what gets printed. This does exactly what CollectDelims() does, but input
** is from a string.
*/
static
char *
GetDelimsFromString(int open, int close, int print_delims, char *inBuf,
					char *outBuf, char *err_type_str)
{
	int c, nOpenDelims;
	int in_string = FALSE, in_char_const = FALSE;

	if (inBuf == NULL || outBuf == NULL)
		return inBuf;

	if (print_delims)
		*outBuf++ = open;

	if (open == S_QUOTE) in_char_const = TRUE;
	else if (open == D_QUOTE) in_string = TRUE;

	nOpenDelims = 1;
	for (;;) {
		switch (c = *inBuf++) {
		case S_QUOTE:
			if (close == S_QUOTE)
				goto CLOSE;
			if (!in_string)
				in_char_const = !in_char_const;
			goto PASSTHRU;
		case D_QUOTE:
			if (close == D_QUOTE)
				goto CLOSE;
			if (!in_char_const)
				in_string = !in_string;
			goto PASSTHRU;
		case BACKSLASH:
			*outBuf++ = BACKSLASH;
			c = *inBuf++;
			goto PASSTHRU;
		case '\0':
			sprintf(outBuf, "unexpected end of string in %s\n", err_type_str);
			Error(outBuf);
			break;
		default:
			if (c == close) {
				if (in_string || in_char_const)
					goto PASSTHRU;
CLOSE:
				if (--nOpenDelims == 0) {
					if (print_delims)
						*outBuf++ = close;
					*outBuf = '\0';
					return inBuf;
				}
			}
			else if (c == open && !in_char_const && !in_string)
				++nOpenDelims;
PASSTHRU:
			*outBuf++ = c;
			break;
		}
	}
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
