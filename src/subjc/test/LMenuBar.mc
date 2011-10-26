// ===========================================================================
//	LMenuBar.cp				 		й1993 Metrowerks Inc. All rights reserved.
// ===========================================================================
//
//	Manages a Mac menu bar. Contains a list a Menu objects.
//
//	Dependencies:
//		LMenu
//
//	Resources:
//		'MBAR'		Standard Mac resource for a Menu Bar
//
//	ее Techniques
//
//	е Adding/Removing a Menu depending on runtime conditions
//		During initialization, create a Menu object
//		Store pointer to Menu object in an appropriate place
//		When you want to add the Menu to the MenuBar:
//			LMenuBar::GetCurrentMenuBar()->InstallMenu(myMenu, beforeID);
//			where "myMenu" is the pointer to the Menu object
//				"beforeID" is the ID of the Menu before which to put
//				this Menu (use InstallMenu_AtEnd to put the Menu last or
//				the Toolbox constant hierMenu for a hierarchical or popup)
//		When you want to remove the Menu from the MenuBar:
//			LMenuBar::GetCurrentMenuBar()->RemoveMenu(myMenu);
//
//	е Toggling a Menu item
//		For a menu item that toggles between two states (such as Show Toolbar
//		and Hide Toolbar), you can change the command as well as the text
//		of the menu item.
//
//		The follow code fragment assumes that you have declared oldCommand
//		and newCommand as CommandT variables or constants and newName as
//		as some kind of string.
//										
//		ResIDT		theID;
//		MenuHandle	theMenuH;
//		Int16		theItem;			// Locate oldCommand
//		FindMenuItem(oldCommand, theID, theMenuH, theItem);
//		if (theItem != 0) {				// Replace with newCommand
//			LMenu	*theMenu = LMenuBar::GetCurrentMenuBar->FetchMenu(theID);
//			theMenu->SetCommand(theItem, newCommand);
//			SetMenuItemText(theMenuH, theItem, newName);
//		}
// ===========================================================================
//	PP_Messages.h					й1993 Metrowerks Inc. All rights reserved.
// ===========================================================================


#include <PP_Types.h>

	// Messages are 32-bit numbers used as parameters to a few PowerPlant
	// functions that you typically override:
	//		LCommander::ObeyCommand
	//		LListener::ListenerToMessage
	//		LAttachment::ExecuteSelf
	
	// These function each take a Message and a void* parameter called
	// "ioParam". For each Message defined below, the adjacent comment
	// specifies the data passed via ioParam.
	
	// If a message is sent as a result of a menu selection (either with
	// the mouse or keyboard equivalent), the ioParam is an Int32*, where
	// the hi Int16 is the MENU ID, and the lo Int16 is the menu item
	// number (value returned by MenuSelect/MenuKey).

											// ioParam Data
											
#define cmd_Nothing			((MessageT)0)	// nil
#define msg_Nothing			((MessageT)0)	// nil

#define cmd_About			((MessageT)1)	// nil

					// File Menu
#define cmd_New				((MessageT)2)	// nil
#define cmd_Open			((MessageT)3)	// nil
#define cmd_Close			((MessageT)4)	// nil
#define cmd_Save			((MessageT)5)	// nil
#define cmd_SaveAs			((MessageT)6)	// nil
#define cmd_Revert			((MessageT)7)	// nil
#define cmd_PageSetup		((MessageT)8)	// nil
#define cmd_Print			((MessageT)9)	// nil
#define cmd_PrintOne		((MessageT)17)	// nil
#define cmd_Quit			((MessageT)10)	// nil

					// Edit Menu
#define cmd_Undo			((MessageT)11)	// nil
#define cmd_Cut				((MessageT)12)	// nil
#define cmd_Copy			((MessageT)13)	// nil
#define cmd_Paste			((MessageT)14)	// nil
#define cmd_Clear			((MessageT)15)	// nil
#define cmd_SelectAll		((MessageT)16)	// nil

#define cmd_SaveCopyAs		((MessageT)18)	// nil
#define cmd_ShowClipboard	((MessageT)19)	// nil

					// Undo/Redo Editing Actions
