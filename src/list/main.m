#include <stdio.h>
#include <stdlib.h>
#include "List.h"
#include "String.h"
#include "Stream.h"

static void TestList();
static void print_list(id list);
static void TestListAndString();
static void PrintList();
static void TestStream();

char *table[] =
{
	"Line 1",
	"Another line",
	"Doomed to be deleted",
	"Last line",
	NULL
};

int main(int argc, char *argv[])
{
	TestList();
	TestListAndString();
	if (argc > 1)
		TestStream(argv[1]);
	exit(0);
}

static
void
TestList()
{
	int i;
	id list, list2;

	list = [[List alloc] init];
	if (list == nil)
	{
		puts("error: [[List alloc] init] returned nil");
		exit(1);
	}

	for (i = 0; table[i] != nil; ++i)
		[list addObject: (id)table[i]];
	print_list(list);

	[list removeObjectAt: 2];
	putchar('\n');
	print_list(list);

	printf("\nIndex of \"Last line\" is %d\n",
		   [list indexOf: (id)"Last line"]);

	printf("Number of elements in list is %d\n", [list count]);

	list2 = [[List alloc] init];
	for (i = 0; table[i] != nil; ++i)
		[list2 addObject: (id)table[i]];

	[list appendList: list2];
	puts("\nCreated another list, and appended it to first one. Here it is:");
	print_list(list);

	[list replaceObject: (id)"Another line" with: (id)"-- replacement --"];
	puts("\nReplaced first \"Another line\". Here it is:");
	print_list(list);

	[list2 free];
	[list free];
}

void
print_list(id list)
{
	int i;

	putchar('\n');
	for (i = 0; i < [list count]; ++i)
		puts((char *)[list objectAt: i]);
}

void
TestListAndString()
{
	id list;
	
	list = [[List alloc] init];
	
	[list addObject: [[String alloc] initFromChars: "Hi there!"]];
	[list addObject: [[String alloc] initFromChars: "The second line"]];
	[list addObject: [[String alloc] initFromChars: "The third line"]];
	PrintList(list);
	
	[list removeObjectAt: 1];
	PrintList(list);
	
	[list makeObjectsPerform: @selector(setChars:) with: (id)"MORE"];
	PrintList(list);
	
	/* Note: don't do freeObjects, since strings are static memory */
	[list free];
}

void
PrintList(list)
	id list;
{
	int i;
	
	puts("List: ====");
	for (i = 0; i < [list count]; ++i)
		puts([[list objectAt: i] chars]);
	puts("==== done");
}

void
TestStream(fname)
	char *fname;
{
	int c;
	id stream;
	
	stream = [[Stream alloc] initFromFile: fname mode: STREAM_READWRITE];
	
	if (stream == nil) {
		fprintf(stderr, "Error initializing stream\n");
		exit(1);
	}
	
	putchar('\n');
	while ((c = [stream getc]) != EOF)
		putchar(c);
	
	[stream puts: "Mary had a little lamb...\n"];
	[stream puts: "  and boy, was the Doctor surprised!\n"];
	[stream flush];
	[stream free];
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
