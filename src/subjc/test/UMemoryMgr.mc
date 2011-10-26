// ===========================================================================
//	UMemoryMgr.cp					©1993 Metrowerks Inc. All rights reserved.
// ===========================================================================
//
//	Memory management utility classes and functions
//
//	Stack-based Classes:
//		Several utility classes are designed for creating stack-based
//		objects, where the Constructor performs some action and the
//		Destructor undoes the action. The advantage of stack-based
//		objects is that the Destructor automatically gets called,
//		even when there is an exception thrown.

#ifdef PowerPlant_PCH
#include PowerPlant_PCH
#endif


#include <PP_Types.h>

#ifndef _Object_h_
#define _Object_h_


#ifndef _Object_impl_h_
#define _Object_impl_h_

#define Nil ((Class)0)
#undef nil
#define nil ((id)0)

#define NO  ((BOOL)0)
#define YES ((BOOL)1)

typedef char BOOL;
typedef void *id;
typedef char *SEL;
typedef id (*IMP)();

struct super_context
{
    id receiver;
    struct _Class *class;
};

extern struct super_context _gSuperContext;

extern IMP _msgSend(id receiver, SEL selector, ...);
extern IMP _msgSuper(struct super_context *context, SEL selector, ...);

#endif /* _Object_impl_h_ */

#ifndef _Class_h_
#define _Class_h_

#include <stdio.h>

typedef struct _Method {
    char *name;
    void (*func_ptr)();
} *Method;

typedef struct _MethodList {
    int count;
    struct _Method *list;
} MethodList;

typedef struct _Class {
    struct _Class *isa;
    struct _Class *superclass;
    size_t objectSize;
    char *name;
    MethodList methods;
} *Class;

#endif /* _Class_h_ */

@interface Object
{
    struct _Class *isa;
}

+ alloc;
+ new;
- free;

- init;

- class;
- superclass;

- (BOOL)isKindOf: aClassObject;
- (BOOL)isMemberOf: aClassObject;
- (BOOL)isKindOfClassNamed: (char *)aClassName;
- (BOOL)isMemberOfClassNamed: (char *)aClassName;

+ (BOOL)instancesRespondTo: (SEL)aSelector;
- (BOOL)respondsTo: (SEL)aSelector;

- perform: (SEL)aSelector;
- perform: (SEL)aSelector with: anObject;
- perform: (SEL)aSelector with: object1 with: object2;

- doesNotImplement;
- subclassResponsibility;
- error: (char *)s;

@end

#endif /* _Object_h_ */

#ifndef __MEMORY__
#include <Memory.h>
#endif


// ---------------------------------------------------------------------------
@interface StHandleLocker : Object
{
	Handle mHandle;
	char mSaveState;
}

- init: (Handle)inHandle;
- free;

- (Handle) handle;

@end

// ---------------------------------------------------------------------------
@interface StHandleBlock : Object
{
	Handle mHandle;
}

- init: (Size)inSize;
- init: (Size)inSize : (BOOL)inThrowFail;
- free;

- (Handle) handle;

@end

// ---------------------------------------------------------------------------
@interface StTempHandle : Object
{
	Handle mHandle;
}

- init: (Size)inSize;
- init: (Size)inSize : (BOOL)inThrowFail;
- free;

- (Handle) handle;

@end

// ---------------------------------------------------------------------------
@interface StPointerBlock : Object
{
	Ptr mPtr;
}

- init: (Size)inSize;
- init: (Size)inSize : (BOOL)inThrowFail;
- free;

- (Ptr) pointer;

@end

// ---------------------------------------------------------------------------
@interface StResource : Object
{
	Handle mResourceH;
}

- init: (ResType)inResType : (ResIDT)inResID;
- init: (ResType)inResType : (ResIDT)inResID : (BOOL)inThrowFail;
- free;

- (Handle) handle;

@end

// ---------------------------------------------------------------------------

void InitializeHeap(Int16 inMoreMasters);
BOOL BlocksAreEqual(const void *s1, const void *s2, Uint32 n);

#ifndef __RESOURCES__
#include <Resources.h>
#endif

#ifndef __ERRORS__
#include <Errors.h>
#endif


// ===========================================================================
//	¥ StHandleLocker Class
// ===========================================================================
//	Constructor Locks the Handle
//	Destructor restores the Handle's original state