#define cmd_ActionDeleted	((CommandT)20)	// LAction*
#define cmd_ActionDone		((CommandT)21)	// LAction*
#define cmd_ActionCut		((CommandT)22)	// LTECutAction*
#define cmd_ActionCopy		((CommandT)23)	// nil [not used]
#define cmd_ActionPaste		((CommandT)24)	// LTEPasteAction*
#define cmd_ActionClear		((CommandT)25)	// LTEClearAction*
#define cmd_ActionTyping	((CommandT)26)	// LTETypingAction*

#define msg_TabSelect		((MessageT)201)	// nil
#define msg_BroadcasterDied	((MessageT)202)	// LBroadcaster*
#define msg_ControlClicked	((MessageT)203)	// LControl*
#define msg_ThumbDragged	((MessageT)204)	// LStdControl*

					// Use these three command numbers to disable the menu
					// item when you use the font-related menus as
					// hierarchical menus.
#define cmd_FontMenu		((MessageT)250)	// nil
#define cmd_SizeMenu		((MessageT)251)	// nil
#define cmd_StyleMenu		((MessageT)252)	// nil

					// Size menu commands
#define cmd_FontLarger		((MessageT)301)	// nil
#define cmd_FontSmaller		((MessageT)302)	// nil
#define cmd_FontOther		((MessageT)303)	// nil

					// Style menu commands
#define cmd_Plain			((MessageT)401)	// nil
#define cmd_Bold			((MessageT)402)	// nil
#define cmd_Italic			((MessageT)403)	// nil
#define cmd_Underline		((MessageT)404)	// nil
#define cmd_Outline			((MessageT)405)	// nil
#define cmd_Shadow			((MessageT)406)	// nil
#define cmd_Condense		((MessageT)407)	// nil
#define cmd_Extend			((MessageT)408)	// nil

					// Text justification
#define cmd_JustifyDefault	((MessageT)411)	// nil
#define cmd_JustifyLeft		((MessageT)412)	// nil
#define cmd_JustifyCenter	((MessageT)413)	// nil
#define cmd_JustifyRight	((MessageT)414)	// nil
#define cmd_JustifyFull		((MessageT)415)	// nil

					// Mail menu commands
#define cmd_AddMailer		((MessageT)501)	// nil
#define cmd_ExpandMailer	((MessageT)502)	// nil
#define cmd_SendLetter		((MessageT)503)	// nil
#define cmd_Reply			((MessageT)504)	// nil
#define cmd_Forward			((MessageT)505)	// nil
#define cmd_TagLetter		((MessageT)506)	// nil
#define cmd_OpenNextLetter	((MessageT)507)	// nil
#define cmd_Sign			((MessageT)508)	// nil
#define cmd_Verify			((MessageT)509)	// nil

					// Miscellaneous Messages
#define msg_GrowZone		((MessageT)801)	// Int32* (in: bytes needed, out: bytes freed)
#define msg_EventHandlerNote ((MessageT)802) // SEventHandlerNote*

					// Attachment Messages
#define msg_Event			((MessageT)810)	// EventRecord*
#define msg_DrawOrPrint		((MessageT)811)	// Rect* (frame of Pane)
#define msg_Click			((MessageT)812)	// SMouseDownEvent*
#define msg_AdjustCursor	((MessageT)813)	// EventRecord*
#define msg_KeyPress		((MessageT)814)	// EventRecord* (KeyDown or AutoKey event)
#define msg_CommandStatus	((MessageT)815)	// SCommandStatus*
#define msg_PostAction		((MessageT)816)	// LAction*

#define msg_OK				((MessageT)900)	// nil
#define msg_Cancel			((MessageT)901)	// nil

#define cmd_UseMenuItem		((CommandT)-1)	// --- (special flag, message is never sent)
#define msg_AnyMessage		((MessageT)-2)	// --- (special flag, message is never sent)

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

#include <PP_Types.h>

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

static id sMenuBar = nil;

@implementation LMenuBar

