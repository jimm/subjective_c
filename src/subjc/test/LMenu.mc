//
//	Manages a Mac menu. Maintains a mapping between Menu items and
//	Command numbers.
//
//	Dependencies:
//		LMenuBar (declared as a friend class in the interface)
//
//	Resources:
//		'MENU'		Standard Mac resource for a Menu
//		'Mcmd'		Command numbers for each item in the Menu
//
//	ее Command Numbers
//	Commands are 32-bit, signed integer values.
//	PowerPlant reserves command numbers -999 to +999.
//
//		е Synthetic Command Numbers
//		A synthetic command number has the Menu ID in the high 16 bits
//		and the item number in the low 16 bits, with the result negatated.
//			syntheticCmd = - (MenuID << 16) - ItemNumber
//		A synthetic command is the negative of the value returned by
//		the Toolbox traps MenuSelect and MenuKey.
//		You can extract the components as follows:
//			MenuID = HiWord(-syntheticCmd);
//			ItemNumber = LoWord(-syntheticCmd);
//		Alternatively, the LCommander class has an IsSyntheticCommand
//		static function that extracts this information.
//
//		You must use Menu ID numbers between 1 and 32767. Therefore, a
//		command number is synthetic if it is negative and the hi word
//		of its negation is not zero (which would correspond to a zero
//		Menu ID).
//
//		Synthetic commands numbers range from $80000000 (Menu ID 32767)
//		to $FFFF0000 (Menu ID 1).
//
//		е Negative command numbers
//		Negative command numbers from $FFFF0001 to $FFFFFFFF (-65535 to -1)
//		are not valid synthetic command numbers. Programs can use command
//		numbers in this range. (As mentioned above PowerPlant reserves
//		-999 to +999). However, the PowerPlant Application class treats
//		positive and negative command numbers differently.
//
//		The Application class updates the enabled state of menu items with
//		positive command numbers just before letting the user make a menu
//		selection. It does not update the state of menu items with negative
//		command numbers. You might want to use a negative command number
//		for a menu item that is always enabled (except when its entire
//		menu is disabled; disabling an entire menu overrides the settings
//		of individual menu items).
//
//	ее Command Table
//	The command table (mCommandNums) is a handle of command numbers. The
//	table always starts with the first menu item. For example, if
//	mNumCommands is 6, then the commands in the table map to items 1 to 6.
//
//	ее CommandFromIndex
//	CommandFromIndex returns the command for a particular menu item. It
//	returns a synthetic command number in two cases:
//		1) The menu item is greater than the size of the command table.
//		This happens when you add menu items at runtime (for example, by
//		calling AppendResMenu for a Font menu or maintaining a Windows menu).
//
//		2) The item has a command of cmd_UseMenuItem (value of -1).
//
//	ее Using the Toolbox Menu Manager
//	You should use direct Toolbox traps for all menu operations except
//	adding and removing items that have command numbers. You can get the
//	MenuHandle for a Menu object from the GetMacMenuH function.
//
//	Note that is OK to add and remove items that don't have command numbers.
//	For example, the Windows menu in some programs have some fixed items
//	at the top, then a variable list of the names of open windows. Using
//	LMenu, only the fixed items would have command numbers. The items for
//	the open windows would not have command numbers, so you can call
//	the Toolbox traps InsertMenuItem and DeleteMenuItem for those items.
//	For items with command numbers, you must use the LMenu functions
//	InsertCommand, RemoveCommand, and RemoveItem.

#include <PP_Messages.h>

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

@implementation LMenu

// ---------------------------------------------------------------------------
//		е LMenu
// ---------------------------------------------------------------------------
//	Construct Menu from a 'MENU' resource
//
//	This is equivalent to the Toolbox GetMenu() call

- init: (ResIDT)inMENUid
{
	[super init];

	mMacMenuH = GetMenu(inMENUid);// Even though Inside Mac warns
										//  about calling GetMenu more than
										//	once for a Menu, TechNote
										//	TB 550 - Menu Mgr Q&As says
										//	that it's OK for the Mac Plus
										//	or any more recent machine.
	mMENUid = inMENUid;
		
	mNextMenu = nil;
	mNumCommands = 0;
	mCommandNums = nil;
	mIsInstalled = NO;

	if (mMacMenuH != nil)
		[self readCommandNumbers];

	return self;
}


