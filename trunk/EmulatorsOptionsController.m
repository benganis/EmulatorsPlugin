//
//  EmulatorsAlertController.h
//  EmulatorsPlugIn 2.1
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import "EmulatorsOptionsController.h"
#import "EmulatorsDisableController.h"
#import "EmulatorsForceQuitController.h"

@implementation EmulatorsOptionsController

- (id)init;
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - init");
	self = [super init];
	if (self == nil) return nil;
	
	[self addLabel:@"com.bgan1982.Emulators.EmulatorsApplianceMenuController"];
	[self setListTitle:@"Emulators Options"];
	
	_items = [[NSMutableArray alloc] initWithObjects:nil];
	_fileListArray = [[NSMutableArray alloc] initWithObjects:nil];
	
	fileManager = [NSFileManager defaultManager];
	NSString *bundlePath = @"/System/Library/CoreServices/Finder.app/Contents/PlugIns/Emulators.frappliance";
	bundle = [NSBundle bundleWithPath:bundlePath];
	
	int i;
	for(i=0; i<=4; i++)
	{
		NSString *str;
		BOOL isDir = FALSE;

		if (i==0) { str = @"About EmulatorsPlugIn..."; }
		else if (i==1) { str = @"Reset Emulators Preferences"; }
		else if (i==2) { str = @"Reset PlugIn Preferences"; }
		else if (i==3) { str = @"Kill Finder"; }
		else if (i==4) { str = @"Reboot AppleTV"; }
		
		/* Next version:
		if (i==0) { str = @"About EmulatorsPlugIn..."; }
		else if (i==1) { str = @"Reset Emulators Preferences"; }
		else if (i==2) { str = @"Reset PlugIn Preferences"; }
		else if (i==3) { str = @"Enable/Disable Emulators"; isDir = TRUE; }
		else if (i==4) { str = @"Force Quit"; isDir = TRUE; }
		else if (i==5) { str = @"Kill Finder"; }
		else if (i==6) { str = @"Reboot AppleTV"; }
		*/
		 
		[_fileListArray addObject:str];
		id item;
		if (isDir) item = [BRTextMenuItemLayer folderMenuItem];
		else item = [BRTextMenuItemLayer menuItem];
		[item setTitle:str];
		[_items addObject:item];
	}
	
	id list = [self list];
	[list setDatasource: self];
	return self;
}

- (void)dealloc
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[[self list] setDatasource: nil];
	
	id obj;
	while((obj = [[_items objectEnumerator] nextObject]) != nil)
		[_items removeObject:obj];
	while((obj = [[_fileListArray objectEnumerator] nextObject]) != nil)
		[_fileListArray removeObject:obj];
	[_items release];
	[_fileListArray release];
	
	if (disableController != nil) { [disableController release]; }
	if (forceQuitController != nil) { [forceQuitController release]; }
	
	[super dealloc];  
}

- (long)defaultIndex
{
	return 0;
}

- (void)itemSelected:(long)fp8
{
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsApplianceMenuController - itemSelected, row=%i",fp8]);
	switch (fp8)
	{
		case 0:
			[self aboutEmulatorsPlugIn];
			break;
		case 1:
			[self resetEmulatorPreferences];
			break;
		case 2:
			[self resetPlugInPreferences];
			break;
		case 3:
			[self killFinder];
			break;
		case 4:
			[self rebootAppleTV];
			break;
		
		/* Next Version:
		case 0:
			[self aboutEmulatorsPlugIn];
			break;
		case 1:
			[self resetEmulatorPreferences];
			break;
		case 2:
			[self resetPlugInPreferences];
			break;
		case 3:
			[self disableEmulatorsMenu];
			break;
		case 4:
			[self forceQuitMenu];
			break;
		case 5:
			[self killFinder];
			break;
		case 6:
			[self rebootAppleTV];
			break;
		 */
	}
}


