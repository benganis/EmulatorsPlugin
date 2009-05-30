//
//  EmulatorsApplianceMenuController.m
//  EmulatorsPlugIn 1.5
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import "EmulatorsApplianceMenuController.h"

@implementation EmulatorsApplianceMenuController

// Overloading the standard init method finally allows recursive menus
- (id)init
{
	return [self initWithIdentifier:nil	withName:nil withPath:nil withExtensions:nil];
}

// My initialization routine
- (id)initWithIdentifier:(NSString *)initId withName:(NSString *)initName withPath:(NSString *)initPath 
		  withExtensions:(NSArray *)initExtensions;
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - initWithIdentifier:%@ withName:%@ withPath:%@",
						  initId,initName,initPath);

	self = [super init];
	if (self == nil) return nil;
	
	workspace = [NSWorkspace sharedWorkspace];
	helper = [BackRowHelper sharedInstance];
	identifier = initId;
	[identifier retain];
	name = initName;
	[name retain];
	path = initPath;
	[path retain];
	selectedFileExtensions = initExtensions;
	[selectedFileExtensions retain];
	emulatorRunning = NO;
	tappedOnce = NO;
	
	[self addLabel:@"com.bgan1982.Emulators.EmulatorsApplianceMenuController"];
	[self setListTitle:[NSString stringWithFormat:@"%@ ROMs", name]];

	_items = [[NSMutableArray alloc] initWithObjects:nil];
	_fileListArray = [[NSMutableArray alloc] initWithObjects:nil];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	long i, count = [[fileManager directoryContentsAtPath:path] count];
	if (count > 100) count = 100;

	for ( i = 0; i < count; i++ )
	{
		// idStr is the actual filename
		NSString *idStr = [[fileManager directoryContentsAtPath:path] objectAtIndex:i];
		NSString *extension = [[idStr pathExtension] lowercaseString];
		BOOL isDir = false;
		[[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:idStr]
														   isDirectory:&isDir];
		
		if (isDir)
		{
			[_fileListArray addObject:idStr];
			id item = [BRTextMenuItemLayer folderMenuItem];
			[item setTitle:idStr];
			[_items addObject:item];
		}
		else if ((! [idStr hasPrefix:@"."]) && (! [extension isEqualToString:@"jpg"]) && (! [extension isEqualToString:@"png"]))
		{
			BOOL addCurrentFile = true;
			NSString *fileName;		// fileName is what will be displayed in the menu

			if (selectedFileExtensions != nil)	// if only certain file extensions are enabled, then other files will be hidden
			{
				if ( [selectedFileExtensions containsObject:extension] )
				{
					fileName = [idStr stringByDeletingPathExtension];
				}
				else
				{
					addCurrentFile = false;
				}
			}
			else	// otherwise, set the menu entry to the whole filename
			{
				fileName = [idStr copy];
			}
			
			// create a new menu item and set the filename
			if (addCurrentFile)
			{
				[_fileListArray addObject:idStr];
				id item = [BRTextMenuItemLayer menuItem];
				[item setTitle:fileName];
				[_items addObject:item];
			}
		}
	}

	id list = [self list];
	[list setDatasource: self];
	return self;
}

- (void)dealloc
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - dealloc");
	tappedOnce = NO;
	[identifier release];
	[name release];
	[path release];
	[selectedFileExtensions release];
	if (startupScript != nil) [startupScript release];
	if (upScript != nil) [upScript release];
	if (downScript != nil) [downScript release];
	if (leftScript != nil) [leftScript release];
	if (rightScript != nil) [rightScript release];
	[super dealloc];
	[helper showFrontRow];
}

- (void)setStartupScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setStartupScript");
	startupScript = aScript;
	[startupScript retain];
}

- (void)setUpScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setUpScript");
	upScript = aScript;
	[upScript retain];
}

- (void)setDownScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setDownScript");
	downScript = aScript;
	[downScript retain];
}

- (void)setLeftScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setLeftScript");
	leftScript = aScript;
	[leftScript retain];
}

- (void)setRightScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setRightScript");
	rightScript = aScript;
	[rightScript retain];
}

- (long)defaultIndex
{
	return 0;
}

