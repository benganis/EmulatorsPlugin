	//
//  BRRenderer.h
//  Emulators
//
//  Created by ash on 16.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BRRenderer.h>
#import <objc/objc-runtime.h>


@interface EPRenderer : BRRenderer {

}

- (BRRenderContext *) context;
- (CARenderer*) renderer;
- (void) setRenderer:(CARenderer*) theRenderer;

@end
