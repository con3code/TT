//
//  ButtonImages.m
//  TT
//
//  Created by Kotatsu RIN on 10/01/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ButtonImages.h"


@implementation ButtonImages

@synthesize buttonImages_n;
@synthesize buttonImages_h;
@synthesize arrow_left;
@synthesize arrow_right;
@synthesize copy_icon;
@synthesize copy_icon_h;
@synthesize weekday_icon;
@synthesize saturday_icon;
@synthesize holiday_icon;
@synthesize everyday_icon;

@synthesize loadDone;


static ButtonImages *_instance = nil;

+ (id)instance {
	@synchronized(self) {
		if (!_instance) {
			_instance = [[self alloc] init];
		}
	}
	return _instance;
}


- (id)init {
	if (self == [super init]) {
		
		buttonImages_n = [[NSMutableArray alloc] init];
		buttonImages_h = [[NSMutableArray alloc] init];
		loadDone = NO;
		
	}
	return self;
}


- (UIImage *)timeButtonImage_n:(int)min {
	NSLog(@"tbi_n");
	return [buttonImages_n objectAtIndex:min];
}

- (UIImage *)timeButtonImage_h:(int)min {
	NSLog(@"tbi_h");
	return [buttonImages_h objectAtIndex:min];
}

@end
