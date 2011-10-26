#ifndef List_h_
#define List_h_

#include <subjc/Object.h>

@interface List : Object
{
	id *data;				/* Data of the List object */
	int n_elements;			/* Actual number of elements */
	int n_allocated;		/* Total allocated elements */
}

/* Initializing */

- initCount: (int)numSlots;

/* Creating, freeing */

- free;
- freeObjects;
#if 0
/* #if 0 doesn't work for Subjective-C
- copyFromZone: (NXZone *)zone;
 */
 #endif

/* Comparing two lists */

- (BOOL)isEqual: anObject;
  
/* Managing the storage capacity */

- (int)capacity;
- setAvailableCapacity: (int)numSlots;

/* Manipulating objects by index */

- (int)count;
- objectAt: (int)index;
- lastObject;
- addObject: anObject;
- insertObject: anObject at: (int)index;
- removeObjectAt: (int)index;
- removeLastObject;
- replaceObjectAt: (int)index with: newObject;
- appendList: (List *)otherList;

/* Manipulating objects by id */

- (int)indexOf: anObject;
- addObjectIfAbsent: anObject;
- removeObject: anObject;
- replaceObject: anObject with: newObject;

/* Emptying the list */

- empty;

/* Sending messages to elements of the list */

- makeObjectsPerform: (SEL)aSelector;
- makeObjectsPerform: (SEL)aSelector with: anObject;

#if 0

/* Archiving */

/* #if 0 doesn't work for Subjective-C
- write: (NXTypedStream *)stream;
- read: (NXTypedStream *)stream;
 */
#endif

@end

#define NOT_IN_LIST	0xffff

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _list_h_ */
