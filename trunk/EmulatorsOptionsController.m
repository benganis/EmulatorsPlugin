//
//  EmulatorsAlertController.h
//  EmulatorsPlugIn 1.4
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import "EmulatorsOptionsController.h"

@implementation EmulatorsOptionsController

- (id)init;
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - initWithApplicance");
	id returnid = [super init];
	
	[self addLabel:@"com.bgan1982.Emulators.EmulatorsApplianceMenuController"];
	[self setListTitle:@"Emulators Options"];
	
	_items = [[NSMutableArray alloc] initWithObjects:nil];
	_fileListArray = [[NSMutableArray alloc] initWithObjects:nil];
	
	fileManager = [NSFileManager defaultManager];
	NSString *bundlePath = @"/System/Library/CoreServices/Finder.app/Contents/PlugIns/Emulators.frappliance";
	bundle = [NSBundle bundleWithPath:bundlePath];
	
	NSEnumerator *enumerator = [[bundle objectForInfoDictionaryKey:@"FRApplianceOptionsCategoryDescriptors"] 
								objectEnumerator];
	id obj;
	while((obj = [enumerator nextObject]) != nil) 
	{
		// if (DEBUG_MODE) NSLog(@"Adding option %@",[obj valueForKey:@"identifier"]);
		[_fileListArray addObject:[obj valueForKey:@"identifier"]];
		id item = [[BRTextMenuItemLayer alloc] init];
		[item setTitle:[obj valueForKey:@"name"]];
		[_items addObject:item];
	}
	
	id list = [self list];
	[list setDatasource: self];
	return returnid;
}

- (void)dealloc
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
			[self resetEmulatorPreferences];
			break;
		case 1:
			[self resetPlugInPreferences];
			break;
		case 2:
			[self enableQuartzExtreme];
			break;
		case 3:
			[self killFinder];
			break;
	}
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
	/*
	BRAlertController *alert = [BRAlertController alertOfType:0 titled:@""
			primaryText:@"Emulator preferences have been reset." secondaryText:@""];
	[[self stack] pushController:alert];
	*/
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

- (void)enableQuartzExtreme
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - enableQuartzExtreme");
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"EnableQuartz" ofType:@"sh"] 
							 arguments:[NSArray arrayWithObjects:nil]];
	/*
	BRAlertController *alert = [BRAlertController alertOfType:0 titled:@""
			primaryText:@"Quartz Extreme has been enabled." secondaryText:@""];
	[[self stack] pushController:alert];
	*/
}

- (void)killFinder
{
	if (DEBUG_MODE) NSLog(@"EmulatorsOptionsController - killFinder");
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"KillFinder" ofType:@"sh"]
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
