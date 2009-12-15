//
//  BackRowHelper.h
//  System
//
//  Created by ash on 04.03.09.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <BackRow/BRRenderDisplayLink.h>
#import <Foundation/Foundation.h>


@interface BackRowHelper : NSObject {
@private
	BOOL screenSaverWasEnabled;
	NSWorkspace *workspace;
	id oldFirstResponder;
	NSString *pidOfRunningApp;
	BRRenderDisplayLink *displayManager;
}

+ (BackRowHelper *)sharedInstance;

- (BOOL)runApplicationWithIdentifier:(NSString *)appIdentifier withName:(NSString *)appName withPath:(NSString *)appPath;
- (NSString *)runScriptWithPathToScript:(NSString *)scriptPath WaitForScript:(BOOL) waitForScript;
- (BOOL)quitApplicationWithPID: (NSString *)pid;
- (BOOL)quitApplication;
- (void)hideFrontRowSetResponderTo:(id)responder;
- (void)showFrontRow;
- (BRImage *)getIconOfApplication:(NSString *)pathToApplication;
- (BRImage *)getIconOfFile:(NSString *)pathToFile;

@end

// Gesture events have a dictionary defining the touch points and other info.
typedef enum {
	kBREventOriginatorRemote = 1,
	kBREventOriginatorGesture = 3
} BREventOriginator;

// For AppleTV 2.4
typedef enum {
	// for originator kBREventOriginatorRemote
	kBREventRemoteActionMenu = 1,
	kBREventRemoteActionMenuHold,
	kBREventRemoteActionUp,
	kBREventRemoteActionDown,
	kBREventRemoteActionPlay,
	kBREventRemoteActionLeft,
	kBREventRemoteActionRight,
	
	kBREventRemoteActionPlayHold = 20,
	
	// Gestures, for originator kBREventOriginatorGesture
	kBREventRemoteActionTap = 30,
	kBREventRemoteActionSwipeLeft,
	kBREventRemoteActionSwipeRight,
	kBREventRemoteActionSwipeUp,
	kBREventRemoteActionSwipeDown
	
} BREventRemoteAction;