#ifndef _clist_h_
#define _clist_h_

#define NOT_IN_LIST (-1)

typedef void (*VFPTR)();		/* Pointer to function returning void */

typedef struct list
{
	void **data;				/* Array of void pointers */
	int n_elements;				/* Number of elements */
	int n_allocated;			/* Number allocated */
} LIST;

LIST * ListNew(void);
void ListFree(LIST *self);

/* Creating, freeing */
  
void ListFreeObjects(LIST *self);
void ListFreeArrayObjects(LIST *self);
  
/* Comparing two lists */
  
int ListIsEqual(const LIST *self, const LIST *list2);
  
/* Managing the storage capacity */
  
#define ListCapacity(l) ((l) ? (l)->n_allocated : 0)
void ListSetAvailableCapacity(LIST *self, const int numSlots);
  
/* Manipulating objects by index */
  
#define ListCount(l) ((l) ? (l)->n_elements : 0)
void *ListObjectAt(const LIST *self, const int index);
void *ListLastObject(const LIST *self);
void ListAddObject(LIST *self, void *anObject);
void ListInsertObjectAt(LIST *self, void *anObject, int index);
void *ListRemoveObjectAt(LIST *self, int index);
void *ListRemoveLastObject(LIST *self);
void *ListReplaceObjectAtWith(LIST *self, int index, void *newObject);
void ListAppendList(LIST *self, const LIST *otherList);
  
/* Manipulating objects by id */
  
int ListIndexOf(const LIST *self, const void *anObject);
void ListAddObjectIfAbsent(LIST *self, void *anObject);
void *ListRemoveObject(LIST *self, void *anObject);
void *ListReplaceObjectWith(LIST *self, void *anObject, void *newObject);
  
/* Emptying the LIST */
  
#define ListEmpty(l) {if (l) (l)->n_elements = 0;}
  
/* Sending messages to elements of the LIST */
  
void ListMakeObjectsPerform(LIST *self, VFPTR aSelector);
void ListMakeObjectsPerformWith(LIST *self, VFPTR aSelector, void *anObject);

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _clist_h_ */
