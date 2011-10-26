#ifndef Object_h_
#define Object_h_

#include "Object_impl.h"
#include "Class.h"

@interface Object
{
	struct _Class *isa;
}

+ alloc;
+ new;
+ initialize;
+ class;

- init;
- free;

- (char *)name;
- class;
- superclass;

- (BOOL)isKindOf: aClassObject;
- (BOOL)isMemberOf: aClassObject;
- (BOOL)isKindOfClassNamed: (char *)aClassName;
- (BOOL)isMemberOfClassNamed: (char *)aClassName;

+ (BOOL)instancesRespondTo: (SEL)aSelector;
- (BOOL)respondsTo: (SEL)aSelector;

- perform: (SEL)aSelector;
- perform: (SEL)aSelector with: anObject;
- perform: (SEL)aSelector with: object1 with: object2;

- doesNotImplement;
- subclassResponsibility;
- error: (char *)s;

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* Object_h_ */
