//
//  BRRenderer.m
//  Emulators
//
//  Created by ash on 16.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EPRenderer.h"


@implementation EPRenderer

- (BRRenderContext *) context
{
	Class klass = [self class];
	Ivar ret = class_getInstanceVariable(klass, "_context");
	
	return *(BRRenderContext * *)(((char *)self)+ret->ivar_offset);
}

- (CARenderer*) renderer {
	Class klass = [self class];
	Ivar ret = class_getInstanceVariable(klass, "_renderer");
	
	return *(CARenderer * *)(((char *)self)+ret->ivar_offset);
}

- (void) setRenderer:(CARenderer*) theRenderer{
	Class klass = [self class];
	Ivar ret = class_getInstanceVariable(klass, "_renderer");
	
	*(CARenderer * *)(((char *)self)+ret->ivar_offset) = theRenderer;
}


@end