// ---------------------------------------------------------------------------
//		е LMenu
// ---------------------------------------------------------------------------
//	Construct Menu object from a ID and a Title
//
//	This is equivalent to the Toolbox NewMenu() call

- init: (ResIDT)inMENUid : (Str255)inTitle
{
	[super init];

	mMENUid = inMENUid;
	mNextMenu = nil;
	mNumCommands = 0;
	mCommandNums = nil;
	mIsInstalled = NO;

	mMacMenuH = NewMenu(inMENUid, inTitle);

	return self;
}


// ---------------------------------------------------------------------------
//		е ~LMenu
// ---------------------------------------------------------------------------
//	Destructor

- free
{
	if (mMacMenuH != nil) {
		DeleteMenu(mMENUid);		// Remove Menu from Mac MenuBar
		
			// Free Mac MenuHandle. At this point, we don't know if
			// the menu was created using GetMenu or NewMenu, which
			// require different ways to delete the MenuHandle.
			// Thus, we call ReleaseResource first, which will fail,
			// but not crash, if the MenuHandle is not from a resource.
			// If ReleaseResource fails with a resNotFound error, the
			// MenuHandle is not a resource, so we call DisposeMenu.
		
		ReleaseResource((Handle)mMacMenuH);
		if (ResError() == resNotFound)
			DisposeMenu(mMacMenuH);
	}

	if (mCommandNums != nil)
		DisposeHandle((Handle)mCommandNums);

	return [super free];
}


// ---------------------------------------------------------------------------
//		е ReadCommandNumbers
// ---------------------------------------------------------------------------
//	Get command numbers from the 'Mcmd' resource
//
//	A 'Mcmd" resource with the same ID as the 'MENU' resource contains a
//	list of command numbers. The format of a 'Mcmd' resource is:
//		Number of Commands: n		(2 bytes)
//		Command Num for Item 1		(4 bytes)
//		   ...
//		Command Num for Item n		(4 bytes)

- readCommandNumbers
{
	Int16**	theMcmdH = (Int16**)GetResource('Mcmd', mMENUid);

	if (theMcmdH != nil) {
		mNumCommands = (*theMcmdH)[0];
		if (mNumCommands > 0) {
			Int32 commandsSize;
				
				// Our command numbers list is the same as the 'Mcmd'
				// resource without the 2-byte count at the top. So we
				// can reuse the 'Mcmd' resource Handle by detaching it,
				// shifting the command numbers down by 2-bytes, and
				// resizing it.
		
			DetachResource((Handle)theMcmdH);
			mCommandNums = (Int32 **)theMcmdH;
			commandsSize = mNumCommands * sizeof(Int32);
			BlockMoveData(*theMcmdH + 1, *mCommandNums, commandsSize);
			SetHandleSize((Handle) mCommandNums, commandsSize);
		}
	}
	return self;
}


// ---------------------------------------------------------------------------
//		е GetMacMenuH
// ---------------------------------------------------------------------------
//	Return MenuHandle associated with a Menu object

- (MenuHandle) getMacMenuH
{
	return mMacMenuH;
}


// ---------------------------------------------------------------------------
//		е GetMenuID
// ---------------------------------------------------------------------------
//	Return MENU ID associated with a Menu object

- (ResIDT) getMenuID
{
	return mMENUid;
}


// ---------------------------------------------------------------------------
//		е CommandFromIndex
// ---------------------------------------------------------------------------
//	Return the command number for a particular Menu item

