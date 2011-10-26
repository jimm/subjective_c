#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "String.h"

@implementation String

- initFromChars: (char *)chars
{
	[super init];
	return [self setChars: chars];
}

- free
{
	if (data != NULL)
		free(data);
	return [super free];
}

- (int) len
{
	return len;
}

- (char *) chars
{
	return data;
}

- cat: (char *)chars
{
	len += strlen(chars);
	if (data == NULL)
		data = malloc(len + 1);
	else
		data = realloc(data, len + 1);
	if (data == NULL)
		[self error: "Out of memory"];
	strcat(data, chars);
	return self;
}

- setChars: (char *)chars
{
	len = strlen(chars);

	if (data == NULL)
		data = malloc(len + 1);
	else
		data = realloc(data, len + 1);
	if (data == NULL)
		[self error: "Out of memory"];
	strcpy(data, chars);
	return self;
}

- (int)compareWith: anObject
{
	if (![anObject isKindOf: StringClass])
		return -1;

	return strcmp(data, ((String *)anObject)->data);
}

- copyTo: anObject
{
	if (![anObject isKindOf: StringClass])
		return nil;

	[anObject setChars: data];

	return self;
}

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
