#ifndef Dictionary_h_
#define Dictionary_h_

#include <subjc/Object.h>

@interface Dictionary : Object
{
	id keyList;
	id valueList;
}

/* Initializing */

- init;
- initCount: (int)numSlots;

/* Creating, freeing */

- free;
- freeObjects;
#if 0
/* #if 0 doesn't work for Subjective-C
- copyFromZone: (NXZone *)zone;
 */
 #endif

/* Comparing two Dictionaries */

- (BOOL)isEqual: anObject;
  
/* Manipulating objects by index */

- (int)count;
- at: (const char *)key;
- at: (const char *)key put: (const char *)value;

/* Retreiving keys and values */
- keys;
- values;

/* Emptying the Dictionary */

- empty;

/* Sending messages to elements of the Dictionary */

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

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _Dictionary_h_ */
