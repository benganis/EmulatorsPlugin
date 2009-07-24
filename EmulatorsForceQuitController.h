//
//  EmulatorsForceQuitController.h
//  EmulatorsPlugIn 2.1
//
//  Created by bgan1982@mac.com (Ben) on 7/22/09.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <BackRowHelper.h>

@interface EmulatorsForceQuitController : BRMenuController
{
	int padding[16];	// credit is due here to SapphireCompatibilityClasses!!
	
	NSBundle *bundle;
	
	// Data source variables:
	NSMutableArray *_items;
	NSMutableArray *_fileListArray;
}

@end
