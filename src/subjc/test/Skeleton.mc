#include <stdio.h>
#include <string.h>

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
#include <PP_Messages.h>


// Resource IDs

#define StopIconID	0				// Stop sign icon

#define rBundle		128				// Application bundle
#define rSignature	0				// Signature resource

enum {
	rRefAPPL = 128,					// APPL file reference
	rRefTEXT						// TEXT file reference
};

enum {
	rIconAPPL = 128,
	rIconTEXT
};

enum {
	rAboutBox = 128,
	rNotSystem7
};

#define rHelpString	128

// Menu and menu item IDs
// Note: we use menu resource IDs that are the same as Menu IDs

#define rMenuBar	128

enum {
	MENU_Apple = 128,
	MENU_File,
	MENU_Edit
};

enum {								// Apple menu items
	iAbout = 1
};

enum {								// File menu items
	iNew = 1,
	iOpen,
	iClose = 4,
	iSave,
	iSaveAs,
	iPrintSetup = 8,
	iPrint,
	iQuit = 11
};

enum {								// Edit menu items
	iUndo = 1,
	iCut = 3,
	iCopy,
	iPaste,
	iClear
};

#define kMinSize	23				// Min partition size (in K)
#define kMaxSize	35				// Preferred partition size (in K)

#define AppName			"Skeleton"
#define AppVers			"1.0"
#define CopyrightNotice	"© 1991 Garry Little"
#define ApplCreator		'SKel'		// Application signature

enum {
	rRefsEXT = rRefTEXT + 1			// sEXT file reference
};

enum {
	rIconsEXT = rIconTEXT + 1
};

enum {
	rMainWindow = 128,
	rDebugWindow
};

#define rHelpString	128

// Menu and menu item IDs
// Note: we use menu resource IDs that are the same as Menu IDs

#define rMenuBar	128

enum {
	MENU_Special = MENU_Edit + 1
};

enum {								// Special menu items
	iTest = 1
};

#define kMinSize	23				// Min partition size (in K)
#define kMaxSize	35				// Preferred partition size (in K)

// Use these to set the enable/disable flags of a menu:
#define kMenuAllItems	0x7fff
#define kMenuNoItems	0x0000
#define kMenuItem1		(1 << 0)
#define kMenuItem2		(1 << 1)
#define kMenuItem3		(1 << 2)
#define kMenuItem4		(1 << 3)
#define kMenuItem5		(1 << 4)
#define kMenuItem6		(1 << 5)
#define kMenuItem7		(1 << 6)
#define kMenuItem8		(1 << 7)
#define kMenuItem9		(1 << 8)
#define kMenuItem10		(1 << 9)
#define kMenuItem11		(1 << 10)
#define kMenuItem12		(1 << 11)
#define kMenuItem13		(1 << 12)
#define kMenuItem14		(1 << 13)
#define MENU_ITEM_FLAG(n) (1 << ((n)-1))

#include <PP_Types.h>

#ifndef _Object_h_
#define _Object_h_


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

#ifndef __MENUS__
#include <Menus.h>
#endif

@interface LMenu : Object
{
	id mNextMenu;
	MenuHandle mMacMenuH;
	ResIDT mMENUid;
	Int16 mNumCommands;
	CommandT **mCommandNums;
	BOOL mIsInstalled;
}

- init: (ResIDT)inMENUid;
- init: (ResIDT)inMENUid : (Str255)inTitle;
- free;

- (MenuHandle) getMacMenuH;
- (ResIDT) getMenuID;
					// Mapping between Command numbers and Index numbers

- (CommandT) commandFromIndex: (Int16)inIndex;
- (CommandT) syntheticCommandFromIndex: (Int16)inIndex;
- (Int16) indexFromCommand: (CommandT)inCommand;

- (BOOL) findNextCommand: (Int16 *)ioIndex : (Int32 *)outCommand;

					// Manipulating Items

