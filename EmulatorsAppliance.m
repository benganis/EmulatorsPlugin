//
//  EmulatorsAppliance.m
//  EmulatorsPlugIn 2.1
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import "EmulatorsAppliance.h"
#import "EmulatorsApplianceMenuController.h"
#import "EmulatorsAlertController.h"
#import "EmulatorsOptionsController.h"

@implementation EmulatorsAppliance

// Override to allow FrontRow to load custom appliance plugins
+ (NSString *)className
{
    NSString *className = NSStringFromClass(self);
	NSRange result = [[BRBacktracingException backtrace] rangeOfString:@"(in BackRow)"];
	if (result.location != NSNotFound) className = @"MOVAppliance";
	
	// Set defaults for com.bgan1982.EmulatorsPlugIn.plist
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	if (DEBUG_MODE) NSLog(@"bundlePath=%@",[bundle bundlePath]);
	if (! [defaults persistentDomainForName:@"com.bgan1982.EmulatorsPlugIn"])
	{
		if (DEBUG_MODE) NSLog(@"EmulatorsAppliance is creating com.bgan1982.EmulatorsPlugIn.plist from defaults");
		
		// This will create a binary plist file
		// NSString *defaultPlist = [[NSBundle bundleForClass:[self class]] pathForResource:@"defaults" ofType:@"plist"];
		// NSDictionary *defaultDictionary = [NSDictionary dictionaryWithContentsOfFile:defaultPlist];
		// [defaults setPersistentDomain:defaultDictionary forName:@"com.bgan1982.EmulatorsPlugIn"];
		
		// This will create a xml plist file (more user friendly)
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *source = [bundle pathForResource:@"defaults" ofType:@"plist"];
		NSString *destination = [@"~/Library/Preferences/com.bgan1982.EmulatorsPlugIn.plist" stringByExpandingTildeInPath];
		[fileManager copyPath:source toPath:destination handler:nil];
	}
	else
	{
		if (DEBUG_MODE) NSLog(@"EmulatorsAppliance has found com.bgan1982.EmulatorsPlugIn.plist");
	}
	
	// Rebuild Launch Services for noobs
	if (DEBUG_MODE) NSLog(@"Rebuilding Launch Services...");
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"RebuildLaunchServices" ofType:@"sh"]
							 arguments:[NSArray arrayWithObjects:nil]];
	
	// Remove the headache of enabling UI scripting for novice users
	if (DEBUG_MODE) NSLog(@"Enabling UI Scripting...");
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"EnableUIScripting" ofType:@"sh"]
							 arguments:[NSArray arrayWithObjects:nil]];

	// Remove the headache of enabling UI scripting for novice users
	if (DEBUG_MODE) NSLog(@"Enabling Quartz and Quartz Extreme...");
	[NSTask launchedTaskWithLaunchPath:[bundle pathForResource:@"EnableQuartz" ofType:@"sh"]
							 arguments:[NSArray arrayWithObjects:nil]];
	
	return className;
}

+ (NSString *)rootMenuLabel
{
	return ( @"Emulators" );
}

