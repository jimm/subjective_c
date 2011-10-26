/*
** This stuff stores info about classes as we see 'em. Class info include
** the class name, superclass name, a pointer to the superclass, and the
** list of ivars.
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "subjc.h"
#include "classinf.h"
#include "error.h"

static LIST *class_list = NULL;

static ClassInfo *RealNew(const char *class_name, const char *superclass_name);
static void DeleteClassListItem(ClassInfo *ci);
static void CreateIVar(ClassInfo *ci, const char *type, const char *varText,
					   const char *varName);
static int is_ivar_internal(const ClassInfo *ci, const char *word);

/*
** Allocate, initialize, and return a pointer to a ClassInfo structure.
** The structure is store in a list for later retrieval.
**
** Also creates a metaclass object.
*/
ClassInfo *
NewClassInfo(const char *class_name, const char *superclass_name)
{
	char meta_class_name[MY_BUFSIZ], meta_superclass_name[MY_BUFSIZ];

	sprintf(meta_class_name, "_%s", class_name);
	if (strcmp(superclass_name, "NULL") == 0)
		strcpy(meta_superclass_name, "NULL");
	else
		sprintf(meta_superclass_name, "_%s", superclass_name);

	(void)RealNew(meta_class_name, meta_superclass_name);

	return RealNew(class_name, superclass_name);
}

static
ClassInfo *
RealNew(const char *class_name, const char *superclass_name)
{
	ClassInfo *ci;

	ci = malloc(sizeof(ClassInfo));
	if (ci == NULL)
		return NULL;

	ci->name = malloc(strlen(class_name) + 1);
	if (ci->name == NULL) {
		free(ci);
		return NULL;
	}
	strcpy(ci->name, class_name);

	/* Lazily instantiate class_list and add ci to it */
	if (class_list == NULL)
		class_list = ListNew();
	ListAddObject(class_list, ci);

	/* Get a pointer to ci's superclass and complain if it's not found */
	ci->superclass_info = LookupClassInfo(superclass_name);
	if (ci->superclass_info == NULL && strcmp(superclass_name, "NULL") != 0) {
		char buf[MY_BUFSIZ];
		sprintf(buf, "class %s: unknown superclass %s\n", class_name,
				superclass_name);
		FatalError(buf);
	}

	ci->ivar_list = ListNew();
	ci->method_list = ListNew();

	return ci;
}

/*
** Given a string, walk through class_list to find the ClassInfo with that
** name. If it isn't there, return NULL.
*/
ClassInfo *
LookupClassInfo(const char *class_name)
{
	int i;
	ClassInfo *ci;

	for (i = 0; i < ListCount(class_list); ++i) {
		ci = (ClassInfo *)ListObjectAt(class_list, i);
		if (strcmp(class_name, ci->name) == 0)
			return ci;
	}
	return NULL;
}

