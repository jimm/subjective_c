#ifndef _subjc_h_
#define _subjc_h_

#include <stdio.h>
#include <ctype.h>

/* Don't comment these out, just change their value */
/*
 * If SEND_WITHOUT_JUMP is defined, method calls are made by looking up the
 * proper function pointer and then calling that function. If it is not
 * defined, an assembly routine takes the function pointer and jumps directly
 * to the function.
 */
#define SEND_WITHOUT_JUMP		1 /* Don't jump via asm, return func ptr */

#define EXTRANEOUS_SPACES		1 /* Ignore extra spaces added by preproc */

#ifndef TRUE
#define TRUE  			1
#define FALSE 			0
#endif

#define MY_BUFSIZ		1024

#define D_QUOTE			'"'
#define S_QUOTE			'\''
#define BACKSLASH		'\\'

typedef enum {
	codeState_C,
	codeState_Interface,
	codeState_Implementation
} CodeState;

typedef enum {
	methodType_instance,
	methodType_class
} MethodType;

#define is_starting_id_char(c)		(isalpha(c) || (c) == '_')
#define is_id_char(c)				(isalnum(c) || (c) == '_')
#define is_starting_method_char(c)	(isalpha(c) || (c) == '_' || (c) == ':')
#define is_method_char(c)			(isalnum(c) || (c) == '_' || (c) == ':')
#define BufSkipWhitespace(b)		while (*(b) && isspace(*b)) ++(b)
#define IncrLineNumber()		(++gLineNum)

/* main.c */
#if defined(__THINK__) || defined(__MWERKS__)	/* macintosh */
OSErr MungeFile(FSSpec *inMacFSSpec);
#else
int MungeFile(char *fileName);
#endif
void GetWord(char *buf);
int NextNonWhitespace(void);
void SkipToChar(int c);
void PassPreprocLine(void);
void PrintLineNumber(void);
void PrintErrorLine(void);

extern CodeState gCodeState;
extern MethodType gMethodType;
extern int gLineNum;

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _subjc_h_ */