- setCommand: (Int16)inIndex : (CommandT)inCommand;
- insertCommand: (Str255)inItemText : (CommandT)inCommand : (Int16)inAfterItem;
- removeCommand: (CommandT)inCommand;
- removeItem: (Int16)inItemToRemove;
	
- (BOOL) isInstalled;
- setInstalled: (BOOL)inInstalled;
	
// protected
	
- readCommandNumbers;
- getNextMenu;
- setNextMenu: inMenu;

@end

#include <PP_Types.h>

#define InstallMenu_AtEnd	((ResIDT)0)

@interface LMenuBar : Object
{
	id mMenuListHead;
}

- init: (ResIDT)inMBARid;
- free;

- (CommandT) menuCommandSelection: (const EventRecord *)inMouseEvent;

- (BOOL) couldBeKeyCommand: (const EventRecord *)inKeyEvent;

- (CommandT) findKeyCommand: (const EventRecord *)inKeyEvent;
- (CommandT) findCommand: (ResIDT)inMENUid : (Int16)inItem;
- findMenuItem: (CommandT)inCommand : (ResIDT *)outMENUid
	: (MenuHandle *)outMenuHandle : (Int16 *)outItem;
- (BOOL) findNextCommand: (Int16 *)ioIndex : (MenuHandle *)ioMenuHandle
	: (id *)ioMenu : (CommandT *)outCommand;

- installMenu: inMenu before: (ResIDT)inBeforeMENUid;
- removeMenu: inMenu;

- fetchMenu: (ResIDT)inMENUid;
- (BOOL) findNextMenu: (id *)ioMenu;

+ getCurrentMenuBar;

@end

typedef long CommandT;

#define kDITop		0x0050		// Top coord for disk init dialog
#define kDILeft		0x0070		// Left coord for disk init dialog
#define LEFT_MARGIN	10			// Left margin for window drawing

#define cmd_SpecialTest	1000

void Initialize();
void EventLoop();
void DoIdle(EventRecord *event);
void DoEvent(EventRecord *event);
void DoMenuCommand(long menuResult);
void CleanUp();
void DoActivate(WindowPtr window, BOOL becomingActive);
void DoUpdate(WindowPtr wp);
BOOL DoCloseWindow(WindowPtr wp);
void DuUpdate(WindowPtr wp);
void AdjustMenus(void);

OSErr CreateUntitledWindow(void);
OSErr CreateFileWindow(FSSpec *opFSSpec, BOOL isStationery);
OSErr NewDocWindow(long winPrivateSize);

void GetOpenName(StandardFileReply *toReply);
void GetSaveName(StandardFileReply *toReply, Str255 defaultName,
				 BOOL *isStationery);

BOOL System7Available(void);
BOOL TrapAvailable(short theTrap);
TrapType GetTrapType(short theTrap);
short NumToolboxTraps(void);

void ShowError(Str255 errorMessage, long errorNumber);
void PrintHex(long theNumber);
void PrintString(Str255 s);
void PrintOSType(OSType theType);
void CRLF(void);
void pStringCopy(Str255 srcString, Str255 destString);
void ConcatString(Str255 s1, Str255 s2);

BOOL IsSyntheticCommand(CommandT inCommand, ResIDT *outMenuID, Int16 *outMenuItem);
short ShowAboutBox(void);

void DoAEInstallation(void);
pascal OSErr HandleOAPP(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon);
pascal OSErr HandleODOC(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon);
pascal OSErr HandlePDOC(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon);
pascal OSErr HandleQUIT(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon);
OSErr RequiredCheck(AppleEvent *theAppleEvent);

// You'll have to add code for these:

void DrawWindowContents(WindowPtr wp);
void DoContentClick(WindowPtr wp, Point where);
void DoTest(WindowPtr wp);

// Special types

// The 'winPrivate' struct describes the data that's attached to each doc
// window via the window's refCon

typedef struct {
	short data1;			// etc.
	// define other data elements here that you want associated with a window
} winPrivate, *winPrivatePtr, **winPrivateHandle;

