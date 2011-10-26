#include <stdio.h>
#include <stdlib.h>
#include "List.h"

#define INITIAL_SIZE	4

@implementation List

/*
 * Initializes the receiver, a new List object, by allocating enough memory for
 * it to hold numSlots objects.  Returns self.
 *
 * This method is the designated initializer for the class.  It should be used
 * immediately after memory for the List has been allocated and before any
 * objects have been assigned to it; it shouldn't be used to reinitialize a
 * List that's already in use.
 */
- initCount: (int)numSlots
{
    [super init];
    return [self setAvailableCapacity: numSlots];
}

/*
 * Deallocates the List object and the memory it allocated for the array of
 * object ids.  However, the objects themselves aren't freed.
 */
- free
{
    if (data)
	free(data);
    n_elements = n_allocated = 0;
    return [super free];
}

/*
 * Removes every object from the List, sends each one of them a free message,
 * and returns self.  The List object itself isn't freed and its current
 * capacity isn't altered.
 *
 * The methods that free the objects shouldn't have the side effect of
 * modifying the List.
 */
- freeObjects
{
    int index;

    for (index = 0; index < n_elements; ++index)
	[data[index] free];
    n_elements = 0;
    return self;
}

/*
 * Compares the receiving List to anObject.  If anObject is a List with exactly
 * the same contents as the receiver, this method returns YES.  If not, it
 * returns NO.
 *
 * Two Lists have the same contents if they each hold the same number of
 * objects and the ids in each List are identical and occur in the same order.
 *
 * NOTE: Should check class of anObject to see if it's a (sub)class of List.
 */
- (BOOL)isEqual: anObject
{
    int index;

    if (anObject == nil || ![anObject isKindOf: ListClass] ||
	n_elements != [anObject count])
	return NO;

    for (index = 0; index < n_elements; ++index)
	if (data[index] != ((List *)anObject)->data[index])
	    return NO;

    return YES;
}

/*
 * Inserts anObject at the end of the List, and returns self.  However, if
 * anObject is nil, nothing is inserted and nil is returned.
 */
- addObject: anObject
{
    if (anObject == nil)
	return nil;

    if (n_elements >= n_allocated) {
	if ([self setAvailableCapacity: n_allocated * 2] == nil)
	    return nil;
    }
    data[n_elements++] = anObject;
    return self;
}

/*
 * Returns the maximum number of objects that can be stored in the List without
 * allocating more memory for it.  When new memory is allocated, it's taken
 * from the same zone that was specified when the List was created.
 */
- (int)capacity
{
    return n_allocated;
}

/*
 * Sets the storage capacity of the List to at least numSlots objects and
 * returns self.  However, if the List already contains more than numSlots
 * objects (if the count method returns a number greater than numSlots), its
 * capacity is left unchanged and nil is returned.
 */
- setAvailableCapacity: (int)numSlots
{
    int newNAlloc;
    size_t size;

    if (n_allocated > numSlots)
	return nil;

    newNAlloc = (n_allocated == 0) ? INITIAL_SIZE : n_allocated;

    while (newNAlloc < numSlots)
	newNAlloc *= 2;

    size = (size_t)(newNAlloc * sizeof(id));

    if (data == NULL)
	data = malloc(size);
    else
	data = realloc(data, size);

    n_allocated = newNAlloc;
    return self;
}

/*
 * Returns the number of objects currently in the List.
 */
- (int)count
{
    return n_elements;
}

/*
 * Returns the id of the object located at slot index, or nil if index is
 * beyond the end of the List.
 */
- objectAt: (int)index
{
    if (index >= n_elements)
	return nil;

    return data[index];
}

/*
 * Returns the last object in the List, or nil if there are no objects in the
 * List.  This method doesn't remove the object that's returned.
 */
- lastObject
{
    if (n_elements > 0)
	return data[n_elements - 1];
    else
	return nil;
}

/*
 * Inserts anObject into the List at index, moving objects down one slot to
 * make room.  If index equals the value returned by the count method, anObject
 * is inserted at the end of the List.  However, the insertion fails if index
 * is greater than the value returned by count or anObject is nil.
 *
 * If anObject is successfully inserted into the List, this method returns
 * self. If not, it returns nil.
 */
- insertObject: anObject at: (int)index
{
    int i;

    if (index > n_elements || anObject == nil)
	return nil;

    if (index == n_elements)
	return [self addObject: anObject];

    for (i = n_elements; i > index; --i)
	data[i] = data[i - 1];
    ++n_elements;
    data[index] = anObject;

    return self;
}

/*
 * Removes the object located at index and returns it.  If there's no object at
 * index, this method returns nil.
 *
 * The positions of the remaining objects in the List are adjusted so there's
 * no gap.
 */
