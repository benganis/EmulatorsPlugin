//
//  EmulatorsForceQuitController.m
//  EmulatorsPlugIn 2.1
//
//  Created by bgan1982@mac.com (Ben) on 7/22/09.
//
//  $Author$
//  $Date$
//  $Rev$ 
//  $HeadURL$

#import "EmulatorsForceQuitController.h"

@implementation EmulatorsForceQuitController

- (id)init;
{
	if (DEBUG_MODE) NSLog(@"EmulatorsForceQuitController - init");
	self = [super init];
	if (self == nil) return nil;
	
	[self addLabel:@"com.bgan1982.Emulators.EmulatorsForceQuitController"];
	[self setListTitle:@"Force Quit"];
	
	_items = [[NSMutableArray alloc] initWithObjects:nil];
	_fileListArray = [[NSMutableArray alloc] initWithObjects:nil];
	
	NSString *bundlePath = @"/System/Library/CoreServices/Finder.app/Contents/PlugIns/Emulators.frappliance";
	bundle = [NSBundle bundleWithPath:bundlePath];
	
	id list = [self list];
	[list setDatasource: self];
	return self;
}

- (void)dealloc
{
	if (DEBUG_MODE) NSLog(@"EmulatorsForceQuitController - dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[self list] setDatasource: nil];
	
	id obj;
	while((obj = [[_items objectEnumerator] nextObject]) != nil)
		[_items removeObject:obj];
	while((obj = [[_fileListArray objectEnumerator] nextObject]) != nil)
		[_fileListArray removeObject:obj];
	[_items release];
	[_fileListArray release];
	
	[super dealloc];  
}

- (long)defaultIndex
{
	return 0;
}

- (void)itemSelected:(long)fp8
{
	if (DEBUG_MODE) NSLog([NSString stringWithFormat:@"EmulatorsForceQuitController - itemSelected, row=%i",fp8]);
	switch (fp8)
	{
		case 0:
			break;
	}
}

// Data source methods:
- (float)heightForRow:(long)row		{ return 0.0f; }
- (BOOL)rowSelectable:(long)row		{ return YES;}
- (long)itemCount					{ return (long)[_items count];}
- (id)itemForRow:(long)row			{ return [_items objectAtIndex:row]; }
- (long)rowForTitle:(id)title		{ return (long)[_items indexOfObject:title]; }
- (id)titleForRow:(long)row			{ return [[_items objectAtIndex:row] title]; }

// Partially borrowed from SapphireCompatibilityClasses:
- (long)getSelection
{
	BRListControl *list = [self list];
	NSMethodSignature *signature = [list methodSignatureForSelector:@selector(selection)];
	NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
	[selInv setSelector:@selector(selection)];
	[selInv invokeWithTarget:list];
	long row = 0;
	[selInv getReturnValue:&row];
	return row;
}

@end