// Global vars:

BOOL gQuitting;
BOOL gInBackground;
WindowPtr gMessageWindow;
RgnHandle gCursorRgn;
id gMenuBar;

int main(void)
{
	Initialize();
	EventLoop();
	ZeroScrap();
	TEToScrap();
	[gMenuBar free];
	return 0;
}

void Initialize(void)
{
	short i;

	MaxApplZone();
	for (i = 1; i <= 4; ++i)
		MoreMasters();

	FlushEvents(everyEvent, 0);

	InitGraf(&qd.thePort);
	InitFonts();
	InitWindows();
	InitMenus();
	TEInit();
	InitDialogs(0L);
	InitCursor();

	gInBackground = NO;
	gQuitting = NO;
	gCursorRgn = NewRgn();		// Forces cursor-move event right away

	TEFromScrap();

	gMenuBar = [[LMenuBar alloc] init: rMenuBar]; // Create the menu bar
	if (gMenuBar == nil) {
		gQuitting = YES;
		return;
	}

	if (!System7Available()) {
		Alert(rNotSystem7, 0L);
		gQuitting = YES;
		return;
	}

	// InitEditionPack();		// Initialize Edition Manager
	DoAEInstallation();			// Install AppleEvent handlers

	// This window is for debugging purposes only:
	gMessageWindow = GetNewWindow(rDebugWindow, 0L, (WindowPtr)-1);
}

void EventLoop()
{
	BOOL gotEvent;
	EventRecord event;
	long sleepTime;

	while (!gQuitting) {
		sleepTime = GetCaretTime(); // If front window has TE record

//		if (gInBackground)
//			sleepTime = -1L;	// Set appropriate background value

		gotEvent = WaitNextEvent(everyEvent, &event, sleepTime, gCursorRgn);
		if (gotEvent)
			DoEvent(&event);
		else
			DoIdle(&event);
	}
}

void DoIdle(EventRecord *event)
{
	// Do idle stuff
}

void DoEvent(EventRecord *event)
{
	short myError;
	short windowPart;
	WindowPtr window;
	char key;
	Point mountPoint;
	CommandT menuCommand;

	switch (event->what) {
	case mouseDown:
		windowPart = FindWindow(event->where, &window);
		switch (windowPart) {
		case inMenuBar:
			AdjustMenus();		// Prepare menu items first
			menuCommand = [gMenuBar menuCommandSelection: event];
			DoMenuCommand(menuCommand);
			break;
		case inContent:
			if (window != FrontWindow())
				SelectWindow(window);
			else
				DoContentClick(window, event->where);
			break;
		case inDrag:
			DragWindow(window, event->where, &qd.screenBits.bounds);
			break;
		case inGrow:
			break;
		case inGoAway:
			if (TrackGoAway(window, event->where))
				DoCloseWindow(window);
			break;
		case inZoomIn:
		case inZoomOut:
			if (TrackBox(window, event->where, windowPart)) {
				SetPort(window);
				EraseRect(&window->portRect);
				ZoomWindow(window, windowPart, YES);
				InvalRect(&window->portRect);
			}
			break;
		}
		break;
	case keyDown:
	case autoKey:
		key = event->message & charCodeMask;
		if (event->modifiers & cmdKey) { // Is a command key down?
			if ([gMenuBar couldBeKeyCommand: event]) {
				AdjustMenus();		// Prepare menu items first
				menuCommand = [gMenuBar findKeyCommand: event];
				DoMenuCommand(menuCommand);
			}
		}
		break;
	case activateEvt:
		DoActivate((WindowPtr)event->message,
				   (event->modifiers & activeFlag) != 0);
		break;
	case updateEvt:
		DoUpdate((WindowPtr)event->message);
		break;
	case diskEvt:
		if ((event->message >> 16) != noErr) {
			mountPoint.h = kDILeft;
			mountPoint.v = kDITop;
			myError = DIBadMount(mountPoint, event->message);
		}
		break;
	case osEvt:
		switch ((event->message >> 24) & 0xff) {
		case suspendResumeMessage:
			if ((event->message & resumeFlag) == 0) { // suspend
				gInBackground = YES;
				ZeroScrap();
				TEToScrap();
				DoActivate(FrontWindow(), NO); // deactivate
			}
			else {						// resuming
				gInBackground = NO;
				if (event->message & convertClipboardFlag)
					TEFromScrap();
				DoActivate(FrontWindow(), YES); // activate
			}
			break;
		case mouseMovedMessage:
			DisposeRgn(gCursorRgn);
			gCursorRgn = NewRgn();
			SetRectRgn(gCursorRgn, -32768, -32768, 32766, 32766);
			break;
		}
		break;
	case kHighLevelEvent:
		AEProcessAppleEvent(event);
		break;
	}
}

