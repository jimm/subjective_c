#include <stdio.h>
#include <stdlib.h>
#include "Object.h"

@interface Foo : Object
{
	int x;
}

- init;
- printMe;

@end

@implementation Foo
- init
{
	[super init];
	x = 42;
	return self;
}

- printMe
{
	printf("An object of class Foo, x = %d\n", x);
	return self;
}
@end

@interface Bar : Foo
{
	int y;
}

- init;
- printMe;
+initialize;

@end

@implementation Bar

static int barClassVar = 0;

- init
{
	[super init];
	y = 17;
	return self;
}

- printMe
{
	printf("An object of class Bar, (x, y) = (%d, %d)\n", x, y);
	printf("Bar class variable = %d (such an evil number)!\n", barClassVar);
	return self;
}

+ initialize
{
	[super initialize];
	barClassVar = 666;
	return self;
}
@end

int
main()
{
	Object *o;
	id fooObj, barObj;

	o = [Object alloc];

	printf("After alloc, o = %p\n", o);
	printf("o->class = %p\n", o->isa);
	fflush(stdout);

	printf("o's name is %s\n", [o name]);
	fflush(stdout);

	[o init];

	printf("After init, o = %p\n", o);
	fflush(stdout);

	if ([o respondsTo: @selector(dummy)])
		puts("o responds to dummy!");
	else
		puts("o doesn't respond to dummy");
	fflush(stdout);

	if ([o respondsTo: @selector(free)])
		puts("o responds to free");
	else
		puts("o doesn't respond to free!");
	fflush(stdout);

	printf("class name = %s\n", ((Class)[o class])->name);
	fflush(stdout);

	puts("Going to try to send message \"dummy\" to o.");
	fflush(stdout);
	[o dummy];

	[o free];

	puts("Going to try sending a message to a nil object.");
	fflush(stdout);
	[nil sentThisToNil];

	fooObj = [[Foo alloc] init];
	[fooObj printMe];
	[fooObj free];

	barObj = [[Bar alloc] init];
	[barObj printMe];
	[barObj free];

	exit(0);
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
