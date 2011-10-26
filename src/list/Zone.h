#ifndef _zone_h_
#define _zone_h_

#include <subjc/Object.h>

@interface Zone : Object
{
	id *data;					/* Data of the Zone object */
	unsigned int nElements;		/* Actual number of elements */
	unsigned int nAllocated;	/* Total allocated elements */
	unsigned int elementSize;	/* Size, in bytes, of element */
}

/* Initializing */

- init;
- initSize: (unsigned int)slotSize count: (unsigned int)numSlots;

/* Creating, freeing */

- free;

/* Comparing two zones */

- (BOOL)isEqual: anObject;
  
/* Managing the storage capacity */

- (unsigned int)capacity;
- setAvailableCapacity: (unsigned int)numSlots;

/* Manipulating objects by index */

- (unsigned int)count;

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _zone_h_ */
