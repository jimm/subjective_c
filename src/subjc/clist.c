#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "clist.h"

#define INITIAL_SIZE 4

/*
 * Creates a new list, initializes it, and returns a pointer to it.
 */
LIST *
ListNew()
{
	register LIST *self = malloc(sizeof(LIST));

	if (self == NULL)
		return NULL;

	self->data = NULL;
	self->n_elements = self->n_allocated = 0;

	return self;
}

/*
 * Deallocates the List object and the memory it allocated for the array of
 * void pointers.  However, the objects themselves aren't freed.
 */
void
ListFree(register LIST *self)
{
	if (!self)
		return;

	if (self->data)
	{
		free(self->data);
		self->data = NULL;
	}
	free(self);
}

/*
 * Removes every object from the List and calls (free) on each one.
 * The List object itself isn't freed and its current capacity isn't altered.
 *
 * The methods that free the objects shouldn't have the side effect of
 * modifying the List.
 */
void
ListFreeObjects(register LIST *self)
{
	int index;

	if (!self)
		return;

	for (index = 0; index < self->n_elements; ++index)
		free(self->data[index]);
	self->n_elements = 0;
}

void
ListFreeArrayObjects(register LIST *self)
{
	int index;

	if (!self)
		return;

	for (index = 0; index < self->n_elements; ++index)
		free(self->data[index]);
	self->n_elements = 0;
}

/*
 * Compares the receiving List to anObject.  If anObject is a List with exactly
 * the same contents as the receiver, this method returns 1.  If not, it
 * returns 0.
 *
 * Two Lists have the same contents if they each hold the same number of
 * objects and the void pointers in each List are identical and occur in the
 * same order.
 *
 */
int
ListIsEqual(register const LIST *self, register const LIST *anObject)
{
	int index;

	if (!self || !anObject || self->n_elements != ListCount(anObject))
		return 0;

	for (index = 0; index < self->n_elements; ++index)
		if (self->data[index] != anObject->data[index])
			return 0;

	return 1;
}

/*
 * Inserts anObject at the end of the List.  However, if anObject is NULL,
 * nothing is inserted.
 */
void
ListAddObject(register LIST *self, void *anObject)
{
	if (!self || !anObject)
		return;

	if (self->n_elements >= self->n_allocated)
		ListSetAvailableCapacity(self, self->n_allocated * 2);
	self->data[self->n_elements++] = anObject;
}

/*
 * Sets the storage capacity of the List to at least numSlots objects.
 * However, if the List already contains more than numSlots objects
 * (if the count method returns a number greater than numSlots), its
 * capacity is left unchanged.
 */
void
ListSetAvailableCapacity(register LIST *self, const int numSlots)
{
	int newNAlloc;
	void **newData;

	if (!self || self->n_allocated > numSlots)
		return;

	newNAlloc = (self->n_allocated == 0) ? INITIAL_SIZE : self->n_allocated;

	while (newNAlloc < numSlots)
		newNAlloc *= 2;

	newData = malloc(newNAlloc * sizeof(void *));

	if (self->data != 0) {
		if (self->n_allocated)
			memcpy(newData, self->data, self->n_allocated * sizeof(void *));
		free(self->data);
	}

	self->data = newData;
	self->n_allocated = newNAlloc;
}

/*
 * Returns the void * located at slot index, or NULL if index is
 * beyond the end of the List.
 */
void *
ListObjectAt(register const LIST *self, const int index)
{
	if (!self || index >= self->n_elements)
		return NULL;

	return self->data[index];
}

/*
 * Returns the last object in the List, or NULL if there are no objects in the
 * List.  This method doesn't remove the object that's returned.
 */
void *
ListLastObject(register const LIST *self)
{
	if (self && self->n_elements > 0)
		return self->data[self->n_elements - 1];
	else
		return NULL;
}

/*
 * Inserts anObject into the List at index, moving objects down one slot to
 * make room.  If index equals the value returned by ListCount(), anObject
 * is inserted at the end of the List.  However, the insertion fails if index
 * is greater than the value returned by ListCount() or anObject is NULL.
 */
void
ListInsertObjectAt(register LIST *self, void *anObject, int index)
{
	int i;

	if (!self || !anObject || index > self->n_elements)
		return;

	if (index == self->n_elements)
	{
		ListAddObject(self, anObject);
		return;
	}

	for (i = self->n_elements; i > index; --i)
		self->data[i] = self->data[i - 1];
	++self->n_elements;
	self->data[index] = anObject;
}

/*
 * Removes the object located at index and returns it.  If there's no object at
 * index, this method returns NULL.
 *
 * The positions of the remaining objects in the List are adjusted so there's
 * no gap.
 */
