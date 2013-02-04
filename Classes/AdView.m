//
//  AdView.m
//  TT
//
//  Created by Kotatsu RIN on 09/12/01.
//  Copyright 2009 con3office. All rights reserved.
//

#import "AdView.h"


@implementation AdView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.frame = frame;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	context = UIGraphicsGetCurrentContext();

	CGContextSetLineWidth(context, 0.2);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 48.0f);
	CGContextAddLineToPoint(context, 320.0f, 48.0f);
	CGContextStrokePath(context);
//	CGContextRelease(context);
}


- (void)dealloc {
    [super dealloc];
}


@end
