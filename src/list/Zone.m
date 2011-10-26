#include <stdio.h>
#include <stdlib.h>
#include "Zone.h"

#define INITIAL_SIZE	4

@implementation Zone

/*
 * Initializes the receiver, a new Zone object, but doesn't allocate any memory
 * for its array of object ids.	It's initial capacity will be 0.	Minimal
 * amounts of memory will be allocated when objects are added to the Zone.
 * Or an initial capacity can be set, before objects are added, using the
 * setAvailableCapacity: method.	Returns self.
 */
- init
{
	[super init];
	elementSize = 1;
	return self;
}

/*
 * Initializes the receiver, a new Zone object, by allocating enough memory for
 * it to hold numSlots objects.	Returns self.
 *
 * This method is the designated initializer for the class.	It should be used
 * immediately after memory for the Zone has been allocated and before any
 * objects have been assigned to it; it shouldn't be used to reinitialize a
 * Zone that's already in use.
 */
- initSize: (unsigned int)slotSize count: (unsigned int)numSlots
{
	[super init];
	elementSize = 1;
	[self setAvailableCapacity: numSlots];
	return self;
}

/*
 * Deallocates the Zone object and the memory it allocated for the array of
 * object ids.	However, the objects themselves aren't freed.
 */
- free
{
	if (data)
		free(data);
	nElements = nAllocated = 0;
	return [super free];
}

/*
 * Compares the receiving Zone to anObject.	If anObject is a Zone with exactly
 * the same contents as the receiver, this method returns YES.	If not, it
 * returns NO.
 *
 * Two Zones have the same contents if they each hold the same number of
 * objects and the ids in each Zone are identical and occur in the same order.
 *
 * NOTE: Should check class of anObject to see if it's a (sub)class of Zone.
 */
- (BOOL)isEqual: anObject
{
	unsigned int index;

	if (anObject == nil || ![anObject isKindOf: ZoneClass] ||
		nElements != [anObject count] ||
		elementSize != ((Zone *)anObject)->elementSize)
		return NO;

	if (memcmp(data, ((Zone *)anObject)->data) != 0)
		return NO;

	return YES;
}

/*
 * Returns the maximum number of objects that can be stored in the Zone without
 * allocating more memory for it.	When new memory is allocated, it's taken
 * from the same zone that was specified when the Zone was created.
 */
- (unsigned int)capacity
{
	return nAllocated;
}

/*
 * Sets the storage capacity of the Zone to at least numSlots objects and
 * returns self.	However, if the Zone already contains more than numSlots
 * objects (if the count method returns a number greater than numSlots), its
 * capacity is left unchanged and nil is returned.
 */
- setAvailableCapacity: (unsigned int)numSlots
{
	unsigned int newNAlloc;
	size_t size;
	id newData;

	if (nAllocated > numSlots)
		return nil;

	newNAlloc = (nAllocated == 0) ? INITIAL_SIZE : nAllocated;

	while (newNAlloc < numSlots)
		newNAlloc *= 2;

	size = (size_t)(newNAlloc * elementSize);

	if (data == NULL)
		data = malloc(size);
	else
		data = realloc(data, size);

	nAllocated = newNAlloc;
	return self;
}

/*
 * Returns the number of objects currently in the Zone.
 */
- (unsigned int)count
{
	return nElements;
}

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
