//
//  EmulatorsAppliance.h
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
#import "EmulatorsApplianceMenuController.h"

@interface EmulatorsAppliance : BRBaseAppliance
{
	EmulatorsApplianceMenuController *menuController;
}

@end
