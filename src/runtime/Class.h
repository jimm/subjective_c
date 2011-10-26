#ifndef Class_h_
#define Class_h_

#if !defined(__THINK__) && !defined(__MWERKS__)
#include <sys/types.h>
#endif /* not macintosh */

#define _SUBJC_CACHE_SIZE		32

typedef struct _Method {
	char *name;
	void (*func_ptr)();
} *Method;

typedef struct _MethodList {
	int count;
	struct _Method *list;
} MethodList;

typedef struct _Cache {
	int nextSlot;
	struct _Method methodCache[_SUBJC_CACHE_SIZE];
} Cache;

typedef struct _Class {
	struct _Class *isa;
	struct _Class *superclass;
	size_t objectSize;
	char *name;
	MethodList methods;
	Cache cache;
	int isInitialized;
} *Class;

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* Class_h_ */
