/*
** Translate Subjective-C bracket statements into C function calls.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "subjc.h"
#include "bracket.h"
#include "classinf.h"
#include "error.h"
#include "msgargs.h"
#include "xlate.h"

static char *CollectObject(char *buf, char *outBuf);
static char *FindMatchingRBracket(char *buf);
static char *NextMethodNamePart(char *buf, char *funcName);

/*
** Collect a bracket statment and pass it along to XlateBracketBuf().
*/
void
DoBracket()
{
	char bracket_text[MY_BUFSIZ], output[MY_BUFSIZ],
		bracket_text_copy[MY_BUFSIZ], *p;

	CollectDelims('[', ']', bracket_text, "collecting bracket expression");

	/* If there is only one word here, there's nothing to translate */
	p = bracket_text;
	BufSkipWhitespace(p);
	if (*p == '\0') {
NOT_MESSAGE_SEND:
		printf("[%s]", bracket_text);
		return;
	}
	while (*p && !isspace(*p)) ++p;
	BufSkipWhitespace(p);
	if (*p == '\0')
		goto NOT_MESSAGE_SEND;
	
	*output = '\0';

	/*
	 * Since XlateBracketBuf() munges its input and we may need it if we goto
	 * NOT_MESSAGE_SEND, make a copy and work on the copy.
	 */
	strcpy(bracket_text_copy, bracket_text);
	if (XlateBracketBuf(bracket_text_copy, output) == FALSE) {
		goto NOT_MESSAGE_SEND;
	}

	printf(output);
	PrintLineNumber();
}

/*
** Preprocess a bracket statement. Translate
**		[object method: arg1 name: [object foo]];
** into
**				((ret_type(*)())_msgSend)(object, (SEL)"method:name", arg1,
**										  ((ret_type(*)())_msgSend)(object,
**												(SEL)"foo"));
** and
**				[super free];
** into
**				((ret_type(*)())_msgSuper)((_gSuperContext.receiver=self,
**											_gSuperContext.class=<superclass>,
**												&gSuperContext),
**												(SEL)"foo");
** etc.
**
** Returns TRUE if translation took place, else returns FALSE (so our caller
** can print out the original text).
*/
int
XlateBracketBuf(char *inBuf, char *outBuf)
{
	int i;
	char func_name[MY_BUFSIZ], message_target[MY_BUFSIZ], *arg_text_buf;
	LIST *argList = NULL;

	/* Collect the first part of the statement: the target of the message */

	inBuf = CollectObject(inBuf, message_target);
	if (isupper(*message_target)) /* Special case: class name */
		strcat(message_target, "Class");

	/*
	** Now find the next method name part. If it ends in ':', read the
	** argument and go back for more.
	*/

	*func_name = '\0';
	while (*(inBuf = NextMethodNamePart(inBuf, func_name)) != '\0') {
		if (func_name[strlen(func_name) - 1] == ':') {
			/* We've got an argument to find... */
			arg_text_buf = malloc(MY_BUFSIZ);
			if (argList == NULL) /* Lazily instantiate a list that holds */
				argList = ListNew(); /*   the arguments */

			/* Read and (perhaps recursively) translate the argument */
			inBuf = CollectMessageArgs(inBuf, arg_text_buf);
			ListAddObject(argList, arg_text_buf);
		}
		else
			break;
	}

	if (*func_name == '\0') {		/* There was no method name */
		return FALSE;
	}

	/*
	** Print the message send. This will end up looking something like
	** (*(int (*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", arg1)
	** if done with compile-time switch SEND_WITHOUT_JUMP, or
	** ((int(*)())_msgSend)(self, (SEL)"foo:", arg1)
	** if done without.
	*/
	MethodCastToBuf(func_name, outBuf);
	if (strcmp(message_target, "super") == 0) {
		char name[MY_BUFSIZ];

		if (gCodeState != codeState_Implementation) {
			Error("messages to \"super\" only allowed in @implementation "
				  "methods\n"
				  "message was written to send to \"self\" instead");
			strcpy(message_target, "self");
			goto NOT_SUPER_SEND;
		}

		strcpy(name, CurrSuperclassName());
		if (strcmp(name, "NULL") != 0) {
			if (gMethodType == methodType_instance)
				strcat(name, "Class");
			else {
				/* We're not using message_target anymore. Construct
				   superclass name there. */
				sprintf(message_target, "_%s", name);
				strcpy(name, message_target);
			}
		}
		else
			strcpy(name, "0");
#ifdef SEND_WITHOUT_JUMP
		sprintf(outBuf + strlen(outBuf),
				"_msgSuper((_gSuperContext.receiver=self," /* concat... */
				"_gSuperContext.class=%s,&_gSuperContext)" /* concat... */
				", (SEL)\"%s\"))(self, (SEL)\"%s\"", name, func_name,
				func_name);
#else /* not SEND_WITHOUT_JUMP */
		sprintf(outBuf + strlen(outBuf),
				"_msgSuper)((_gSuperContext.receiver=self," /* concat... */
				"_gSuperContext.class=%s,&_gSuperContext)", name);
#endif /* not SEND_WITHOUT_JUMP */
	}
#ifdef SEND_WITHOUT_JUMP
	else {
NOT_SUPER_SEND:
		sprintf(outBuf + strlen(outBuf),
				"_msgSend(%s, (SEL)\"%s\"))(%s, (SEL)\"%s\"", message_target,
				func_name, message_target, func_name);
	}
#else /* not SEND_WITHOUT_JUMP */
	else {
NOT_SUPER_SEND:
		sprintf(outBuf + strlen(outBuf), "_msgSend)(%s", message_target);
	}
	sprintf(outBuf + strlen(outBuf), ", (SEL)\"%s\"", func_name);
#endif /* not SEND_WITHOUT_JUMP */

	/* Print the method arguments */
	if (argList != NULL) {
		for (i = 0; i < ListCount(argList); ++i)
			sprintf(outBuf + strlen(outBuf), ", %s",
					(char *)ListObjectAt(argList, i));
	}

	/* ...and finish up */
	strcat(outBuf, ")");

	if (argList != NULL) {
		ListFreeArrayObjects(argList);
		ListFree(argList);
	}

	return TRUE;
}