// ---------------------------------------------------------------------------
//		е LMenuBar
// ---------------------------------------------------------------------------
//	Construct Menu Bar from a MBAR resource
- init: (ResIDT)inMBARid
{
	id theMBAR;
	Int16 *menuIDP, numMenus, i;
	MenuHandle macAppleMenuH;

	[super init];
	theMBAR = [[StResource alloc] init: 'MBAR' : inMBARid];
	HLockHi([theMBAR handle]);

	sMenuBar = self;
	mMenuListHead = nil;

									// Install each menu in the MBAR resource
	menuIDP = (Int16 *)*[theMBAR handle];
	numMenus = *menuIDP++;
	for (i = 0; i <= numMenus; ++i)
		[self installMenu: [[LMenu alloc] init: *menuIDP++] : InstallMenu_AtEnd];

									// Populate the Apple Menu
	macAppleMenuH = GetMenuHandle(MENU_Apple);
	if (macAppleMenuH != nil)
		AppendResMenu(macAppleMenuH, 'DRVR');

	DrawMenuBar();

	[theMBAR free];

	return self;
}

// ---------------------------------------------------------------------------
//		е ~LMenuBar
// ---------------------------------------------------------------------------
//	Destructor
- free
{
	id theMenu = nil;

	while ([self findNextMenu: *theMenu])
		[self removeMenu: theMenu];

	return [super free];
}

// ---------------------------------------------------------------------------
//		е MenuCommandSelection
// ---------------------------------------------------------------------------
//	Handle menu selection with the Mouse and return the command number for
//	the item chosen
//
//	When to Override:
//		To implement alternative menu selection behavior.
//		To change menu commands based on what modifier keys are down
- (CommandT) menuCommandSelection: (const EventRecord *)inMouseEvent
{
	long menuChoice = MenuSelect(inMouseEvent->where);
	CommandT menuCmd = cmd_Nothing;

	if (HiWord(menuChoice) != 0)
		menuCmd = [self findCommand: HiWord(menuChoice) : LoWord(menuChoice)];

	return menuCmd;
}

// ---------------------------------------------------------------------------
//		е CouldBeKeyCommand
// ---------------------------------------------------------------------------
//	Return whether the keystoke could be a key equivalent for a menu command
//
//	When to Override:
//		To implement keyboard equivalents that use modifier keys other than
//		just the command key. This function returns true if the command
//		key is down.
- (BOOL) couldBeKeyCommand: (const EventRecord *)inKeyEvent
{
	return (inKeyEvent->modifiers & cmdKey) != 0;
}

// ---------------------------------------------------------------------------
//		е FindKeyCommand
// ---------------------------------------------------------------------------
//	Return the Command number corresponding to a keystroke
//		Returns cmd_Nothing if the keystroke is not a menu equivalent
//
//	Usage Note: Call this function when CouldBeKeyCommand() is true.
//
//	When to Override:
//		To implement keyboard equivalents that use modifier keys other than
//		just the command key. This function calls the Toolbox routine
//		MenuKey to find the associated menu item, if any. Override this
//		function (as well as CouldBeKeyCommand) to implement key equivalents
//		that use other modifier keys, such as Option, Shift, or Control.
- (CommandT) findKeyCommand: (const EventRecord *)inKeyEvent
{
	CommandT theCommand = cmd_Nothing;
	char theChar = inKeyEvent->message & charCodeMask;
	long menuChoice = MenuKey(theChar);

	if (HiWord(menuChoice) != 0)
		theCommand = [self findCommand: HiWord(menuChoice) : LoWord(menuChoice)];

	return theCommand;
}

// ---------------------------------------------------------------------------
//		е FindCommand
// ---------------------------------------------------------------------------
//	Return the Command number corresponding to a Menu (ID, item) pair
- (CommandT) findCommand: (ResIDT)inMENUid : (Int16)inItem
{
									// Start with synthetic command number
	CommandT theCommand = -(((Int32)inMENUid) << 16) - inItem;

	id theMenu = mMenuListHead;

	while (theMenu) {				// Search all installed Menus
		if (inMENUid == [theMenu getMenuID]) {
			theCommand = [theMenu commandFromIndex: inItem];
			break;
		}
		theMenu = [theMenu getNextMenu];
	}
	
	return theCommand;
}