/*
** Add instance variable text (from an "@interface" declaration) to a class.
** Splits "int x, *y;" into "int", "x" and "int *", "y". ivar_text has no
** whitespace at the beginning, and probably ends with ";\n" (plus surrounding
** whitespace);
*/
void
AddClassVarText(ClassInfo *ci, char *ivar_text)
{
	int isQualifier, parenCount, idFound = FALSE;
	char *stmtStart, type[MY_BUFSIZ], varName[MY_BUFSIZ], varText[MY_BUFSIZ], *p, *s,
		*varNamePtr, *varTextPtr;

	for (stmtStart = strtok(ivar_text, ";"); stmtStart != NULL; stmtStart = strtok(NULL, ";")) {
		p = stmtStart;
		BufSkipWhitespace(p);
		for (s = type; is_id_char(*p); ++p)
			*s++ = *p;
		*s = '\0';
		BufSkipWhitespace(p);
		isQualifier = (strcmp(type, "unsigned") == 0 ||
					   strcmp(type, "long") == 0 ||
					   strcmp(type, "short") == 0);
		if (isQualifier || strcmp(type, "struct") == 0) {
			char *typeCurrEnd;

			BufSkipWhitespace(p);
			*s++ = ' ';
			for (typeCurrEnd = s; is_id_char(*p); ++p)
				*s++ = *p;
			*s = '\0';
			/*
			** if we have "(unsigned|long|short)" but not
			** " (int|char|double|float)" after, then un-get the second word.
			*/
			if (isQualifier &&
				!(strcmp(typeCurrEnd, " int") == 0 ||
				  strcmp(typeCurrEnd, " char") == 0 ||
				  strcmp(typeCurrEnd, " double") == 0 ||
				  strcmp(typeCurrEnd, " float") == 0))
				{
					*typeCurrEnd = '\0';
				}
		}

		/*
		** We now have a type: one of "UnknownName", "struct name", or
		** "(<qual>)?type". p points to the next char after the
		** type. Loop over the rest, which are comma separated
		** identifiers, each preceeded by a non-negative number of
		** '*'.  This gets tricky, because these "identifiers" could
		** be something like ** (*funcPtr)(int, id), *foo[42],
		** ***barPtrPtrPtr; Notice we can't just use strtok() with a
		** comma separator. That sucks.
		**
		** varText stores "(*funcPtr)(int, id)" and varName stores "funcPtr".
		*/
		parenCount = 0;
		idFound = FALSE;
		varName[0] = varText[0] = '\0';
		varNamePtr = varName;
		varTextPtr = varText;
		while (*p != '\0') {
			switch (*p) {
			case '(':
				++parenCount;
				*varTextPtr++ = *p++;
				break;
			case ')':
				--parenCount;
				*varTextPtr++ = *p++;
				break;
			case ',':
				if (parenCount == 0) {
					/*
					** After "x" in "int x, y" or after "(*funcPtr)(int, int)" in
					** "void (*funcPtr)(int, int), (*g)(void)". We've already
					** collected the "x" or "funcPtr" if idFound is TRUE.
					*/
					if (idFound) {
						*varTextPtr = '\0';
						CreateIVar(ci, type, varText, varName);
						idFound = FALSE;
					}
					/* Reset buffers so we can collect next ident, if any */
					varName[0] = varText[0] = '\0';
					varNamePtr = varName;
					varTextPtr = varText;

					++p;
				}
				else
					*varTextPtr++ = *p++;
				break;
			default:
				if (!idFound && is_id_char(*p)) {
					while (is_id_char(*p)) {
						*varTextPtr++ = *p;
						*varNamePtr++ = *p++;
					}

					/* We've collected the id ("x" or "funcPtr" in the
					   above examples) */
					*varNamePtr = '\0';
					idFound = TRUE;
				}
				else
					*varTextPtr++ = *p++;
				break;
			}
		}
		if (idFound) {
			*varTextPtr = '\0';
			CreateIVar(ci, type, varText, varName);
		}
	}
}

/*
** Print all of the instance variables from all superclasses of a class.
** This is used during translation from an "@interface" declaration to
** a C struct.
*/
void
PrintSuperclassVars(ClassInfo *ci)
{
	int i, j;
	LIST *cl;

	if (ci == NULL)
		return;

	/* Make a list of superclasses from ci's superclass back up to object */
	cl = ListNew();
	for (ci = ci->superclass_info; ci != NULL; ci = ci->superclass_info)
		ListAddObject(cl, (unsigned char *)ci);

	/*
	** Traverse the class hierarchy backwards (down from Object), printing
	** all of the instance variables for that class.
	** Note: we're reusing the variable ci since it's not needed anymore.
	*/
	for (i = ListCount(cl) - 1; i >= 0; --i) {
		ci = (ClassInfo *)ListObjectAt(cl, i);
		for (j = 0; j < ListCount(ci->ivar_list); ++j) {
			IVar *ivar = (IVar *)ListObjectAt(ci->ivar_list, j);

			printf("	%s %s;\n", ivar->type, ivar->restOfText);
		}
	}
	ListFree(cl);
}

/*
** Add a method name to the list of methods implemented by this class,
** and to the global method name list.
*/
void
AddMethod(char *class_name, char *method_name, char *return_type)
{
	ClassInfo *ci = LookupClassInfo(class_name);
	Method *method = malloc(sizeof(Method));
	
	method->name = malloc(strlen(method_name) + 1);
	strcpy(method->name, method_name);

	method->return_type = malloc(strlen(return_type) + 1);
	strcpy(method->return_type, return_type);

	ListAddObject(ci->method_list, method);
}

/*
** Print the list of methods implemented by this (meta)class in the proper
** format.
*/
void
PrintMethodList(char *class_name)
{
	register ClassInfo *ci = LookupClassInfo(class_name);
	register Method *method;
	register char *name;
	int i, n_methods;

	if (ci == NULL) {
		/* Should never be true */
		Error("internal error: null class in PrintMethodList");
		return;
	}

	n_methods = ListCount(ci->method_list);
	if (n_methods == 0) {
		/* Compiler complains if struct has no members */
		printf("	{0, 0}\n");
		return;
	}
	for (i = 0; i < n_methods; ++i) {
		method = (Method *)ListObjectAt(ci->method_list, i);
		name = method->name;
		printf("	{\"%s\", (void (*)())%s_", name, class_name);
		while (*name) {
			putchar(*name == ':' ? '_' : *name);
			++name;
		}
		printf("}%c\n", (i == n_methods - 1) ? ' ' : ',');
	}
}