- (id)controllerForIdentifier:(id)identifier args:(id) identifier2
{
	if (menuController != nil) { [menuController release]; }
	if (optionsController != nil) { [optionsController release]; }
	
	if ([identifier isEqualToString:@"Options"])
	{
		optionsController = [[EmulatorsOptionsController alloc] init];
		return optionsController;
	}
	
	// Get path from com.bgan1982.EmulatorsPlugIn.plist
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaultDictionary = [defaults persistentDomainForName:@"com.bgan1982.EmulatorsPlugIn"];
	NSArray *applianceCategoryArray = [defaultDictionary objectForKey:@"FRApplianceCategoryDescriptors"];
	NSEnumerator *enumerator = [applianceCategoryArray objectEnumerator];
	
	NSString *altIdentifier;
	NSString *path;
	NSString *name;
	NSString *startupScript;
	NSString *upScript;
	NSString *downScript;
	NSString *leftScript;
	NSString *rightScript;
	NSArray *fileExtensions;
	NSString *type;
	
	id obj;
	while((obj = [enumerator nextObject]) != nil) 
	{
		if ([identifier isEqualToString:[obj valueForKey:@"identifier"]])
		{
			altIdentifier = [obj valueForKey:@"alt-identifier"];
			path = [obj valueForKey:@"path"];
			name = [obj valueForKey:@"name"];
			startupScript = [obj valueForKey:@"startup-script"];
			upScript = [obj valueForKey:@"up-button-script"];
			downScript = [obj valueForKey:@"down-button-script"];
			leftScript = [obj valueForKey:@"left-button-script"];
			rightScript = [obj valueForKey:@"right-button-script"];
			fileExtensions = [[[obj valueForKey:@"file-extensions"] lowercaseString] componentsSeparatedByString:@","];
			type = [[obj valueForKey:@"type"] lowercaseString];
			
			if (DEBUG_MODE) NSLog(@"Extension array=%@", [fileExtensions description]);
		}
	}
	
	// If path is non-existent or blank, launch app without bringing up ROM list
	if ((path == nil) || ([path length] == 0))
	{
		EmulatorsAlertController *alert = 
			[[EmulatorsAlertController alloc] initWithType:0 titled:identifier primaryText:@"" secondaryText:@""];
		
		BOOL success = [alert runEmulatorWithIdentifier:identifier withName:name];
		if (! success)
		{
			[alert setPrimaryText:@"Error"];
			[alert setSecondaryText:[name stringByAppendingString:@" could not be launched."]];		
		}
		else
		{
			if (altIdentifier != nil) [alert setAltIdentifier: altIdentifier];
			if (upScript != nil) [alert setUpScript: upScript];
			if (downScript != nil) [alert setDownScript: downScript];
			if (leftScript != nil) [alert setLeftScript: leftScript];
			if (rightScript != nil) [alert setRightScript: rightScript];
			if (startupScript != nil) [alert runAppleScript:startupScript];
			if ([type isEqualToString:@"script"]) [alert setIsScript:YES];
		}
		
		return alert;
	}
	
	// Otherwise, check that path is valid
	BOOL isDir = false;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	if ((!exists) || (!isDir))
	{
		NSString *errorText = [@"The path " stringByAppendingString:path];
		if (!exists) errorText = [errorText stringByAppendingString:@" doesn't exist."];
		else [errorText stringByAppendingString:@" is not a directory."];
		
		BRAlertController *alert = [BRAlertController alertOfType:0
               titled:identifier
               primaryText:@"Error"
               secondaryText:errorText];
		return alert;
	}
	
	// Display a menu for path directory
	menuController = [[EmulatorsApplianceMenuController alloc] initWithIdentifier:identifier withName:name 
															withPath:path withExtensions:fileExtensions];

	if (altIdentifier != nil) [menuController setAltIdentifier: altIdentifier];
	if (startupScript != nil) [menuController setStartupScript: startupScript];
	if (upScript != nil) [menuController setUpScript: upScript];
	if (downScript != nil) [menuController setDownScript: downScript];
	if (leftScript != nil) [menuController setLeftScript: leftScript];
	if (rightScript != nil) [menuController setRightScript: rightScript];
	if ([type isEqualToString:@"script"]) [menuController setIsScript:YES];
	
	return menuController;
}


-(id)previewControlForIdentifier:(id)arg1
{
	if (DEBUG_MODE) NSLog(@"previewControlForIdentifier");

	NSString *pathToAppPng = [[NSBundle bundleForClass:[self class]] pathForResource:@"EmulatorsPlugIn" ofType:@"png"];
	BRImage *appIcon = [BRImage imageWithPath:pathToAppPng];
	
	BRImageAndSyncingPreviewController *iconControl = [[BRImageAndSyncingPreviewController alloc] init];
	
	[iconControl setImage:appIcon];
	[iconControl setReflectionAmount:0.00f];
	//[iconControl setReflectionOffset:-0.38f];
	return (iconControl);
}



// Populate appliance categories from com.bgan1982.EmulatorsPlugIn.plist
- (id)applianceCategories
{	
	NSMutableArray *categories = [NSMutableArray array];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaultDictionary = [defaults persistentDomainForName:@"com.bgan1982.EmulatorsPlugIn"];
	NSArray *applianceCategoryArray = [defaultDictionary objectForKey:@"FRApplianceCategoryDescriptors"];
	NSEnumerator *enumerator = [applianceCategoryArray objectEnumerator];
	
	id obj;
	while((obj = [enumerator nextObject]) != nil) 
	{
		BRApplianceCategory *category = [BRApplianceCategory categoryWithName:[BRLocalizedStringManager appliance:self
										localizedStringForKey:[obj valueForKey:@"name"] inFile:nil] 
										identifier:[obj valueForKey:@"identifier"] 
										preferredOrder:[[obj valueForKey:@"preferred-order"] floatValue]];
		// if (DEBUG_MODE) NSLog(@"Adding category=%@",[obj valueForKey:@"name"]);
		[categories addObject:category];
	}
	
	// Add new category for EmulatorsOptionsController
	[categories addObject:[BRApplianceCategory categoryWithName:@"Options" identifier:@"Options" preferredOrder:200]];

	return categories;
}

- (id)identifierForContentAlias:(id)fp8
{
	return @"Emulators";
}

- (id)applianceInfo
{
	return [BRApplianceInfo infoForApplianceBundle:[NSBundle bundleForClass:[self class]]];
}

@end