- (id)previewControlForItem:(long)fp8
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - previewControlForItem, row=%i",fp8);

	NSArray *extensionsArray = [NSArray arrayWithObjects:@".png", @".jpg", nil];
	NSEnumerator *enumerator = [extensionsArray objectEnumerator];

	id imageExtension;
	while((imageExtension = [enumerator nextObject]) != nil)
	{
		NSString *imagePath = [[path stringByAppendingPathComponent:[[_fileListArray objectAtIndex:fp8]
									stringByDeletingPathExtension]] stringByAppendingString:imageExtension];
		BOOL isDir = false;
		BOOL imageExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir];
		
		if ((imageExists) && !(isDir))
		{
			if (DEBUG_MODE) NSLog(@"previewControlForItem - ImagePath=%@",imagePath);
			BRImageControl *imageControl = [[BRImageControl alloc] init];
			[imageControl setImage:[BRImage imageWithPath:imagePath]];
			return imageControl;
		}
	}
	return nil;
}

- (void)itemSelected:(long)fp8
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - itemSelected, row=%i",fp8);
	
	if (! emulatorRunning)
	{
		selectedFilename = [_fileListArray objectAtIndex:fp8];
		NSString *pathToROM = [path stringByAppendingPathComponent:selectedFilename];
		BOOL isDir = false;
		[[NSFileManager defaultManager] fileExistsAtPath:pathToROM isDirectory:&isDir];
		if (isDir)
		{
			pathToROM = [pathToROM stringByAppendingString:@"/"];
			
			if (DEBUG_MODE) NSLog(@"itemSelected - Creating new EmulatorsApplianceMenuController for %@",pathToROM);
			EmulatorsApplianceMenuController *menu = 
				[[EmulatorsApplianceMenuController alloc] 
					initWithIdentifier:identifier withName:name withPath:pathToROM withExtensions:selectedFileExtensions];
			 
			if (startupScript != nil) [menu setStartupScript:startupScript];
			if (upScript != nil) [menu setUpScript:upScript];
			if (downScript != nil) [menu setDownScript:downScript];
			if (leftScript != nil) [menu setLeftScript:leftScript];
			if (rightScript != nil) [menu setRightScript:rightScript];

			if (DEBUG_MODE) NSLog(@"itemSelected - Pushing new controller onto stack");
			[[self stack] pushController:menu];
			return;
		}
		
		if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsApplianceMenuController - itemSelected, row=%i", 
							   selectedFilename]);
		
		// Open the current ROM with the current Emulator using LaunchServices
		NSLog(@"brEventAction: Opening %@ with application %@",pathToROM,identifier);
		emulatorRunning = [workspace openFile:pathToROM withApplication:identifier];
		
		if (! emulatorRunning)
		{
			[helper showFrontRow];
			BRAlertController *alert = [BRAlertController alertOfType:0
				titled:@"Error"
				primaryText:[NSString stringWithFormat:@"%@ could not be opened",identifier]
				secondaryText:[NSString stringWithFormat:@"ROM = %@",selectedFilename]];
			[[self stack] pushController:alert];
			return;
		}

		if (DEBUG_MODE) NSLog(@"itemSelected - SavePathToROM");
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"SavePathToROM" ofType:@"sh"] 
								 arguments:[NSArray arrayWithObjects:path, nil]];
		
		[helper hideFrontRowSetResponderTo:self];
		
		if (startupScript != nil) [self runAppleScript:startupScript];
		return;
	}
	else
	{
		[self killEmulatorAndShowFrontRow];
		return;
	}
}

- (int)getEmulatorPID
{
	int thePID=0;
	NSString *ident;
	
	// Bad hack because 'zsnes.app' launches 'ZSNES' process
	if ([identifier isEqualToString:@"zsnes"])
	{
		ident = @"ZSNES";
	}
	else
	{
		ident = identifier;
	}

	NSArray *apps = [workspace valueForKeyPath:@"launchedApplications.NSApplicationName"];
	NSArray *pids = [workspace valueForKeyPath:@"launchedApplications.NSApplicationProcessIdentifier"];
	// if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"apps = %@",apps]);
	// if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"pids = %@",pids]);
	
	int i;
	for (i=0; i<[apps count]; i++)
	{
		if ([ident isEqualToString:[apps objectAtIndex:i]])
		{
			thePID = [[pids objectAtIndex:i] intValue];
		}
	}
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsApplianceMenuController - getEmulatorPID: %@ returned %i",
						   ident,thePID]);
	return thePID;
}

- (void)killEmulatorAndShowFrontRow
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - killEmulatorAndShowFrontRow");

	int emuPID = [self getEmulatorPID];
	if (emuPID != 0)
	{
		NSLog(@"killEmulatorAndShowFrontRow : killing pid %i",emuPID);
		[NSTask launchedTaskWithLaunchPath:@"/bin/kill"
								 arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",emuPID],nil]];

		if (DEBUG_MODE) NSLog(@"killEmulatorAndShowFrontRow - ForgetPathToROM");
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"ForgetPathToROM" ofType:@"sh"] 
								 arguments:[NSArray arrayWithObjects:nil]];
	}
	emulatorRunning = NO;
	
	[helper showFrontRow];
	tappedOnce = NO;
}

