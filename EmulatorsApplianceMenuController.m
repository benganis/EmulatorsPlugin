//
//  EmulatorsApplianceMenuController.m
//  EmulatorsPlugIn 2.1
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import "EmulatorsApplianceMenuController.h"

@implementation EmulatorsApplianceMenuController

// Overloading the standard init method finally allows recursive menus
- (id)init
{
	return [self initWithIdentifier:nil	withName:nil withPath:nil withExtensions:nil];
}

// My initialization routine
- (id)initWithIdentifier:(NSString *)initId withName:(NSString *)initName 
				withPath:(NSString *)initPath withExtensions:(NSArray *)initExtensions
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - initWithIdentifier:%@ withName:%@ withPath:%@",
						  initId,initName,initPath);

	self = [super init];
	if (self == nil) return nil;
	
	identifier = initId;
	[identifier retain];
	altIdentifier = nil;
	name = initName;
	[name retain];
	path = initPath;
	[path retain];
	selectedFileExtensions = initExtensions;
	[selectedFileExtensions retain];

	prevCount = 0;
	lastSelectedRow = 0;
	isScript = NO;
	emulatorRunning = NO;
	tappedOnce = NO;
	menuLoaded = NO;
	childControllers = [[NSMutableDictionary alloc] init];
	
	workspace = [NSWorkspace sharedWorkspace];
	helper = [BackRowHelper sharedInstance];
	
	[self addLabel:@"com.bgan1982.Emulators.EmulatorsApplianceMenuController"];
	[self setListTitle:[NSString stringWithFormat:@"%@ ROMs", name]];

	_items = [[NSMutableArray alloc] initWithObjects:nil];
	_fileListArray = [[NSMutableArray alloc] initWithObjects:nil];
	
	return self;
}

- (void)listMoreFiles
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - listMoreFiles");
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *dirContents = [NSMutableArray arrayWithArray:[fileManager directoryContentsAtPath:path]];
	long i, currCount, temp;
	BOOL addMoreItem = false;
	long totalCount = [dirContents count];
	
	// Remove hidden files and images from directory list
	temp=totalCount;
	for(i=totalCount-1; i>=0; i--)
	{
		NSString *idStr = [dirContents objectAtIndex:i];
		NSString *extension = [[idStr pathExtension] lowercaseString];
		if (([idStr hasPrefix:@"."]) || ([extension isEqualToString:@"jpg"]) || ([extension isEqualToString:@"png"]))
		{
			[dirContents removeObjectAtIndex:i];
			temp--;
		}
	}
	totalCount=temp;
	
	if (totalCount <= prevCount) return;
	
	[[self list] setDatasource: nil];

	// Remove the "More..." item
	if ((prevCount > 0) && ([[_fileListArray lastObject] isEqualToString:@"###More###"]))
	{
		[_fileListArray removeLastObject];
		[_items removeLastObject];
	}

	currCount = totalCount;
	
	/*
	if (totalCount <= (prevCount + 250))
	{
		currCount = totalCount - prevCount;
	}
	else
	{
		currCount = prevCount + 250;
		addMoreItem = true;
	}
	*/

	if (DEBUG_MODE) NSLog(@"listMoreFiles - totalCount=%i, prevCount=%i, currCount=%i",totalCount,prevCount,currCount);
	
	for ( i = prevCount; i < currCount; i++ )
	{
		NSString *idStr = [dirContents objectAtIndex:i];
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
		else
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
	if (addMoreItem)
	{
		NSString *moreItem = @"###More###";
		[_fileListArray addObject:moreItem];
		id item = [BRTextMenuItemLayer menuItem];
		[item setTitle:@"More..."];
		[_items addObject:item];
	}
	
	[[self list] setDatasource: self];
	if (! menuLoaded) { menuLoaded = YES; }
	if (lastSelectedRow > [_items count]-1) { lastSelectedRow = [_items count]-1; }
	
	if (DEBUG_MODE) NSLog(@"listMoreFiles - Setting selected object to %i",lastSelectedRow);
	[(BRListControl *)[self list] setSelection:lastSelectedRow];

	prevCount = currCount;
}

- (void)dealloc
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - dealloc");
	
	tappedOnce = NO;
	[identifier release];
	[name release];
	[path release];
	[selectedFileExtensions release];
	if (altIdentifier != nil) [altIdentifier release];
	if (startupScript != nil) [startupScript release];
	if (upScript != nil) [upScript release];
	if (downScript != nil) [downScript release];
	if (leftScript != nil) [leftScript release];
	if (rightScript != nil) [rightScript release];
	
	[self clearFileList];
	[_items release];
	[_fileListArray release];
	
	id key;
	while((key = [[[childControllers allKeys] objectEnumerator] nextObject]) != nil)
	{
		id controller = [childControllers objectForKey:key];
		[childControllers removeObjectForKey:key];
		[controller release];
	}
	[childControllers release];
	
	[super dealloc];
	[helper showFrontRow];
}