void DoMenuCommand(CommandT command)
{
	short theMenuItem, itemHit;
	ResIDT theMenuID;
	Str255 defaultName;
	StandardFileReply reply;
	WindowPtr wp;
	BOOL isStationery;

	if (IsSyntheticCommand(command, &theMenuID, &theMenuItem)) {
		if (theMenuID == MENU_Apple) {
									// Handle selection from the Apple Menu
			Str255	appleItem;
			GetMenuItemText(GetMenuHandle(theMenuID), theMenuItem, appleItem);
			OpenDeskAcc(appleItem);
			
		}
#if 0
		else
			cmdHandled = LCommander::ObeyCommand(inCommand, ioParam);
#endif			
	} else {
		switch (command) {
			case cmd_About:
				itemHit = ShowAboutBox();
				break;
			case cmd_New:
				CreateUntitledWindow();
				break;
			case cmd_Open:
				GetOpenName(&reply);
				if (reply.sfGood) {
					isStationery = (reply.sfFlags & 0x0800) != 0;
					CreateFileWindow(&reply.sfFile, isStationery);
				}
				break;
			case cmd_Close:
				DoCloseWindow(FrontWindow());
				break;
			case cmd_Save:
				// Save file to disk with current name
				break;
			case cmd_SaveAs:
				wp = FrontWindow();
				GetWTitle(wp, defaultName);
				GetSaveName(&reply, defaultName, &isStationery);
				if (reply.sfGood) {
					// Save file to disk with new name
					SetWTitle(wp, reply.sfFile.name);
				}
				break;
			case cmd_PageSetup:
			case cmd_Print:
			case cmd_Quit:
				CleanUp();
				gQuitting = YES;
				break;
			case cmd_SpecialTest:
				DoTest(FrontWindow());
				break;
			case cmd_Undo:
			case cmd_Cut:
			case cmd_Copy:
			case cmd_Paste:
			case cmd_Clear:
			default:
				break;
		}
	}
}

// Close specified window and dispose of private data handle in the refCon.
// Returns YES if the operation was not cancelled.
BOOL DoCloseWindow(WindowPtr wp)
{
	winPrivateHandle myPrivate;

	if (wp) {
		SetPort(wp);
		myPrivate = (winPrivateHandle)GetWRefCon(wp);

		// Put code here to ask user to verify close if window is "dirty".
		// Return NO if user cancels

		if (myPrivate) {
			// Warning: dispose of any handles in private data first!
			DisposeHandle((Handle)myPrivate);
		}
		DisposeWindow(wp);
	}
	return YES;
}

void CleanUp(void)
{
	WindowPtr wp;
	BOOL closed = YES;

	do {
		wp = FrontWindow();
		if (wp)
			closed = DoCloseWindow(wp);
	} while (closed && wp);

	if (closed)
		gQuitting = YES;		// Exit if no cancellation
}

void DoActivate(WindowPtr wp, BOOL becomingActive)
{
	if (becomingActive) {
		// Do activation stuff
	}
	else {
		// Do deactivation stuff
	}
}