- (BOOL)brEventAction:(id)event
{	
	if (emulatorRunning)
	{
		unsigned int hashVal = (uint32_t)([event page] << 16 | [event usage]);
		if ([(BRControllerStack *)[self stack] peekController] != self) hashVal = 0;
		if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"brEventAction - hashVal = %i",hashVal]);
		
		// Check here to make sure emulator is really running
		if ([self getEmulatorPID] == 0)
		{
			emulatorRunning = NO;
			tappedOnce = NO;
			[helper showFrontRow];
			[[self stack] popController];
			return YES;
		}
		
		if (tappedOnce)
		{
			if (DEBUG_MODE) NSLog(@"brEventAction - Ignoring duplicate event");
			tappedOnce = NO;
			return NO;
		}
		tappedOnce = YES;
		
		switch (hashVal)
		{
			case 65676:		// tap up
				if (DEBUG_MODE) NSLog(@"brEventAction: tap up");
				if (upScript != nil)
				{
					[self runAppleScript:upScript];
					return YES;
				}
				break;
			case 65677:		// tap down
				if (DEBUG_MODE) NSLog(@"brEventAction: tap down");
				if (downScript != nil)
				{
					[self runAppleScript:downScript];
					return YES;
				}
				break;
			case 65675:		// tap left
				if (DEBUG_MODE) NSLog(@"brEventAction: tap left");
				if (leftScript != nil)
				{
					[self runAppleScript:leftScript];
					return YES;
				}
				break;
			case 65674:		// tap right
				if (DEBUG_MODE) NSLog(@"brEventAction: tap right");		
				if (rightScript != nil)
				{
					[self runAppleScript:rightScript];
					return YES;
				}
				break;
			case 65670:		// tap menu
				if (DEBUG_MODE) NSLog(@"brEventAction: tap menu -- quitting emulator");
				
				[self killEmulatorAndShowFrontRow];
				//[[self stack] popController];
				tappedOnce = NO;
				
				return YES;
				break;
				
			case 65673:		// tap play
				if (DEBUG_MODE) NSLog(@"brEventAction: tap play -- resetting emulator");			
				
				NSString *pathToROM = [path stringByAppendingPathComponent:selectedFilename];
				NSLog(@"brEventAction: Opening %@ with application %@",pathToROM,identifier);
				[workspace openFile:pathToROM withApplication:identifier];
				tappedOnce = NO;
				
				return YES;
				break;
		}
		return NO;
	}
	else
	{
		return [super brEventAction:event];
	}
}

- (void)runAppleScript:(NSString *)aScript
{	
	NSAppleScript *theScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:aScript,identifier]];
	NSDictionary *error = [[NSDictionary alloc] init];
	if (DEBUG_MODE) NSLog(@"runAppleScript - script = %@", aScript);
	NSAppleEventDescriptor *descriptor = [theScript executeAndReturnError:&error];
	if (descriptor == nil)
	{
		NSLog(@"runAppleScript failed, error = %@",error);
	}
	else
	{
		int i;
		for(i = 1; i <= [descriptor numberOfItems]; i++)
		{
			NSAppleEventDescriptor *subDescriptor = [descriptor descriptorAtIndex:i];
			NSLog(@"runAppleScript returned: %@",[subDescriptor stringValue]);
		}
	}
}

// Data source methods:
- (float)heightForRow:(long)row		{ return 0.0f; }
- (BOOL)rowSelectable:(long)row		{ return YES;}
- (long)itemCount					{ return (long)[_items count];}
- (id)itemForRow:(long)row			{ return [_items objectAtIndex:row]; }
- (long)rowForTitle:(id)title		{ return (long)[_items indexOfObject:title]; }
- (id)titleForRow:(long)row			{ return [[_items objectAtIndex:row] title]; }


// Partially borrowed from SapphireCompatibilityClasses:
- (long)getSelection
{
	BRListControl *list = [self list];
	NSMethodSignature *signature = [list methodSignatureForSelector:@selector(selection)];
	NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
	[selInv setSelector:@selector(selection)];
	[selInv invokeWithTarget:list];
	long row = 0;
	[selInv getReturnValue:&row];
	return row;
}

@end