#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Object.h"

@interface Object
- onFile: (FILE *)fp;
@end

@implementation Object

/*
 * Allocate space for an object, whatever its class.
 * self is a Class pointer.
 */
+ alloc
{
	Object *newObj = (Object *)malloc(self->objectSize);
	
	if (newObj != nil) {
		memset(newObj, 0, self->objectSize);
		newObj->isa = self;
	}
	return (id)newObj;
}

+ new
{
	id obj = [self alloc];
	
	return (obj != nil) ? [obj init] : nil;
}

+ initialize
{
	return self;
}

// A class returns *itself* when asked "[ClassName class]"
+ class
{
	return self;
}

- init
{
	return self;
}

- free
{
	free(self);
	return nil;
}

- (char *)name
{
	return isa->name;
}

- class
{
	return (id)isa;
}

- superclass
{
	return (id)isa->superclass;
}

- (BOOL)isKindOf: aClassObject
{
	Class class = isa;
	
	for (class = isa; class; class = class->superclass)
		if (class == aClassObject)
			return YES;
	return NO;
}

- (BOOL)isMemberOf: aClassObject
{
	return (isa == aClassObject) ? YES : NO;
}

- (BOOL)isKindOfClassNamed: (char *)aClassName
{
	Class class = isa;
	
	for (class = isa; class; class = class->superclass)
		if (strcmp(class->name, aClassName) == 0)
			return YES;
	return NO;
}

- (BOOL)isMemberOfClassNamed: (char *)aClassName
{
	return (strcmp(isa->name, aClassName) == 0) ? YES : NO;
}

+ (BOOL)instancesRespondTo: (SEL)aSelector
{
	register Class class;
	register int n_methods;
	register int i;

	for (class = (Class)self; class != NULL; class = class->superclass) {
		n_methods = class->methods.count;
		for (i = 0; i < n_methods; ++i)
			if (strcmp(class->methods.list[i].name, (char *)aSelector) == 0)
				return YES;
	}
	return NO;
}

- (BOOL)respondsTo: (SEL)aSelector
{
	register Class class;
	register int n_methods;
	register int i;

	for (class = isa; class != NULL; class = class->superclass) {
		n_methods = class->methods.count;
		for (i = 0; i < n_methods; ++i)
			if (strcmp(class->methods.list[i].name, (char *)aSelector) == 0)
				return YES;
	}
	return NO;
}

- perform: (SEL)aSelector
{
#if 0
	return (*_msgSend(self, aSelector))(self, aSelector);
#else
	return _msgSend(self, aSelector);
#endif
}

- perform: (SEL)aSelector with: anObject
{
#if 0
	return (*_msgSend(self, aSelector))(self, aSelector, anObject);
#else
	return _msgSend(self, aSelector, anObject);
#endif
}

- perform: (SEL)aSelector with: object1 with: object2
{
#if 0
	return (*_msgSend(self, aSelector))(self, aSelector, object1, object2);
#else
	return _msgSend(self, aSelector, object1, object2);
#endif
}

- doesNotImplement
{
	char buf[BUFSIZ];
	
	[self onFile: stderr];
	sprintf(buf, " does not implement '%s'\n", _cmd);
	[self error: buf];
	return self;
}

- subclassResponsibility
{
	char buf[BUFSIZ];
	
	[self onFile: stderr];
	sprintf(buf, ":\n\tmethod '%s' should be implemented by a subclass\n",
			_cmd);
	return ([self error: buf]);
}

- error: (char *)s
{
	fprintf(stderr, "%s\n", s);
	exit(1);
}

- onFile: (FILE *)fp
{
	fprintf(fp, "Object <%p>", self);
	if (self == nil || isa == nil)
		fprintf(fp, " no class");
	else
		fprintf(fp, " class %s", isa->name);
	return self;
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

@end