void DoUpdate(WindowPtr wp)
{
	SetPort(wp);
	BeginUpdate(wp);
	if (!EmptyRgn(wp->visRgn))
		DrawWindowContents(wp);
	EndUpdate(wp);
}

void DrawWindowContents(wp)
{
	// Insert code here for redrawing window
}

// Enable and disable menu items as required by the context
void AdjustMenus(void)
{
	WindowPtr wp;
	ResIDT menuID;
	MenuHandle menuHandle;
	short menuItem;

	wp = FrontWindow();

	[gMenuBar findMenuItem: cmd_Undo : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);
	[gMenuBar findMenuItem: cmd_Cut : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);
	[gMenuBar findMenuItem: cmd_Copy : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);
	[gMenuBar findMenuItem: cmd_Paste : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);
	[gMenuBar findMenuItem: cmd_Clear : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);

	[gMenuBar findMenuItem: cmd_Open : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);
	[gMenuBar findMenuItem: cmd_New : &menuID : &menuHandle : &menuItem];
	DisableItem(menuHandle, menuItem);

	if (wp == nil || wp == gMessageWindow) {
		[gMenuBar findMenuItem: cmd_Close : &menuID : &menuHandle : &menuItem];
		DisableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_Save : &menuID : &menuHandle : &menuItem];
		DisableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_SaveAs : &menuID : &menuHandle : &menuItem];
		DisableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_SpecialTest : &menuID : &menuHandle : &menuItem];
		DisableItem(menuHandle, menuItem);
	}
	else {
		[gMenuBar findMenuItem: cmd_Close : &menuID : &menuHandle : &menuItem];
		EnableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_Save : &menuID : &menuHandle : &menuItem];
		EnableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_SaveAs : &menuID : &menuHandle : &menuItem];
		EnableItem(menuHandle, menuItem);
		[gMenuBar findMenuItem: cmd_SpecialTest : &menuID : &menuHandle : &menuItem];
		EnableItem(menuHandle, menuItem);
	}
}

void DoTest(WindowPtr wp)
{
	SetPort(wp);
	EraseRect(&wp->portRect);
	MoveTo(10, 20);
	DrawString("\pInsert your test code here.");
}

// Handle clicks inside a window
void DoContentClick(WindowPtr wp, Point where)
{
	// Insert code here for handling clicks in a window
}

// Install Apple Event handlers
void DoAEInstallation(void)
{
	AEInstallEventHandler(kCoreEventClass, kAEOpenDocuments,
						  NewAEEventHandlerProc(HandleODOC), 0, NO);
	AEInstallEventHandler(kCoreEventClass, kAEQuitApplication,
						  NewAEEventHandlerProc(HandleQUIT), 0, NO);
	AEInstallEventHandler(kCoreEventClass, kAEPrintDocuments,
						  NewAEEventHandlerProc(HandlePDOC), 0, NO);
	AEInstallEventHandler(kCoreEventClass, kAEOpenApplication,
						  NewAEEventHandlerProc(HandleOAPP), 0, NO);
}

OSErr CreateUntitledWindow(void)
{
	OSErr myErr;
	WindowPtr wp;

	myErr = NewDocWindow(sizeof(winPrivate));
	if (myErr != noErr)
		return myErr;

	wp = FrontWindow();
	SetWTitle(wp, "\pUntitled");
	return noErr;
}

OSErr CreateFileWindow(FSSpec *opFSSpec, BOOL isStationery)
{
	OSErr fileError;
	WindowPtr wp;

	// Insert code to open and read file's data

	fileError = NewDocWindow(sizeof(winPrivate));
	if (fileError != noErr)
		return fileError;

	wp = FrontWindow();
	
	// Insert code to attach data to window, perhaps by storing handle to it
	// in the winPrivate structure
	
	if (isStationery)
	SetWTitle(wp, isStationery ? "\pUntitled" : opFSSpec->name);

	return noErr;
}

