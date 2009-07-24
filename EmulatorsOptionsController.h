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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <BackRowHelper.h>
#import "EmulatorsDisableController.h"
#import "EmulatorsForceQuitController.h"

@interface EmulatorsOptionsController : BRMenuController
{
	int padding[16];	// credit is due here to SapphireCompatibilityClasses!!
	
	NSFileManager *fileManager;
	NSBundle *bundle;
	
	// Data source variables:
	NSMutableArray *_items;
	NSMutableArray *_fileListArray;
	
	EmulatorsDisableController *disableController;
	EmulatorsForceQuitController *forceQuitController;
}

- (void)aboutEmulatorsPlugIn;
- (void)resetEmulatorPreferences;
- (void)disableEmulatorsMenu;
- (void)resetPlugInPreferences;
- (void)forceQuitMenu;
- (void)killFinder;
- (void)rebootAppleTV;

@end
