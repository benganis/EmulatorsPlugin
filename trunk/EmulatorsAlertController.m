//
//  EmulatorsAlertController.h
//  EmulatorsPlugIn 2.0
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import "EmulatorsAlertController.h"

@implementation EmulatorsAlertController

- (BOOL)runEmulatorWithIdentifier:(NSString *)aIdentifier withName:(NSString *)aName
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - runEmulatorWithIdentifier");
	
	workspace = [NSWorkspace sharedWorkspace];
	identifier = aIdentifier;
	name = aName;
	tappedOnce = NO;
	helper = [BackRowHelper sharedInstance];

	NSLog(@"runEmulatorWithIdentifier - opening application %@",identifier);
	BOOL emulatorRunning = [workspace launchApplication:identifier];
	if (emulatorRunning) [helper hideFrontRowSetResponderTo:self];
	
	// NSImage *theIcon = [workspace iconForFile:[workspace fullPathForApplication:identifier]];
	// CGImageRef *imgRef = ???
	// [self->_image setImage:[BRImage imageWithCGImageRef:imgRef]];
	
	return emulatorRunning;
}

- (void)setAltIdentifier:(NSString *)altId
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - setAltIdentifier");
	altIdentifier = altId;
}

- (void)setUpScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - setUpScript");
	upScript = aScript;
}

- (void)setDownScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - setDownScript");
	downScript = aScript;
}

- (void)setLeftScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - setLeftScript");
	leftScript = aScript;
}

- (void)setRightScript:(NSString *)aScript
{
	if (DEBUG_MODE) NSLog(@"EmulatorsAlertController - setRightScript");
	rightScript = aScript;
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
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"apps = %@",apps]);
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"pids = %@",pids]);
	
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
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsAlertController - getEmulatorPID: %@ returned %i",
						   identifier,thePID]);
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
			tappedOnce = NO;
			[helper showFrontRow];
			tappedOnce = NO;
			
			return YES;
			break;
			
		case 65673:		// tap play
			if (DEBUG_MODE) NSLog(@"brEventAction: tap play -- returning to menu");			
			
			tappedOnce = NO;
			[helper showFrontRow];
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
	[theScript release];
	[error release];
}

@end
