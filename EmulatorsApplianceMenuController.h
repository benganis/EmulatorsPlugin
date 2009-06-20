//
//  EmulatorsApplianceMenuController.h
//  EmulatorsPlugIn 1.5
//
//  Created by bgan1982@mac.com (Ben) on 6/14/08.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "BackRowHelper.h"

@interface EmulatorsApplianceMenuController : BRMediaMenuController
{
	int padding[16];	// credit is due here to SapphireCompatibilityClasses!!

	NSString *identifier;
	NSString *altIdentifier;
	NSString *name;
	NSString *path;
	NSString *startupScript;
	NSString *upScript;
	NSString *downScript;
	NSString *leftScript;
	NSString *rightScript;
	NSArray *selectedFileExtensions;
	BackRowHelper *helper;

	BOOL emulatorRunning;
	BOOL tappedOnce;
	long prevCount;
	long startCount;
	NSString *selectedFilename;

	NSWorkspace *workspace;

	// Data source variables:
	NSMutableArray *_items;
	NSMutableArray *_fileListArray;
}

- (id)initWithIdentifier:(NSString *)initId withName:(NSString *)initName withPath:(NSString *)initPath 
		  withExtensions:(NSArray *)initExtensions;
- (void)listMoreFiles;
- (void)clearFileList;
- (void)setAltIdentifier:(NSString *)altId;
- (void)setStartupScript:(NSString *)aScript;
- (void)setUpScript:(NSString *)aScript;
- (void)setDownScript:(NSString *)aScript;
- (void)setLeftScript:(NSString *)aScript;
- (void)setRightScript:(NSString *)aScript;

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
