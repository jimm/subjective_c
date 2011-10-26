#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "subjc.h"

static char preprocFileName[MY_BUFSIZ];
static char inputFileName[MY_BUFSIZ];

/*
  ** Flush stdout and print the current file name and line number on cerr,
  ** then print caller's error message.
  */
void
Error(const char *errmsg)
{
	fflush(stdout);
	fprintf(stderr, "%s %s (%d): %s\n", preprocFileName, inputFileName,
			gLineNum, errmsg);
}

/*
  ** Call Error() and exit.
  */
void
FatalError(const char *errmsg)
{
	Error(errmsg);
	exit(1);
}

#if 0

/*
** Flush stdout and print the current file name and line number on stderr.
*/
void
PrintErrorLine()
{
	fflush(stdout);
	fprintf(stderr, "%s (%d): ", gFileName, gLineNum);
}

#endif

void
SetPreprocFileName(const char *fileName)
{
	strcpy(preprocFileName, fileName);
}

const char *
GetPreprocFileName()
{
	return preprocFileName;
}

void
SetIncludeFileName(const char *fileName)
{
	strcpy(inputFileName, fileName);
}

const char *
GetIncludeFileName()
{
	return inputFileName;
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
