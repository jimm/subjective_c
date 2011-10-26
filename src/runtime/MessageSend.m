#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Object.h"

/* #define WARN_IF_NIL_RECEIVER	1 */
/* #define WARN_IF_NIL_SELECTOR	1 */
#define WARN_IF_NOT_FOUND		1

struct super_context _gSuperContext; // Global

static SEL forward = @selector(doesNotImplement:);

static IMP _lookupFunc(Class class, SEL selector);
static void initializeClass(Class class);
static void nop(void);

#if SEND_WITHOUT_JUMP
IMP
_msgSend(id receiver, SEL selector)
#else
id
_msgSend(id receiver, SEL selector, ...)
#endif
{
	IMP func_ptr;
	Class receiverClass;

	if (receiver == nil) {
#if WARN_IF_NIL_RECEIVER
		fprintf(stderr, "subjc: selector \"%s\" was sent to a nil object.\n",
				(char *)selector);
#endif
		return (IMP)nop;		// A safe method for the object to execute
	}
	receiverClass = ((Object *)receiver)->isa;
	if (selector == nil) {
#if WARN_IF_NIL_SELECTOR
		fprintf(stderr,
				"subjc: a nil selector was sent to an object of class \"%s\".\n",
				receiverClass->name);
#endif
		return (IMP)nop;
	}

	// Initialize uninitialized Class objects
	if (receiverClass->isa == Nil) {
		if (!((Class)receiver)->isInitialized)
			initializeClass((Class)receiver);
	}
	else {
		if (!receiverClass->isInitialized)
			initializeClass(receiverClass);
	}

	// Find the method
	func_ptr = _lookupFunc(receiverClass, selector);
	if (func_ptr == NULL && strcmp(selector, (char *)forward) != 0)
		func_ptr = _lookupFunc(receiverClass, forward);

	if (func_ptr == NULL) {
#if WARN_IF_NOT_FOUND
		fprintf(stderr,
				"subjc: cannot find method \"%s\" for object of class \"%s\".\n",
				(char *)selector, receiverClass->name);
#endif
		return (IMP)nop;
	}

#if SEND_WITHOUT_JUMP
	return func_ptr;
#else
	return (*func_ptr)();
#endif
}

#if SEND_WITHOUT_JUMP
IMP
_msgSuper(struct super_context *context, SEL selector)
#else
id
_msgSuper(struct super_context *context, SEL selector, ...)
#endif
{
	IMP func_ptr;
	Class receiverClass;

	if (context == nil || context->receiver == nil) {
#if WARN_IF_NIL_RECEIVER
		// A slightly deceiving error message, I admit.
		fprintf(stderr, "subjc: selector \"%s\" was sent to a nil superclass.\n",
				(char *)selector);
#endif
		return (IMP)nop;
	}
	receiverClass = ((Object *)context->receiver)->isa;
	if (selector == nil) {
#if WARN_IF_NIL_SELECTOR
		fprintf(stderr,
				"subjc: a nil selector was sent to an object of class \"%s\".\n",
				receiverClass->name);
#endif
		return (IMP)nop;
	}

	// Initialize uninitialized Class objects
	if (receiverClass->isa == Nil) {
		if (!((Class)context->receiver)->isInitialized)
			initializeClass((Class)context->receiver);
	}
	else {
		if (!receiverClass->isInitialized)
			initializeClass(receiverClass);
	}

	// Find the method
	func_ptr = _lookupFunc(context->class, selector);
	if (func_ptr == NULL && strcmp(selector, (char *)forward) != 0)
		func_ptr = _lookupFunc(receiverClass, forward);

	if (func_ptr == NULL) {
#if WARN_IF_NOT_FOUND
		fprintf(stderr,
				"subjc: cannot find method \"%s\" for object of class \"%s\".\n",
				(char *)selector, receiverClass->name);
		return (IMP)nop;
#endif
	}

#if SEND_WITHOUT_JUMP
	return func_ptr;
#else
	return (*func_ptr)();
#endif
}

static
IMP
_lookupFunc(Class class, SEL selector)
{
	int i;
	int n_methods;

	if (class == Nil)
		return NULL;

	for (; class != Nil; class = class->superclass) {
		// First, try looking in the cache
		for (i = 0; i < _SUBJC_CACHE_SIZE && class->cache.methodCache[i].name; ++i) {
			if (class->cache.methodCache[i].name == selector)
				return (IMP)class->cache.methodCache[i].func_ptr;
		}
		// Not found in the cache. Try looking the hard way.
		n_methods = class->methods.count;
		for (i = 0; i < n_methods; ++i) {
			if (strcmp(class->methods.list[i].name, (char *)selector) == 0) {
				// Add to the cache
				class->cache.methodCache[class->cache.nextSlot].name = selector;
				class->cache.methodCache[class->cache.nextSlot].func_ptr =
					class->methods.list[i].func_ptr;
				if (++class->cache.nextSlot >= _SUBJC_CACHE_SIZE)
					class->cache.nextSlot = 0;
				// Return what we found
				return (IMP)class->methods.list[i].func_ptr;
			}
		}
	}
	return NULL;
}

// This routine doesn't work yet. We have no list of all classes.
Class
subjc_lookUpClass(const char *className)
{
	if (className == NULL)
		return nil;

	return nil;
}

// Return the SEL associated with a method name
SEL
sel_getUID(const char *selectorName)
{
	return (SEL)selectorName;
}

// Return the method name associated with a selector
const char *
sel_getName(SEL selector)
{
	return (const char *)selector;
}

// Initialize a class'es cache and call +initialize (if it's not a metaclass).
static void
initializeClass(Class class)
{
	int i;
	Class metaclass;

	class->isInitialized = 1;
	/*
	 * NOTE: MUST set before we call "[class initialize]" below, since if
	 * we don't, this code will get executed again and again and...
	 */
	for (i = 0; i < _SUBJC_CACHE_SIZE; ++i) { /* Initialize the cache */
		class->cache.nextSlot = 0;
		class->cache.methodCache[i].name = NULL;
		class->cache.methodCache[i].func_ptr = NULL;
	}

	// Call +initialize the first time we see this class
	metaclass = class->isa;
	if (metaclass != Nil) {	// Don't do this for metaclasses!
		metaclass->isInitialized = 1;
		for (i = 0; i < _SUBJC_CACHE_SIZE; ++i) { /* Initialize the cache */
			metaclass->cache.nextSlot = 0;
			metaclass->cache.methodCache[i].name = NULL;
			metaclass->cache.methodCache[i].func_ptr = NULL;
		}
		[class initialize];
	}
}

static void nop(void)
{
}

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/