- (void)clearFileList
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - clearFileList");

	if (lastImageControl != nil) { [lastImageControl release]; lastImageControl = nil; }
	
	[[self list] setDatasource: nil];
	menuLoaded = NO;
	//[self refreshControllerForModelUpdate];
	
	id obj;
	while((obj = [[_items objectEnumerator] nextObject]) != nil)
		[_items removeObject:obj];
	while((obj = [[_fileListArray objectEnumerator] nextObject]) != nil)
		[_fileListArray removeObject:obj];
	prevCount = 0;
}

- (void)controlWasActivated
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - controlWasActivated");
	[self listMoreFiles];
	[super controlWasActivated];
}

- (void)controlWasDeactivated
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - controlWasDeactivated");
	[self clearFileList];
	[super controlWasDeactivated];
}


- (void)setAltIdentifier:(NSString *)altId
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setAltIdentifier");
	altIdentifier = altId;
	[altIdentifier retain];
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

- (void)setIsScript:(BOOL)aBOOL
{
	isScript = aBOOL;
}

- (long)defaultIndex
{
	return 0;
}

- (id)previewControlForItem:(long)fp8
{
	if (lastImageControl != nil) { [lastImageControl release]; lastImageControl = nil; }
	if (! menuLoaded) { return nil; }
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - previewControlForItem, row=%i",fp8);
	
	lastSelectedRow = fp8;

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
			lastImageControl = imageControl;
			return imageControl;
		}
	}
	return nil;
}

- (void)itemSelected:(long)fp8
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - itemSelected, row=%i",fp8);
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	
	if (! emulatorRunning)
	{
		selectedFilename = [_fileListArray objectAtIndex:fp8];
		if ([selectedFilename isEqualToString:@"###More###"])
		{
			[self listMoreFiles];
			return;
		}
		NSString *pathToROM = [path stringByAppendingPathComponent:selectedFilename];
		BOOL isDir = false;
		[[NSFileManager defaultManager] fileExistsAtPath:pathToROM isDirectory:&isDir];
		if (isDir)
		{
			pathToROM = [pathToROM stringByAppendingString:@"/"];
			
			EmulatorsApplianceMenuController *menu;
			menu = [childControllers objectForKey:pathToROM];
			if (menu != nil)
			{
				if (DEBUG_MODE) NSLog(@"itemSelected - Found previous controller with pathToROM=%@",pathToROM);
			}
			else
			{
				if (DEBUG_MODE) NSLog(@"itemSelected - Creating new EmulatorsApplianceMenuController for %@",pathToROM);
				menu = [[EmulatorsApplianceMenuController alloc] initWithIdentifier:identifier withName:name 
													withPath:pathToROM withExtensions:selectedFileExtensions];
				[childControllers setValue:menu forKey:pathToROM];
				
				if (altIdentifier != nil) [menu setAltIdentifier:altIdentifier];
				if (startupScript != nil) [menu setStartupScript:startupScript];
				if (upScript != nil) [menu setUpScript:upScript];
				if (downScript != nil) [menu setDownScript:downScript];
				if (leftScript != nil) [menu setLeftScript:leftScript];
				if (rightScript != nil) [menu setRightScript:rightScript];
			}
			if (DEBUG_MODE) NSLog(@"itemSelected - Pushing controller onto stack");
			[[self stack] pushController:menu];
			return;
		}
		
		if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsApplianceMenuController - itemSelected, row=%i", 
							   selectedFilename]);
		
		// Open the current ROM with the current Emulator using LaunchServices
		NSLog(@"brEventAction: Launch Services is Opening %@ with application %@",pathToROM,identifier);
		[self clearFileList];
		
		// Push dummy alert before hiding FrontRow
		BRAlertController *alert = [BRAlertController alertOfType:0 titled:@"" primaryText:@"" secondaryText:@""];
		[[self stack] pushController:alert];
		
		[helper hideFrontRowSetResponderTo:self];
		
		if (isScript == YES)
		{
			NSLog(@"itemSelected: RunScript.sh is opening %@ with executable %@",pathToROM,identifier);
			NSString *dir = [identifier stringByDeletingLastPathComponent];
			NSString *emu = [[identifier pathComponents] lastObject];
			NSString *game = [[[pathToROM pathComponents] lastObject] stringByDeletingPathExtension];
			[self setAltIdentifier:emu];
			
			NSTask *runScriptTask = [[NSTask alloc] init];
			
			[runScriptTask setLaunchPath:[bundle pathForResource:@"RunScript" ofType:@"sh"]];
			[runScriptTask setArguments:[NSArray arrayWithObjects: dir, emu, game, nil]];
			[runScriptTask launch];

			// Wait for RunScript.sh to start emulator
			// [runScriptTask waitUntilExit];
			NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0];
			[NSThread sleepUntilDate:future];

			[runScriptTask release];
			
			if ([self getEmulatorPID] == 0) emulatorRunning = NO;
			else emulatorRunning = YES;
		}
		else
		{
			NSLog(@"itemSelected: Launch Services is opening %@ with application %@",pathToROM,identifier);
			emulatorRunning = [workspace openFile:pathToROM withApplication:identifier];
		}
		
		if (! emulatorRunning)
		{
			NSLog(@"itemSelected: Could not launch emulator! - going back to FrontRow...");
			[helper showFrontRow];
			[self listMoreFiles];
			BRAlertController *alert = [BRAlertController alertOfType:0
				titled:@"Error"
				primaryText:[NSString stringWithFormat:@"%@ could not be opened",identifier]
				secondaryText:[NSString stringWithFormat:@"ROM = %@",selectedFilename]];
			[[self stack] pushController:alert];
			return;
		}

		if (DEBUG_MODE) NSLog(@"itemSelected - SavePathToROM");
		[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"SavePathToROM" ofType:@"sh"] 
								 arguments:[NSArray arrayWithObjects:path, nil]];
		
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
	int thePID = 0;
	
	BOOL checkAltId;
	if (altIdentifier != nil)
	{
		checkAltId = YES;
	}
	else
	{
		checkAltId = NO;
	}

	NSArray *apps = [workspace valueForKeyPath:@"launchedApplications.NSApplicationName"];
	NSArray *pids = [workspace valueForKeyPath:@"launchedApplications.NSApplicationProcessIdentifier"];
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"apps = %@", apps]);
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"pids = %@", pids]);
	
	int i;
	for (i=0; i<[apps count]; i++)
	{
		if ([identifier isEqualToString:[apps objectAtIndex:i]])
		{
			thePID = [[pids objectAtIndex:i] intValue];
		}
		else if (checkAltId)
		{
			if ([altIdentifier isEqualToString:[apps objectAtIndex:i]])
			{
				thePID = [[pids objectAtIndex:i] intValue];
			}
		}
	}
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsApplianceMenuController - getEmulatorPID: %@ returned %i",
							   identifier,thePID]);
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
		
		// kill twice for good measure
		emuPID = [self getEmulatorPID];
		if (emuPID != 0)
		{
			NSLog(@"killEmulatorAndShowFrontRow : killing pid %i",emuPID);
			[NSTask launchedTaskWithLaunchPath:@"/bin/kill"
									 arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",emuPID],nil]];
		}

		if (DEBUG_MODE) NSLog(@"killEmulatorAndShowFrontRow - ForgetPathToROM");
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"ForgetPathToROM" ofType:@"sh"] 
								 arguments:[NSArray arrayWithObjects:nil]];
	}
	emulatorRunning = NO;
	
	if (isScript)
	{
		NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0];
		[NSThread sleepUntilDate:future];
	}
	
	[helper showFrontRow];
	
	// Wait a little bit for emulator to quit
	NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 0.3];
	[NSThread sleepUntilDate:future];

	[self listMoreFiles];
	
	// Pop dummy alert
	[[self stack] popController];

	tappedOnce = NO;
}



