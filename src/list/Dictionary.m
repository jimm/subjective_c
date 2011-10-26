#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "List.h"
#include "Dictionary.h"

#define INITIAL_SIZE	4

@implementation Dictionary

- init
{
    [super init];
    keyList = [[List alloc] init];
    valueList = [[List alloc] init];

    return self;
}

- initCount: (int)numSlots
{
    [super init];
    keyList = [[List alloc] initCount: numSlots];
    valueList = [[List alloc] initCount: numSlots];

    return self;
}

- free
{
    int i, count = [keyList count];

    for (i = 0; i < count; ++i)
	free([keyList objectAt: i]);
    [keyList free];
    [valueList free];

    return [super free];
}

- freeObjects
{
    int i, count = [keyList count];

    for (i = 0; i < count; ++i)
	free([keyList objectAt: i]);
    [valueList freeObjects];

    return self;
}

- (BOOL)isEqual: anObject
{
    int index, count = [self count];
    id otherKeyList, otherValueList;

    if (anObject == nil || ![anObject isKindOf: DictionaryClass] ||
	count != [anObject count])
	return NO;

    otherKeyList = [anObject keys];
    otherValueList = [anObject values];
    for (index = 0; index < count; ++index) {
	if (strcmp([keyList objectAt: index],
		   [otherKeyList objectAt: index]) != 0
	    || [valueList objectAt: index] != [otherValueList objectAt: index])
	    return NO;
    }
    return YES;
}

/*
 * Returns the number of objects currently in the Dictionary.
 */
- (int)count
{
    return [keyList count];
}

/*
 * Returns the id of the object located at slot index, or nil if index is
 * beyond the end of the Dictionary.
 */
- at: (const char *)key
{
    int i, count = [self count];

    for (i = 0; i < count; ++i) {
	if (strcmp([keyList objectAt: i], key) == 0) {
	    return [valueList objectAt: i];
	}
    }
    return nil;
}

- at: (const char *)key put: (const char *)value
{
    int i, count = [keyList count];
    char *keyText;

    for (i = 0; i < count; ++i) {
	if (strcmp([keyList objectAt: i], key) == 0) {
	    [valueList replaceObjectAt: i with: value];
	    return self;
	}
    }

    keyText = malloc(strlen(key) + 1);
    strcpy(keyText, key);
    [keyList addObject: keyText];
    [valueList addObject: valueList];

    return self;
}

- keys
{
    return keyList;
}

- values
{
    return valueList;
}

- empty
{
    [keyList empty];
    [valueList empty];
    return self;
}

- makeObjectsPerform: (SEL)aSelector
{
    [valueList makeObjectsPerform: aSelector];
    return self;
}

- makeObjectsPerform: (SEL)aSelector with: anObject
{
    [valueList makeObjectsPerform: aSelector with: anObject];
    return self;
}

#if 0

/*
 * Reads the Dictionary and all the objects it contains from the typed stream stream.
 */
- read: (NXTypedStream *)stream
{
}

/*
 * Writes the Dictionary, including all the objects it contains, to the typed stream
 * stream.
 */
- write:(NXTypedStream *)stream
{
}

/*
 * Returns a new Dictionary object with the same contents as the receiver.  The
 * objects in the Dictionary aren't copied; therefore, both Dictionarys contain pointers
 * to the same set of objects.  Memory for the new Dictionary is allocated from zone.
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