/*
** Collect method target's name or expression into out_buf.
*/
static
char *
CollectObject(char *buf, char *out_buf)
{
	char *p;

	BufSkipWhitespace(buf);
	if (*buf == '[') {
		/* The target is a bracket expression; translate it */
		p = FindMatchingRBracket(buf + 1);
		*out_buf = *p = '\0';
		XlateBracketBuf(buf + 1, out_buf);
	}
	else {
		/* Just collect up until the first whitespace character */
		for (p = buf; *p && !isspace(*p); ++p)
			;
		*p = '\0';

		/* If it's an ivar, make it "self->ivar" */
		if (gCodeState == codeState_Implementation &&
			is_ivar(CurrClassName(), buf)) {
			strcpy(out_buf, "self->");
			out_buf += strlen(out_buf);
		}

		strcpy(out_buf, buf);
	}
	return p + 1;
}

/*
** Buf points to the char after the first right bracket. Return
** a pointer to the matching right bracket. Handles embedded
** strings, character constants, etc.
*/
static
char *
FindMatchingRBracket(char *buf)
{
	int n_brackets, in_char_const = FALSE, in_string = FALSE;

	for (n_brackets = 1; *buf; ++buf) {
		switch (*buf) {
		case ']':
			if (!in_string && !in_char_const && (--n_brackets == 0))
				return buf;
			break;
		case '[':
			if (!in_char_const && !in_string)
				++n_brackets;
			break;
		case S_QUOTE:
			if (!in_string)
				in_char_const = !in_char_const;
			break;
		case D_QUOTE:
			if (!in_char_const)
				in_string = !in_string;
			break;
		case BACKSLASH:
			++buf;
			break;
		}
	}
	return buf;						/* Just in case! */
}

/*
** Collect the next part of the method name, if any. Since some preprocessors
** add spaces around anything, including colons, we must keep looking for
** a colon even after the end of a word!
*/
static
char *
NextMethodNamePart(char *buf, char *func_name)
{
#if EXTRANEOUS_SPACES
	int seen_space = 0;

	BufSkipWhitespace(buf);
	func_name += strlen(func_name);
	while (is_method_char(*buf) || *buf == ' ') {
		if (*buf == ':') {
			*func_name++ = *buf++;
			break;
		}
		else if (*buf == ' ') {		/* Handle "namePart :" */
			seen_space = 1;
		}
		else {
			if (seen_space)
				break;
			*func_name++ = *buf;
		}
		++buf;
	}
	*func_name = '\0';
	return buf;
#else
	BufSkipWhitespace(buf);
	func_name += strlen(func_name);
	while (is_method_char(*buf)) {
		*func_name++ = *buf;
		if (*buf++ == ':')
			break;
	}
	*func_name = '\0';
	return buf;
#endif
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