- (BOOL)brEventAction:(BREvent *)event
{
	if (emulatorRunning)
	{
		//unsigned int hashVal = (uint32_t)([event page] << 16 | [event usage]);
		//if ([(BRControllerStack *)[self stack] peekController] != self) hashVal = 0;
		//if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"brEventAction - hashVal = %i",hashVal]);
		
		if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"brEventAction - event = %i",[event remoteAction]]);
		
		// Check here to make sure emulator is really running
		if ([self getEmulatorPID] == 0)
		{
			emulatorRunning = NO;
			tappedOnce = NO;
			[helper showFrontRow];
			[self listMoreFiles];
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
		
		switch([event remoteAction])
		{
			case kBREventRemoteActionUp:		// tap up
				if (DEBUG_MODE) NSLog(@"brEventAction: tap up");
				if (upScript != nil)
				{
					[self runAppleScript:upScript];
					return YES;
				}
				break;
			case kBREventRemoteActionDown:		// tap down
				if (DEBUG_MODE) NSLog(@"brEventAction: tap down");
				if (downScript != nil)
				{
					[self runAppleScript:downScript];
					return YES;
				}
				break;
			case kBREventRemoteActionLeft:		// tap left
				if (DEBUG_MODE) NSLog(@"brEventAction: tap left");
				if (leftScript != nil)
				{
					[self runAppleScript:leftScript];
					return YES;
				}
				break;
			case kBREventRemoteActionRight:		// tap right
				if (DEBUG_MODE) NSLog(@"brEventAction: tap right");		
				if (rightScript != nil)
				{
					[self runAppleScript:rightScript];
					return YES;
				}
				break;
			case kBREventRemoteActionMenu:		// tap menu
				if (DEBUG_MODE) NSLog(@"brEventAction: tap menu -- quitting emulator");
				
				[self killEmulatorAndShowFrontRow];
				tappedOnce = NO;
				
				return YES;
				break;
				
			case kBREventRemoteActionPlay:		// tap play
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
	[theScript release];
	[error release];
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
