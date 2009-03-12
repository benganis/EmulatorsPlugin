//
//  EmulatorsAlertController.h
//  EmulatorsPlugIn 1.4
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import "EmulatorsAlertController.h"

@implementation EmulatorsAlertController

- (BOOL)runEmulatorWithIdentifier:(NSString *)aIdentifier withName:(NSString *)aName
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - runEmulatorWithIdentifier");
	
	workspace = [NSWorkspace sharedWorkspace];
	identifier = aIdentifier;
	name = aName;
	tappedOnce = NO;

	NSLog(@"Opening application %@",identifier);
	BOOL emulatorRunning = [workspace launchApplication:identifier];
	if (emulatorRunning) [self hideFrontRow];
	
	// NSImage *theIcon = [workspace iconForFile:[workspace fullPathForApplication:identifier]];
	// CGImageRef *imgRef = ???
	// [self->_image setImage:[BRImage imageWithCGImageRef:imgRef]];
	
	return emulatorRunning;
}

- (void)setUpScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setUpScript");
	upScript = aScript;
}

- (void)setDownScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setDownScript");
	downScript = aScript;
}

- (void)setLeftScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setLeftScript");
	leftScript = aScript;
}

- (void)setRightScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsApplianceMenuController - setRightScript");
	rightScript = aScript;
}


- (void)hideFrontRow
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - hideFrontRow");
	
	@try
	{
		float ATV_version = [[[BRSettingsFacade sharedInstance] versionSoftware] floatValue];
		if (DEBUG_MODE) NSLog(@"ATV_version = %f",ATV_version);
		
		if (ATV_version > 2.29)
		{
			if (DEBUG_MODE) NSLog(@"hideFrontRow - _setNewDisplay:kCGNullDirectDisplay");
			[[BRDisplayManagerCore sharedInstance] _setNewDisplay:kCGNullDirectDisplay];
			if (DEBUG_MODE) NSLog(@"hideFrontRow - releaseAllDisplays");
			[[BRDisplayManagerCore sharedInstance] releaseAllDisplays];
		}
		else
		{
			if (DEBUG_MODE) NSLog(@"hideFrontRow : BRDisplayManagerDisplayOffline");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerDisplayOffline"
																object:[BRDisplayManager sharedInstance]];
			if (DEBUG_MODE) NSLog(@"hideFrontRow : BRDisplayManagerStopRenderingNotification");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerStopRenderingNotification"
																object:[BRDisplayManager sharedInstance]];
		}
		
		/*
		BRPreferenceManager *prefs = [BRPreferenceManager sharedPreferences];
		ScreenSaverTimeout = [prefs integerForKey:@"ScreenSaverTimeout" forDomain:@"com.apple.Finder" withValueForMissingPrefs:0];
		[prefs _setValue:[NSNumber numberWithInt:0] forKey:@"ScreenSaverTimeout" forDomain:@"com.apple.Finder" sync:true];
		if (DEBUG_MODE) NSLog(@"ScreenSaverTimeout was %i",ScreenSaverTimeout);
		if (DEBUG_MODE) NSLog(@"ScreenSaverTimeout is %i",
			[prefs integerForKey:@"ScreenSaverTimeout" forDomain:@"com.apple.Finder" withValueForMissingPrefs:0]);
		*/
	}
	@catch (NSException *theErr)
	{
		if (DEBUG_MODE) NSLog(@"hideFrontRow : exception thrown...\n  name: %@ \n  reason: %@", [theErr name], [theErr reason]);
	}
	
	// Hack to send remote events to brEventAction of this BRAlertController, even when display is offline
	BREventManager *eventManager = [BREventManager sharedManager];
	oldFirstResponder = [eventManager firstResponder];
	[eventManager setFirstResponder:self];
}