- (CommandT) commandFromIndex: (Int16)inIndex
{
									// Table lookup if index is in range
	Int32 theCommand = cmd_UseMenuItem;

	if (inIndex <= mNumCommands) {
		Int32 *commandNumPtr = *mCommandNums;
		theCommand = commandNumPtr[inIndex-1];
	}
	
	if (theCommand == cmd_UseMenuItem) {
	
			// Command number is a special flag, either because it
			// was set that way in the command table or because the
			// index was greater than the command table size.
			
			// In this case, we return a synthetic command number,
			// which has the MENU id and item number embedded
			
		theCommand = [self syntheticCommandFromIndex: inIndex];
	}
	
	return theCommand;
}


// ---------------------------------------------------------------------------
//		е SyntheticCommandFromIndex
// ---------------------------------------------------------------------------
//	Return the synthetic command number for a particular Menu item
//
//	A synthetic command number has the MENU id in the high 16 bits and
//	the item number in the low 16 bits, and the resulting 32-bit number
//	is negated (to distinguish it from regular command numbers). The
//	synthetic command number is the negative of the value that would be
//	returned by the Toolbox trap MenuSelect for the menu item.

- (CommandT) syntheticCommandFromIndex: (Int16)inIndex
{
	return (-(((Int32)mMENUid) << 16) - inIndex);
}


// ---------------------------------------------------------------------------
//		е IndexFromCommand
// ---------------------------------------------------------------------------
//	Return the Menu item index number for a particular command number
//		Return 0 if the command number is not used for this Menu

- (Int16) indexFromCommand: (CommandT)inCommand
{
	Int16 theIndex;
	CommandT *commandsP = *mCommandNums;

	for (theIndex = 0; theIndex < mNumCommands; theIndex++)
		if (inCommand == *commandsP++)
			return theIndex + 1;
	
	return 0;				// Command not found
}


// ---------------------------------------------------------------------------
//		е FindNextCommand
// ---------------------------------------------------------------------------
//	Pass back the next command in the Menu
//		On entry, ioIndex is the position of an item (0 is allowed)
//		On exit, ioIndex is the position of the next item
//			If ioIndex is greater than the number of commands in the Menu
//				function returns false (and outCommand is unchanged).
//			Otherwise, function returns true and returns the command number
//				of the item after the input index
//
//	Use this function to iterate over all commands in a Menu:
//		Int16	index = 0;
//		Int32	command;
//		while (theMenu->FindNextCommand(index, command)) {
//			// Do something with command
//		}

- (BOOL) findNextCommand: (Int16 *)ioIndex : (Int32 *)outCommand
{
	BOOL cmdFound = NO;

	if (*ioIndex < 0)					// Safety check for negative items
		*ioIndex = 0;					// Set to zero so index is valid

	if (*ioIndex < mNumCommands) {		// Index is in range
										// Lookup command number
		*outCommand = (*mCommandNums)[*ioIndex++];
		cmdFound = YES;
	}
	
	return cmdFound;
}


// ---------------------------------------------------------------------------
//		е SetCommand
// ---------------------------------------------------------------------------
//	Set the command number for a Menu item

- setCommand: (Int16)inIndex : (CommandT)inCommand
{
									// Do nothing if inIndex is out of range
	Int16 menuLength = CountMItems(mMacMenuH);

	if ((inIndex > 0) && (inIndex <= menuLength)) {
		Int16 origNumCommands;

		if (inIndex > mNumCommands) {
									// Setting command for item beyond end
									//   end of command list
			
									// Grow command list
			if (mCommandNums == nil) {
				mCommandNums = (Int32 **)NewHandle(inIndex * sizeof(CommandT));
			}
			else {
				SetHandleSize((Handle)mCommandNums,
							  inIndex * sizeof(CommandT));
			}

			origNumCommands = mNumCommands;
			mNumCommands = inIndex;
			
			if (inIndex > origNumCommands + 1) {
			
				// There are items between the last original command
				// and the one to set. We must set the command for
				// these items to cmd_UseMenuItem.
				// Example:
				//		3 items in command list originally
				//		SetCommand for item 6
				//		Items 4, 5, 6 previously had no entry in command list
				//			(command list was shorter than number of items
				//			in the Menu)
				//		Set command for items 4 and 5 to cmd_UseMenuItem
				
				Int16 newDefaults = inIndex - origNumCommands - 1;
				CommandT *cp = *mCommandNums + origNumCommands;
				do {
					*cp++ = cmd_UseMenuItem;
				} while (--newDefaults);
			}
		}
									// Store command for this item
		(*mCommandNums)[inIndex - 1] = inCommand;
	}

	return self;
}