// Create new window and attach (via the refCon) a handle to your private data
// for the window
OSErr NewDocWindow(long winPrivateSize)
{
	WindowPtr wp;
	Handle myPrivate;
	
	wp = GetNewWindow(rMainWindow, 0L, (WindowPtr)-1);
	if (wp == nil)
		return memFullErr;
		
	SetPort(wp);
	
	myPrivate = NewHandleClear(winPrivateSize);
	if (myPrivate == nil)
		return memFullErr;
	
	SetWRefCon(wp, (long)myPrivate);
	
	return noErr;
}

void GetOpenName(StandardFileReply *toReply)
{
	StandardGetFile(0L, -1, 0L, toReply);
}

void GetSaveName(StandardFileReply *toReply, Str255 defaultName,
				 BOOL *isStationery)
{
	*isStationery = FALSE;
	StandardPutFile("\pSave file as:", defaultName, toReply);
}

// APPLE EVENT HANDLERS
// for required Apple Events

pascal OSErr HandleOAPP(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon)
{
	OSErr myErr;

	myErr = RequiredCheck(theAppleEvent);
	if (myErr != noErr) return myErr;

	myErr = CreateUntitledWindow();
	return myErr;
}

pascal OSErr HandleODOC(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon)
{
	OSErr myErr;
	AEDescList docList;
	FSSpec myFSS;
	long itemsInList;
	AEKeyword theKeyword;
	DescType typeCode;
	Size actualSize;
	long i;
	Handle winDataHandle;
	FInfo theFInfo;
	BOOL isStationery;
	
	myErr = AEGetParamDesc(theAppleEvent, keyDirectObject, typeAEList, &docList);
	if (myErr != noErr) return myErr;
	
	myErr = RequiredCheck(theAppleEvent);
	if (myErr != noErr) return myErr;

	myErr = AECountItems(&docList, &itemsInList);
	if (myErr != noErr) return myErr;

	for (i = 1; i <= itemsInList; ++i) {
		myErr = AEGetNthPtr(&docList, i, typeFSS, &theKeyword, &typeCode,
							(Ptr)&myFSS, sizeof(FSSpec), &actualSize);
		if (myErr != noErr) return myErr;

		FSpGetFInfo(&myFSS, &theFInfo); // Check for stationery
		isStationery = ((theFInfo.fdFlags & 0x0800) != 0);
		CreateFileWindow(&myFSS, isStationery);
	}
	return noErr;
}

pascal OSErr HandlePDOC(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon)
{
	return errAEEventNotHandled;
}

pascal OSErr HandleQUIT(AppleEvent *theAppleEvent, AppleEvent *reply,
						long myRefCon)
{
	OSErr myErr;

	myErr = RequiredCheck(theAppleEvent);
	if (myErr != noErr) return myErr;

	gQuitting = YES;
	return noErr;
}

OSErr RequiredCheck(AppleEvent *theAppleEvent)
{
	OSErr myErr;
	DescType typeCode;
	Size actualSize;

	myErr = AEGetAttributePtr(theAppleEvent, keyMissedKeywordAttr, typeWildCard,
							  &typeCode, 0L, 0, &actualSize);
	if (myErr == errAEDescNotFound) return noErr;
	if (myErr == noErr) return errAEEventNotHandled;
	return myErr;
	
}

// CHECKING FOR SYSTEM 7
// Call System7Available() to determin whether the system software is 7 or higher

BOOL System7Available(void)
{
	long sysVersion;
	
	if (!TrapAvailable(_Gestalt))
		return NO;
	if (Gestalt(gestaltSystemVersion, &sysVersion) == noErr && sysVersion >= 0x0700)
		return YES;
	return NO;
}

BOOL TrapAvailable(short theTrap)
{
	TrapType tType = GetTrapType(theTrap);
	
	if (tType == ToolTrap) {
		theTrap = (theTrap & 0x07ff);
		if (theTrap >= NumToolboxTraps())
			theTrap = _Unimplemented;
	}
	return (NGetTrapAddress(theTrap, tType) != 
			NGetTrapAddress(_Unimplemented, ToolTrap));
}

