//
//  EmulatorsApplianceMenuController.h
//  EmulatorsPlugIn 1.4
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

@interface EmulatorsApplianceMenuController : BRMediaMenuController
{
	int padding[16];	// credit is due here to SapphireCompatibilityClasses!!

	NSString *identifier;
	NSString *name;
	NSString *path;
	NSString *startupScript;
	NSString *upScript;
	NSString *downScript;
	NSString *leftScript;
	NSString *rightScript;
	NSArray *selectedFileExtensions;

	BOOL emulatorRunning;
	BOOL tappedOnce;
	int ScreenSaverTimeout;
	NSString *selectedFilename;

	NSWorkspace *workspace;

	// Data source variables:
	NSMutableArray *_items;
	NSMutableArray *_fileListArray;
}

- (id)initWithIdentifier:(NSString *)initId withName:(NSString *)initName withPath:(NSString *)initPath 
		  withExtensions:(NSArray *)initExtensions;
- (void)setStartupScript:(NSString *)aScript;
- (void)setUpScript:(NSString *)aScript;
- (void)setDownScript:(NSString *)aScript;
- (void)setLeftScript:(NSString *)aScript;
- (void)setRightScript:(NSString *)aScript;

- (void)hideFrontRow;
- (void)showFrontRow;
- (int)getEmulatorPID;
- (void)killEmulatorAndShowFrontRow;
- (void)runAppleScript:(NSString *)aScript;

// Data source methods:
- (float)heightForRow:(long)row;
- (BOOL)rowSelectable:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (long)rowForTitle:(id)title;
- (id)titleForRow:(long)row;
- (long)getSelection;

@end