// ---------------------------------------------------------------------------
//		е InsertCommand
// ---------------------------------------------------------------------------
//	Insert an item with the specified text and command number after
//	particular item
//
//	NOTE: This function does not support adding multiple menu items
//		using "Return" or "Semicolon" characters within inItemText

- insertCommand: (Str255)inItemText : (CommandT)inCommand : (Int16)inAfterItem
{
									// Determine insertion index. It's
									//   usually one plus the after index.
	Int16 menuLength = CountMItems(mMacMenuH);
	Int16 itemToInsert = inAfterItem + 1;

	if (itemToInsert < 1)
		itemToInsert = 1;			// Insert at beginning of Menu
	else if (itemToInsert > menuLength) {
									// Append to end of Menu
		itemToInsert = menuLength + 1;
	}
									// Put item in Mac Menu
	InsertMenuItem(mMacMenuH, inItemText, itemToInsert - 1);

	if (itemToInsert <= mNumCommands) {
									// Inserting into middle of list
									// Command count increases by one
									//   and command table grows
		SetHandleSize((Handle)mCommandNums,
					  (mNumCommands + 1) * sizeof(CommandT));
		mNumCommands++;
									// Shift up commands beyond
									//    insertion point
		BlockMoveData(*mCommandNums + itemToInsert - 1,
				  *mCommandNums + itemToInsert,
				  (mNumCommands - itemToInsert) * sizeof(CommandT));
	}
									// Store command for inserted item
	[self setCommand: itemToInsert : inCommand];

	return self;
}


// ---------------------------------------------------------------------------
//		е RemoveCommand
// ---------------------------------------------------------------------------
//	Remove the Menu item with the specified command

- removeCommand: (CommandT)inCommand
{
										// Lookup index for command
	Int16 itemToRemove = [self indexFromCommand: inCommand];

	if (itemToRemove != 0)				// Command found
		[self removeItem: itemToRemove]; // Remove associated menu item

	return self;
}


// ---------------------------------------------------------------------------
//		е RemoveItem
// ---------------------------------------------------------------------------
//	Remove the Menu item at the specified position

- removeItem: (Int16)inItemToRemove
{
	if (inItemToRemove <= 0)
		return self;
	
										// Remove item from Mac Menu
	DeleteMenuItem(mMacMenuH, inItemToRemove);
		
	if (inItemToRemove <= mNumCommands) {
										// Item to remove has a command
										// Shift down commands above the
										//   item to remove
		BlockMoveData(*mCommandNums + inItemToRemove,
				  *mCommandNums + inItemToRemove - 1,
				  (mNumCommands - inItemToRemove) * sizeof(CommandT));

										// Decrease count of commands and
										//   shrink command table
		SetHandleSize((Handle)mCommandNums,
					  --mNumCommands * sizeof(CommandT));
	}

	return self;
}


// ---------------------------------------------------------------------------
//		е GetNextMenu
// ---------------------------------------------------------------------------
//	Return the next Menu in the linked list

- getNextMenu
{
	return mNextMenu;
}


// ---------------------------------------------------------------------------
//		е SetNextMenu
// ---------------------------------------------------------------------------
//	Set the Menu after this one in the linked list

- setNextMenu: inMenu
{
	mNextMenu = inMenu;
	return self;
}


// ---------------------------------------------------------------------------
//		е IsInstalled
// ---------------------------------------------------------------------------
//	Return whether the Menu is installed in the MenuBar

- (BOOL) isInstalled
{
	return mIsInstalled;
}


// ---------------------------------------------------------------------------
//		е SetInstalled
// ---------------------------------------------------------------------------
//	Specify whether the Menu is installed in the MenuBar

- setInstalled: (BOOL)inInstalled
{
	mIsInstalled = inInstalled;
	return self;
}

@end