- (void)aboutEmulatorsPlugIn
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - aboutEmulatorsPlugIn");

	NSString *bundlePath = @"/System/Library/CoreServices/Finder.app/Contents/PlugIns/Emulators.frappliance";
	bundle = [NSBundle bundleWithPath:bundlePath];
	NSString *vString, *moreString;
	vString = [@"Version: " stringByAppendingString:[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]];
	if (DEBUG_MODE) { moreString = @"DEBUG mode is ON\n\n"; }
	else { moreString = @""; }
	moreString = [moreString stringByAppendingString:@"by bgan1982@mac.com (Ben)\n\n"];
	moreString = [moreString stringByAppendingString:@"http://code.google.com/p/emulatorsplugin\nhttp://wiki.awkwardtv.org/wiki/EmulatorsPlugIn"];

	BRAlertController *alert = [BRAlertController alertOfType:0 titled:@"About Emulators PlugIn..." primaryText:vString secondaryText:moreString];
	[[self stack] pushController:alert];
}

- (void)resetEmulatorPreferences
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - resetEmulatorPreferences");
	
	NSString *source = [bundle pathForResource:@"com.bannister.boycottadvance" ofType:@"plist"];
	NSString *destination = [@"~/Library/Preferences/com.bannister.boycottadvance.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	source = [bundle pathForResource:@"com.bannister.genesisplus" ofType:@"plist"];
	destination = [@"~/Library/Preferences/com.bannister.genesisplus.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	source = [bundle pathForResource:@"com.bannister.mugrat" ofType:@"plist"];
	destination = [@"~/Library/Preferences/com.bannister.mugrat.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	source = [bundle pathForResource:@"com.bannister.nestopia" ofType:@"plist"];
	destination = [@"~/Library/Preferences/com.bannister.nestopia.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	source = [bundle pathForResource:@"com.Gerrit.sixtyforce" ofType:@"plist"];
	destination = [@"~/Library/Preferences/com.Gerrit.sixtyforce.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	source = [bundle pathForResource:@"net.mame.mameosx" ofType:@"plist"];
	destination = [@"~/Library/Preferences/net.mame.mameosx.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	BRAlertController *alert = [BRAlertController alertOfType:0 titled:@""
			primaryText:@"Emulator preferences have been reset." secondaryText:@""];
	[[self stack] pushController:alert];

}

- (void)disableEmulatorsMenu
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - disableEmulatorsMenu");
	
	if (disableController != nil) { [[EmulatorsDisableController alloc] init]; }
	[[self stack] pushController:disableController];
}

- (void)resetPlugInPreferences
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - resetPlugInPreferences");
	
	NSString *source = [bundle pathForResource:@"defaults" ofType:@"plist"];
	NSString *destination = [@"~/Library/Preferences/com.bgan1982.EmulatorsPlugIn.plist" stringByExpandingTildeInPath];
	[fileManager removeFileAtPath:destination handler:nil];
	[fileManager copyPath:source toPath:destination handler:nil];
	
	BRAlertController *alert = [BRAlertController alertOfType:0 titled:@""
			primaryText:@"PlugIn preferences have been reset." secondaryText:@"FrontRow will relaunch in 3 seconds."];
	[[self stack] pushController:alert];
	
	NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 3.0];
	[NSThread sleepUntilDate:future];
	
	[self killFinder];
}

- (void)forceQuitMenu
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - forceQuitMenu");
	
	if (forceQuitController != nil) { [[EmulatorsForceQuitController alloc] init]; }
	[[self stack] pushController:forceQuitController];
}

- (void)killFinder
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - killFinder");
	[[BackRowHelper sharedInstance] hideFrontRowSetResponderTo:self];
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"KillFinder" ofType:@"sh"]
							 arguments:[NSArray arrayWithObjects:nil]];
}

- (void)rebootAppleTV
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - restartAppleTV");
	[[BackRowHelper sharedInstance] hideFrontRowSetResponderTo:self];
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"RestartAppleTV" ofType:@"sh"]
							 arguments:[NSArray arrayWithObjects:nil]];
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