TrapType GetTrapType(short theTrap)
{
	if ((theTrap & 0x0800) > 0)
		return ToolTrap;
	else
		return OSTrap;
}

short NumToolboxTraps(void)
{
	if (NGetTrapAddress(_InitGraf, ToolTrap) == NGetTrapAddress(0xaa6e, ToolTrap))
		return 0x0200;
	else
		return 0x0400;
}

// UTILITY FUNCTIONS

// Display error message and error number in Message window
void ShowError(Str255 errorMessage, long errorNumber)
{
	WindowPtr wp;
	Str255 numberString;
	
	NumToString(errorNumber, numberString);
	
	GetPort(&wp);
	SetPort(gMessageWindow);
	
	EraseRect(&gMessageWindow->portRect);
	MoveTo(10, 20);
	DrawString(errorMessage);
	DrawString(numberString);
	
	SetPort(wp);
}

void PrintHex(long theNumber)
{
	unsigned char theString[10];
	long digit;
	short i;
	WindowPtr wp;

	theString[0] = 9;
	theString[1] = '$';
	for (i = 0; i < 8; ++i) {
		digit = theNumber & 0xf;
		if (digit < 10)
			digit += (long)'0';
		else
			digit += (long)('A' - 10);
		theString[9 - i] = (char)digit;
		theNumber >>= 4;
	}

	GetPort(&wp);
	SetPort(gMessageWindow);

	EraseRect(&gMessageWindow->portRect);
	MoveTo(10, 20);
	DrawString(theString);
	
	SetPort(wp);
}

void PrintString(Str255 s)
{
	WindowPtr wp;

	if (s == nil)
		return;
	
	GetPort(&wp);
	SetPort(gMessageWindow);

	EraseRect(&gMessageWindow->portRect);
	MoveTo(10, 20);
	DrawString(s);
	
	SetPort(wp);
}

void PrintOSType(OSType theType)
{
	Str255 typeString;
	WindowPtr wp;
	short i;
	
	typeString[0] = 4;
	for (i = 0; i < 4; ++i) {
		typeString[4 - i] = (char)(theType & 0xff);
		theType >>= 8;
	}
	
	GetPort(&wp);
	SetPort(gMessageWindow);

	EraseRect(&gMessageWindow->portRect);
	MoveTo(10, 20);
	DrawString(typeString);
	
	SetPort(wp);
}

// Advance drawing position in front window to left side of next line
void CRLF(void)
{
	Point currentPos;
	FontInfo theFontInfo;
	register short lineHeight;
	
	GetPen(&currentPos);
	GetFontInfo(&theFontInfo);
	
	lineHeight = theFontInfo.ascent + theFontInfo.descent + theFontInfo.leading;
	MoveTo(LEFT_MARGIN, currentPos.v + lineHeight);
}

void pStringCopy(Str255 srcString, Str255 destString)
{
	register short index = srcString[0] + 1;
	
	while (index--)
		*destString++ = *srcString++;
}

void ConcatString(Str255 s1, Str255 s2)
{
	short len = s2[0];
	
	if (len == 0)
		return;

	if (s1[0] + len > 255)
		len = 255 - s1[0];
	memcpy(s1 + s1[0], s2 + 1, len);
	s1[0] += len;
}

BOOL IsSyntheticCommand(CommandT inCommand, ResIDT *outMenuID, Int16 *outMenuItem)
{
	BOOL	isSynthetic = NO;
	if (inCommand < 0) {				// A synthetic command is negative
										// with a non-zero hi word
		*outMenuID = (Int16) ((-inCommand) >> 16);
		if (*outMenuID > 0) {
			*outMenuItem = (Int16) (-inCommand);
			isSynthetic = YES;
		}
	}
	return isSynthetic;
}

short ShowAboutBox(void)
{
	return Alert(rAboutBox, 0L);
}