@implementation StHandleLocker

- init: (Handle)inHandle
{
	[super init];
	mHandle = inHandle;
	mSaveState = HGetState(inHandle);
	HLock(inHandle);
	return self;
}

- free
{
	HSetState(mHandle, mSaveState);
	return [super free];
}

- (Handle) handle
{
	return mHandle;
}

@end

// ===========================================================================
//	¥ StHandleBlock Class
// ===========================================================================
//	Constructor allocates the Handle
//	Destructor disposes of the Handle

@implementation StHandleBlock

- init: (Size)inSize
{
	return [self init: inSize : YES];
}

- init: (Size)inSize : (BOOL)inThrowFail
{
	[super init];
	mHandle = NewHandle(inSize);
#if 0
	if (inThrowFail)
		ThrowIfMemFail_(mHandle);
#endif
	return self;
}

- free
{
	if (mHandle != nil)
		DisposeHandle(mHandle);
	return [super free];
}

- (Handle) handle
{
	return mHandle;
}

@end

// ===========================================================================
//	¥ StTempHandle Class
// ===========================================================================
//	Constructor allocates the Handle  using temporary (System) memory
//	Destructor disposes of the Handle

@implementation StTempHandle

- init: (Size)inSize
{
	return [self init: inSize : YES];
}

- init: (Size)inSize : (BOOL)inThrowFail
{
	OSErr err;

	[super init];
	mHandle = TempNewHandle(inSize, &err);
#if 0
	if (inThrowFail && (mHandle == nil))
		ThrowOSErr_(err);
#endif
	return self;
}

- free
{
	if (mHandle != nil)
		DisposeHandle(mHandle);
	return [super free];
}

- (Handle) handle
{
	return mHandle;
}

@end

// ===========================================================================
//	¥ StPointerBlock Class
// ===========================================================================
//	Constructor allocates the Ptr
//	Destructor disposes of the Ptr

@implementation StPointerBlock

- init: (Size)inSize
{
	return [self init: inSize : YES];
}

- init: (Size)inSize : (BOOL)inThrowFail
{
	[super init];
	mPtr = NewPtr(inSize);
#if 0
	if (inThrowFail)
		ThrowIfMemFail_(mPtr);
#endif
	return self;
}


- free
{
	if (mPtr != nil)
		DisposePtr(mPtr);
	return [super free];
}

- (Ptr) pointer
{
	return mPtr;
}

@end

// ===========================================================================
//	¥ StResource Class
// ===========================================================================
//	Constructor gets the resource handle
//	Destructor releases the resource handle

@implementation StResource

- init: (ResType)inResType : (ResIDT)inResID
{
	return [self init: inResType : inResID : YES];
}

- init: (ResType)inResType : (ResIDT)inResID : (BOOL)inThrowFail
{
	[super init];
	mResourceH = GetResource(inResType, inResID);
#if 0
	if (inThrowFail)
		ThrowIfResFail_(mResourceH);
#endif
	return self;
}

- free
{
	if (mResourceH != nil)
		ReleaseResource(mResourceH);
	return [super free];
}

- (Handle) handle
{
	return mResourceH;
}

@end

// ===========================================================================
//	¥ Utility Functions
// ===========================================================================

// ---------------------------------------------------------------------------
//		¥ InitializeHeap
// ---------------------------------------------------------------------------
//	Call this function at the beginning of your program (before initializing
//	the Toolbox) to expand the heap zone to its maximum size and preallocate
//	a specified number of Master Pointer blocks.

void InitializeHeap(Int16 inMoreMasters)
{
	Int16 i;

	MaxApplZone();
	for (i = 1; i <= inMoreMasters; i++)
		MoreMasters();
}


// ---------------------------------------------------------------------------
//		¥ BlocksAreEqual
// ---------------------------------------------------------------------------
//	Blocks are equal if the first n bytes pointed to by s1 have the same
//	values as the first n bytes pointed to by s2. Note that this always
//	returns true if n is zero.

BOOL BlocksAreEqual(const void *s1, const void *s2, Uint32 n)
{
	const unsigned char	*ucp1 = (const unsigned char *) s1;
	const unsigned char	*ucp2 = (const unsigned char *) s2;
	
	while (n > 0) {
		if (*ucp1++ != *ucp2++)
			return NO;
		n--;
	}
	
	return YES;
}