// ---------------------------------------------------------------------------
//		е FindMenuItem
// ---------------------------------------------------------------------------
//	Passes back the MENU id, MenuHandle, and item number corresponding to a
//	Command number
//
//	If the Command is not associated with any item in the MenuBar,
//		outMENUid is 0, outMenuHandle is nil, and outItem is 0
- findMenuItem: (CommandT)inCommand : (ResIDT *)outMENUid
	: (MenuHandle *)outMenuHandle : (Int16 *)outItem
{
	Int16 theItem = 0;			// Search menu list for the command
	id theMenu = mMenuListHead;

	while (theMenu) {
		theItem = [theMenu indexFromCommand: inCommand];
		if (theItem != 0)
			break;
		theMenu = [theMenu getNextMenu];
	}
	
	if (theItem != 0) {				// Command found, get ID and MenuHandle
		*outMENUid = [theMenu getMenuID];
		*outMenuHandle = [theMenu getMacMenuH];
		
	} else {						// Command not found
		*outMENUid = 0;
		*outMenuHandle = nil;
	}
	*outItem = theItem;

	return self;
}

// ---------------------------------------------------------------------------
//		е FindNextCommand
// ---------------------------------------------------------------------------
//	Passes back the next command in the MenuBar
//
//	On entry,
//		ioIndex, ioMenuHandle, and ioMenu specify an item in a Menu
//		ioMenuHandle of nil means to start at the beginning, so the
//		next command will be the first one in the MenuBar
//	On exit,
//		ioIndex, ioMenuHandle, and ioMenu specify the next item in
//		the MenuBar. If the next item is in the same menu, ioIndex
//		is incremented by one and ioMenuHandle and ioMenu are unchanged.
//		If the next item is in another menu, ioIndex is one, and
//		ioMenuHandle and ioMenu refer to the next menu.
//		outCommand is the command number associated with that item
//
//	Returns true if the next command exists
//	Returns false if there is no next command
//
//	Use this function to iterate over all commands in the MenuBar:
//
//		LMenuBar	*theMenuBar = LMenuBar::GetCurrentMenuBar();
//		Int16		menuItem;
//		MenuHandle	macMenuH = nil;
//		LMenu		*theMenu;
//		CommandT	theCommand;
//
//		while (theMenuBar->FindNextCommand(menuItem, macMenuH,
//											theMenu, theCommand)) {
//			// Do something with theCommand
//		}
- (BOOL) findNextCommand: (Int16 *)ioIndex : (MenuHandle *)ioMenuHandle
	: (id *)ioMenu : (CommandT *)outCommand
{
	BOOL cmdFound;

	if (*ioMenuHandle == nil) {		// Special case: first time
		*ioIndex = 0;				//   Start at beginning of our Menu list
		*ioMenu = mMenuListHead;
		if (*ioMenu == nil)
			return NO;				// Quick exit if there are no Menus
	}
		
	do {
									// Get MenuHandle for current Menu
		*ioMenuHandle = [*ioMenu getMacMenuH];
									// Search in current Menu
		cmdFound = [*ioMenu findNextCommand: ioIndex : outCommand];
		if (!cmdFound) {			// No next command in current Menu
			*ioIndex = 0;			// Move to start of next Menu
			*ioMenu = [*ioMenu getNextMenu];
		}
									// End search upon finding next command
									//   or reaching end of menu list 
	} while (!cmdFound && (*ioMenu != nil));
	
	return cmdFound;
}

