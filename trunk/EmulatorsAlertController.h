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


@interface EmulatorsAlertController : BRAlertController
{
	int padding[16];
	NSString *identifier;
	NSString *name;
	NSString *upScript;
	NSString *downScript;
	NSString *leftScript;
	NSString *rightScript;
	BackRowHelper *helper;
	
	BOOL tappedOnce;

	NSWorkspace *workspace;
	
	id oldFirstResponder;
}


- (BOOL)runEmulatorWithIdentifier:(NSString *)aIdentifier withName:(NSString *)aName;
- (void)setUpScript:(NSString *)aScript;
- (void)setDownScript:(NSString *)aScript;
- (void)setLeftScript:(NSString *)aScript;
- (void)setRightScript:(NSString *)aScript;
- (int)getEmulatorPID;
- (void)runAppleScript:(NSString *)aScript;

@end