/*
** Print a typecast for this method name.
*/
void
MethodCastToBuf(char *method_name, char *out_buf)
{
	int i, j;
	ClassInfo *ci;
	Method *method;
	
	for (i = 0; i < ListCount(class_list); ++i) {
		ci = (ClassInfo *)ListObjectAt(class_list, i);
		for (j = 0; j < ListCount(ci->method_list); ++j) {
			method = (Method *)ListObjectAt(ci->method_list, j);
			if (strcmp(method->name, method_name) == 0) {
#ifdef SEND_WITHOUT_JUMP
				sprintf(out_buf + strlen(out_buf),
						"(*(%s(*)())", method->return_type);
#else /* not SEND_WITHOUT_JUMP */
				sprintf(out_buf + strlen(out_buf),
						"((%s(*)())", method->return_type);
#endif /* not SEND_WITHOUT_JUMP */
				return;
			}
		}
	}
	/* error */
	strcat(out_buf, "(");
}

/*
** Return the number of methods that a class implements.
*/
int
ClassNMethods(char *class_name)
{
	register ClassInfo *ci = LookupClassInfo(class_name);

	if (ci == NULL)
		return 0;
	return ListCount(ci->method_list);
}

/*
** Returns 1 if word is an ivar of class class_name, else returns 0.
*/
int
is_ivar(const char *class_name, const char *word)
{
	int retval;
	char savedEnd, *wordEnd;
	ClassInfo *ci = LookupClassInfo(class_name);

	if (ci == NULL)
		return 0;

	for (wordEnd = (char *)word; is_id_char(*wordEnd); ++wordEnd)
		;
	savedEnd = *wordEnd;
	*wordEnd = '\0';

	retval = is_ivar_internal(ci, word);
	*wordEnd = savedEnd;
	return retval;
}

/*
** Returns 1 if word is an ivar of class ci or its superclasses, else
** returns 0.
*/
static int
is_ivar_internal(register const ClassInfo *ci, const char *word)
{
	int i;

	/* ci will never be NULL here */
	for (i = 0; i < ListCount(ci->ivar_list); ++i) {
		register IVar *ivar = (IVar *)ListObjectAt(ci->ivar_list, i);
		if (strcmp(word, ivar->name) == 0)
			return 1;
	}

	return ci->superclass_info == NULL ? 0
		: is_ivar_internal(ci->superclass_info, word);
}

/*
** This gets called by MungeFile().
*/
void
FreeClassInfo()
{
	ListMakeObjectsPerform(class_list, (VFPTR)DeleteClassListItem);
	ListFree(class_list);
	class_list = NULL;
}

/*
** This is a callback routine which is ...umm... called for each entry
** in class_list to let it free its contents.
*/
static
void
DeleteClassListItem(ClassInfo *ci)
{
	int i;
	IVar *ivar;
	Method *method;

	if (ci->name)
		free(ci->name);
	if (ci->ivar_list) {
		for (i = 0; i < ListCount(ci->ivar_list); ++i) {
			ivar = (IVar *)ListObjectAt(ci->ivar_list, i);
			free(ivar->type);
			free(ivar->restOfText);
			free(ivar->name);
			free(ivar);
		}
		ListFree(ci->ivar_list);
	}
	if (ci->method_list) {
		for (i = 0; i < ListCount(ci->method_list); ++i) {
			method = (Method *)ListObjectAt(ci->method_list, i);
			free(method->name);
			free(method->return_type);
			free(method);
		}
		ListFree(ci->method_list);
	}	
	free(ci);
}

static void
CreateIVar(ClassInfo *ci, const char *type, const char *varText,
		   const char *varName)
{
	int isAnIVar;
	char savedEnd, *wordEnd;
	IVar *ivar;

	for (wordEnd = (char *)varName; is_id_char(*wordEnd); ++wordEnd)
		;
	savedEnd = *wordEnd;
	*wordEnd = '\0';

	isAnIVar = is_ivar_internal(ci, varName);
	*wordEnd = savedEnd;

	if (isAnIVar) {
		char buf[MY_BUFSIZ];
		sprintf(buf,
				"ivar %s previously defined in class %s or a superclass",
				varName, ci->name);
		Error(buf);
		return;
	}

	ivar = malloc(sizeof(IVar));
	ivar->type = malloc(strlen(type) + 1);
	strcpy(ivar->type, type);
	ivar->restOfText = malloc(strlen(varText) + 1);
	strcpy(ivar->restOfText, varText);
	ivar->name = malloc(strlen(varName) + 1);
	strcpy(ivar->name, varName);
	ListAddObject(ci->ivar_list, ivar);
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