- removeObjectAt: (int)index
{
    id obj;

    if (n_elements == 0 || index >= n_elements)
	return nil;

    obj = data[index];
    for (--n_elements; index < n_elements; ++index)
	data[index] = data[index + 1];

    return obj;
}

/*
 * Removes the object occupying the last position in the List and returns it.
 * If there are no objects in the List, this method returns nil.
 */
- removeLastObject
{
    id obj;

    if (n_elements == 0)
	return nil;

    obj = data[--n_elements];
    return obj;
}

/*
 * Returns the object at index after replacing it with newObject.  If there's
 * no object at index or newObject is nil, nothing is replaced and nil is
 * returned.
 */
- replaceObjectAt: (int)index with: newObject
{
    id obj;

    if (index >= n_elements || newObject == nil)
	return nil;

    obj = data[index];
    data[index] = newObject;
    return obj;
}

/*
 * Inserts all the objects in otherList at the end of the receiving List, and
 * returns self.  The ordering of the objects is maintained.
 */
- appendList: (List *)otherList
{
    int index;

    if (![otherList isKindOf: ListClass])
	return nil;

    for (index = 0; index < [otherList count]; ++index)
	[self addObject: [otherList objectAt: index]];

    return self;
}

/*
 * Returns the index of the first occurrence of anObject in the List, or
 * NOT_IN_LIST if anObject isn't in the List.
 */
- (int)indexOf: anObject
{
    int index;

    if (anObject == nil)
	return NOT_IN_LIST;

    for (index = 0; index < n_elements; ++index)
	if (data[index] == anObject)
	    return index;

    return NOT_IN_LIST;
}

/*
 * Inserts anObject at the end of the List and returns self, provided that
 * anObject isn't already in the List.  If anObject is in the List, it won't be
 * inserted, but self is still returned.
 *
 * If anObject is nil, nothing is inserted and nil is returned.
 */
- addObjectIfAbsent: anObject
{
    if (anObject == nil)
	return nil;

    if ([self indexOf: anObject] == NOT_IN_LIST) {
	if (n_elements >= n_allocated) {
	    if ([self setAvailableCapacity: n_allocated * 2] == nil)
		return nil;
	}
	data[n_elements++] = anObject;
    }
    return self;
}

/*
 * Removes the first occurrence of anObject from the List, and returns it.  If
 * anObject isn't in the List, this method returns nil.
 *
 * The positions of the remaining objects in the List are adjusted so there's
 * no gap.
 */
- removeObject: anObject
{
    int index = [self indexOf: anObject];

    if (index == NOT_IN_LIST)
	return nil;

    return [self removeObjectAt: index];
}

/*
 * Replaces the first occurrence of anObject in the List with newObject, and
 * returns anObject.  However, if newObject is nil or anObject isn't in the
 * List, nothing is replaced and nil is returned.
 */
- replaceObject: anObject with: newObject
{
    int index = [self indexOf: anObject];

    if (index == NOT_IN_LIST || newObject == nil)
	return nil;

    data[index] = newObject;

    return anObject;
}

/*
 * Empties the List of all its objects without freeing them, and returns self.
 * The current capacity of the List isn't changed.
 */
- empty
{
    n_elements = 0;
    return self;
}

/*
 * Sends an aSelector message to each object in the List in reverse order
 * (starting with the last object and continuing backwards through the List to
 * the first object), and returns self.  The aSelector method must be one that
 * takes no arguments.  It shouldn't have the side effect of modifying the
 * List.
 */
- makeObjectsPerform: (SEL)aSelector
{
    int index = [self count];

    if (index == 0)
	return self;

    --index;
    do {
	[[self objectAt: index] perform: aSelector];
    } while (index--);

    return self;
}

/*
 * Sends an aSelector message to each object in the List in reverse order
 * (starting with the last object and continuing backwards through the List to
 * the first object), and returns self.  The message is sent each time with
 * anObject as an argument, so the aSelector method must be one that takes a
 * single argument of type id.  The aSelector method shouldn't, as a side
 * effect, modify the List.
 */
- makeObjectsPerform: (SEL)aSelector with: anObject
{
    int index = [self count];

    if (index == 0)
	return self;

    --index;
    do {
	[[self objectAt: index] perform: aSelector with: anObject];
    } while (index--);

    return self;
}

#if 0

/*
 * Reads the List and all the objects it contains from the typed stream stream.
 */
- read: (NXTypedStream *)stream
{
}

/*
 * Writes the List, including all the objects it contains, to the typed stream
 * stream.
 */
- write:(NXTypedStream *)stream
{
}

/*
 * Returns a new List object with the same contents as the receiver.  The
 * objects in the List aren't copied; therefore, both Lists contain pointers
 * to the same set of objects.  Memory for the new List is allocated from zone.
 */
- copyFromZone:(NXZone *)zone
{
}

#endif

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
