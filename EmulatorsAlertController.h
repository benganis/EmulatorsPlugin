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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <BackRowHelper.h>


@interface EmulatorsAlertController : BRAlertController
{
	int padding[16];
	NSString *identifier;
	NSString *altIdentifier;
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
- (void)setAltIdentifier:(NSString *)altId;
- (void)setUpScript:(NSString *)aScript;
- (void)setDownScript:(NSString *)aScript;
- (void)setLeftScript:(NSString *)aScript;
- (void)setRightScript:(NSString *)aScript;
- (int)getEmulatorPID;
- (void)runAppleScript:(NSString *)aScript;

@end