- (void)showFrontRow
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - showFrontRow");
	tappedOnce = NO;
	
	// Hack to return sending remote events to BRBaseAppliance when we're done
	BREventManager *eventManager = [BREventManager sharedManager];
	[eventManager setFirstResponder:oldFirstResponder];
	
	@try
	{
		float ATV_version = [[[BRSettingsFacade sharedInstance] versionSoftware] floatValue];
		if (DEBUG_MODE) NSLog(@"ATV_version = %f",ATV_version);
		
		if (ATV_version > 2.29)
		{
			if (DEBUG_MODE) NSLog(@"showFrontRow - _setNewDisplay:kCGDirectMainDisplay");
			[[BRDisplayManagerCore sharedInstance] _setNewDisplay:kCGDirectMainDisplay];
			if (DEBUG_MODE) NSLog(@"showFrontRow - captureAllDisplays");
			[[BRDisplayManagerCore sharedInstance] captureAllDisplays];
		}
		else
		{
			if (DEBUG_MODE) NSLog(@"showFrontRow : BRDisplayManagerResumeRenderingNotification");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerResumeRenderingNotification"
																object:[BRDisplayManager sharedInstance]];
			if (DEBUG_MODE) NSLog(@"hideFrontRow : BRDisplayManagerDisplayOnline");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerDisplayOnline"
																object:[BRDisplayManager sharedInstance]];
		}
		
		/*
		BRPreferenceManager *prefs = [BRPreferenceManager sharedPreferences];
		if (DEBUG_MODE) NSLog(@"ScreenSaverTimeout was %i",
			[prefs integerForKey:@"ScreenSaverTimeout" forDomain:@"com.apple.Finder" withValueForMissingPrefs:0]);
		[prefs _setValue:[NSNumber numberWithInt:ScreenSaverTimeout] forKey:@"ScreenSaverTimeout" 
			   forDomain:@"com.apple.Finder" sync:true];
		if (DEBUG_MODE) NSLog(@"ScreenSaverTimeout is %i",
			[prefs integerForKey:@"ScreenSaverTimeout" forDomain:@"com.apple.Finder" withValueForMissingPrefs:0]);
		*/
	}
	@catch (NSException *theErr)
	{
		if (DEBUG_MODE) NSLog (@"showFrontRow : exception thrown...\n  name: %@ \n  reason: %@", [theErr name], [theErr reason]);
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
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"getEmulatorPID:%@ returned %i",ident,thePID]);
	return thePID;
}

- (BOOL)brEventAction:(id)event
{	
	unsigned int hashVal = (uint32_t)([event page] << 16 | [event usage]);
	if ([(BRControllerStack *)[self stack] peekController] != self) hashVal = 0;
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"brEventAction - hashVal = %i",hashVal]);

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

			int emuPID = [self getEmulatorPID];
			if (emuPID != 0)
			{
				NSLog(@"killEmulatorAndShowFrontRow : killing pid %i",emuPID);
				[NSTask launchedTaskWithLaunchPath:@"/bin/kill"
										 arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",emuPID],nil]];
			}
			[[self stack] popController];
			
			NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0];
			[NSThread sleepUntilDate:future];
			[self showFrontRow];
			tappedOnce = NO;
			
			return YES;
			break;
			
		case 65673:		// tap play
			if (DEBUG_MODE) NSLog(@"brEventAction: tap play -- returning to menu");			
			
			[self showFrontRow];
			[[self stack] popController];
			tappedOnce = NO;
			
			return YES;
			break;
	}
	return NO;
}

- (void)runAppleScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"runAppleScript - script = %@", aScript);
	
	// Remove the headache of enabling UI scripting for novice users
	[NSTask launchedTaskWithLaunchPath:[[NSBundle bundleForClass:[self class]] 
										pathForResource:@"EnableUIScripting" ofType:@"sh"] arguments:@""];
	
	NSAppleScript *theScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:aScript,identifier]];
	NSDictionary *error = [[NSDictionary alloc] init];
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

@end
