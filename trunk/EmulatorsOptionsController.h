//
//  EmulatorsAlertController.h
//  EmulatorsPlugIn 1.5
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <BackRowHelper.h>

@interface EmulatorsOptionsController : BRMenuController
{
	int padding[16];	// credit is due here to SapphireCompatibilityClasses!!
	
	NSFileManager *fileManager;
	NSBundle *bundle;
	
	// Data source variables:
	NSMutableArray *_items;
	NSMutableArray *_fileListArray;
}

- (void)resetEmulatorPreferences;
- (void)resetPlugInPreferences;
- (void)enableQuartzExtreme;
- (void)killFinder;

@end