void *
ListRemoveObjectAt(register LIST *self, int index)
{
	void *obj;

	if (!self || self->n_elements == 0 || index >= self->n_elements)
		return NULL;

	obj = self->data[index];
	for (--self->n_elements; index < self->n_elements; ++index)
		self->data[index] = self->data[index + 1];

	return obj;
}

/*
 * Removes the object occupying the last position in the List and returns it.
 * If there are no objects in the List, this method returns NULL.
 */
void *
ListRemoveLastObject(register LIST *self)
{
	void *obj;

	if (!self || self->n_elements == 0)
		return NULL;

	obj = self->data[--self->n_elements];
	return obj;
}

/*
 * Returns the object at index after replacing it with newObject.  If there's
 * no object at index or newObject is NULL, nothing is replaced and NULL is
 * returned.
 */
void *
ListReplaceObjectAtWith(register LIST *self, int index, void *newObject)
{
	void *obj;

	if (!self || !newObject || index >= self->n_elements)
		return NULL;

	obj = self->data[index];
	self->data[index] = newObject;
	return obj;
}

/*
 * Inserts all the objects in otherList at the end of the receiving List.
 * The ordering of the objects is maintained.
 */
void
ListAppendList(register LIST *self, const LIST *otherList)
{
	int index, count;

	if (!self || !otherList)
		return;

	/* Pre-fetch count so if self == otherList we're not looping forever! */
	count = ListCount(otherList);
	for (index = 0; index < count; ++index)
		ListAddObject(self, ListObjectAt(otherList, index));
}

/*
 * Returns the index of the first occurrence of anObject in the List, or
 * NOT_IN_LIST if anObject isn't in the List.
 */
int
ListIndexOf(register const LIST *self, register const void *anObject)
{
	int index;

	if (!self || !anObject)
		return NOT_IN_LIST;

	for (index = 0; index < self->n_elements; ++index)
		if (self->data[index] == anObject)
			return index;

	return NOT_IN_LIST;
}

/*
 * Inserts anObject at the end of the List, provided that anObject isn't
 * already in the List.  If anObject is in the List, it won't be inserted.
 *
 * If anObject is NULL, nothing is inserted.
 */
void
ListAddObjectIfAbsent(register LIST *self, void *anObject)
{
	if (!self || !anObject)
		return;

	if (ListIndexOf(self, anObject) == NOT_IN_LIST)
	{
		if (self->n_elements >= self->n_allocated)
			ListSetAvailableCapacity(self, self->n_allocated * 2);
		self->data[self->n_elements++] = anObject;
	}
}

/*
 * Removes the first occurrence of anObject from the List, and returns it.  If
 * anObject isn't in the List, this method returns NULL.
 *
 * The positions of the remaining objects in the List are adjusted so there's
 * no gap.
 */
void *
ListRemoveObject(register LIST *self, void *anObject)
{
	int index;

	if (!self || (index = ListIndexOf(self, anObject)) == NOT_IN_LIST)
		return NULL;

	return ListRemoveObjectAt(self, index);
}

/*
 * Replaces the first occurrence of anObject in the List with newObject, and
 * returns anObject.  However, if newObject is NULL or anObject isn't in the
 * List, nothing is replaced and NULL is returned.
 */
void *
ListReplaceObjectWith(register LIST *self, void *anObject,
					  void *newObject)
{
	int index;

	if (!self || !newObject ||
		(index = ListIndexOf(self, anObject)) == NOT_IN_LIST)
		return NULL;

	self->data[index] = newObject;

	return anObject;
}

/*
 * Calls the aSelector function on each object in the List in reverse order
 * (starting with the last object and continuing backwards through the List to
 * the first object). The aSelector function must be one that takes no
 * arguments. It shouldn't have the side effect of modifying the List.
 */
void
ListMakeObjectsPerform(register LIST *self, VFPTR aSelector)
{
	int index;

	if (!self || !aSelector || (index = ListCount(self)) == 0)
		return;

	--index;
	do {
		(*(void (*)(void *))aSelector)(ListObjectAt(self, index));
	} while (index--);
}

/*
 * Calls the aSelector function on each object in the List in reverse order
 * (starting with the last object and continuing backwards through the List to
 * the first object). The aSelector function is called each time with anObject
 * as an argument, so the aSelector function must be one that takes a single
 * argument of type void *. The aSelector function shouldn't, as a side
 * effect, modify the List.
 */
void
ListMakeObjectsPerformWith(register LIST *self, VFPTR aSelector,
						   void *anObject)
{
	int index;

	if (!self || !aSelector || (index = ListCount(self)) == 0)
		return;

	--index;
	do {
		(*(void (*)(void *, void *))aSelector)(ListObjectAt(self, index),
													   anObject);
	} while (index--);
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