// ---------------------------------------------------------------------------
//		е InstallMenu
// ---------------------------------------------------------------------------
//	Install a Menu object in the MenuBar
- installMenu: inMenuToInstall before: (ResIDT)inBeforeMENUid
{
	MenuHandle macMenuH;
	Int16 itemCount, item, itemCmd;

		// It's possible to add a Menu twice to the Mac menu list--
		// once as a regular menu and once as a submenu (hierarchical
		// or popup menu). However, we only need one copy of the
		// menu in our menu list.
		
	if (![inMenuToInstall isInstalled]) {
									// Add it to our singly-linked list
		[inMenuToInstall setNextMenu: mMenuListHead];
		mMenuListHead = inMenuToInstall;
		[inMenuToInstall setInstalled: YES];
	}
	
									// Add it to the Mac MenuBar
	macMenuH = [inMenuToInstall getMacMenuH];
	InsertMenu(macMenuH, inBeforeMENUid);
		
									// Search menu items for submenus
									//   and install them also
	itemCount = CountMItems(macMenuH);
	for (item = 1; item <= itemCount; item++) {
		Int16 itemCmd;
		GetItemCmd(macMenuH, item, &itemCmd);
		if (itemCmd == hMenuCmd) {
			Int16 subMenuID;		// Submenu found. Get its ID, create
									//   a new Menu object, and recursively
									//   call this function to install it.
									//   Recursion means that sub-submenus
									//   get installed too.
			GetItemMark(macMenuH, item, &subMenuID);
			[self installMenu: [[LMenu alloc] init: subMenuID] : hierMenu];
		}
	}

	if (inBeforeMENUid != hierMenu) {
									// Not a submenu, so force a redraw
		InvalMenuBar();				//   of the MenuBar
	}
}

// ---------------------------------------------------------------------------
//		е RemoveMenu
// ---------------------------------------------------------------------------
//	Remove a Menu object from the MenuBar
- removeMenu: inMenuToRemove
{
									// Search for Menu in our list
	id theMenu = mMenuListHead;
	id prevMenu = nil;

	while (theMenu != nil && theMenu != inMenuToRemove) {
		prevMenu = theMenu;
		theMenu = [theMenu getNextMenu];
	}
	
	if (theMenu != nil) {			// Menu is in our list
									// Remove it from our singly-linked list
		if (prevMenu == nil)
			mMenuListHead = [inMenuToRemove getNextMenu];
		else
			[prevMenu setNextMenu: [inMenuToRemove getNextMenu]];

		[inMenuToRemove setNextMenu: nil];
		[inMenuToRemove setInstalled: NO];
									
									// Remove it from the Mac MenuBar
		DeleteMenu([inMenuToRemove getMenuID]);
		InvalMenuBar();				// Force redraw of MenuBar
									// ??? don't redraw if a submenu ???
	}
	return self;
}

// ---------------------------------------------------------------------------
//		е FetchMenu
// ---------------------------------------------------------------------------
//	Return the Menu object for the specified MENU resource ID
//
//	Returns nil if there is no such Menu object
- fetchMenu: (ResIDT)inMENUid
{
	LMenu *theMenu = mMenuListHead;
									// Search menu list until reaching the
									//   end or finding a match
	while (theMenu != nil && theMenu->mMENUid != inMENUid)
		theMenu = [theMenu getNextMenu];

	return theMenu;
}

// ---------------------------------------------------------------------------
//		е FindNextMenu
// ---------------------------------------------------------------------------
//	Pass back the next Menu in a MenuBar
//
//	On entry, ioMenu is a pointer to a Menu object
//		Pass nil to get the first Menu
//	On exit, ioMenu is a pointer to the next Menu in the MenuBar
//		ioMenu is nil if there is no next menu
//
//	Returns false if there is no next menu
//
//	Use this function to loop thru all the Menus in a MenuBar:
//		LMenuBar	*theMenuBar = LMenuBar::GetCurrentMenuBar();
//		LMenu	*theMenu = nil;
//		while (theMenuBar->FindNextMenu(theMenu) {
//			// ... do something with theMenu
//		}
- (BOOL) findNextMenu: (id *)ioMenu
{
	if (ioMenu == nil)
		ioMenu = mMenuListHead;
	else
		ioMenu = [ioMenu getNextMenu];
	
	return (ioMenu != nil);
}

// ---------------------------------------------------------------------------
//		е getCurrentMenuBar [static]
// ---------------------------------------------------------------------------
//	Return a pointer to the current MenuBar object
+ getCurrentMenuBar
{
	return sMenuBar;
}

@end
