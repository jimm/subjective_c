#ifndef _String_h_
#define _String_h_

#include <subjc/Object.h>

@interface String : Object {
	char *data;
	int len;
}

- initFromChars: (char *)chars;

- free;

- (int)len;

- (char *) chars;
- setChars: (char *)chars;

- cat: (char *)chars;
- (int)compareWith: anObject;
- copyTo: anObject;

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif // _String_h_
