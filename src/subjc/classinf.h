#ifndef Classinf_h_
#define Classinf_h_

#include "clist.h"

typedef struct IVarStruct IVar;
typedef struct MethodStruct Method;
typedef struct ClassInfoStruct ClassInfo;

struct IVarStruct
{
	char *type;
	char *restOfText;
	char *name;
};

struct MethodStruct
{
	char *name;
	char *return_type;
};

struct ClassInfoStruct
{
	char *name;
	ClassInfo *superclass_info;
	LIST *ivar_list;
	LIST *method_list;
};

ClassInfo *NewClassInfo(const char *className, const char *superclassName);
ClassInfo *LookupClassInfo(const char *className);
void AddClassVarText(ClassInfo *ci, char *text);
void AddClassFunc(ClassInfo *ci, char *text);
void AddClassFuncType(ClassInfo *ci, char *text);
void PrintSuperclassVars(ClassInfo *ci);
void AddMethod(char *class_name, char *method_name, char *return_type);
void MethodCastToBuf(char *method_name, char *out_buf);
void PrintMethodList(char *class_name);
int ClassNMethods(char *class_name);
int is_ivar(const char *class_name, const char *word);
void FreeClassInfo();

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* Classinf_h_ */
