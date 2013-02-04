//
//  ButtonImages.h
//  TT
//
//  Created by Kotatsu RIN on 10/01/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TT_Define.h"


@interface ButtonImages : NSObject {
	NSMutableArray *buttonImages_n;
	NSMutableArray *buttonImages_h;
	UIImage *arrow_left;
	UIImage *arrow_right;
	UIImage *copy_icon;
	UIImage *copy_icon_h;
	UIImage *weekday_icon;
	UIImage *saturday_icon;
	UIImage *holiday_icon;
	UIImage *everyday_icon;
	BOOL loadDone;
}

@property (nonatomic, retain) NSMutableArray *buttonImages_n;
@property (nonatomic, retain) NSMutableArray *buttonImages_h;
@property (nonatomic, retain) UIImage *arrow_left;
@property (nonatomic, retain) UIImage *arrow_right;
@property (nonatomic, retain, getter=the_copy_icon) UIImage *copy_icon;
@property (nonatomic, retain, getter=the_copy_icon_h) UIImage *copy_icon_h;
@property (nonatomic, retain) UIImage *weekday_icon;
@property (nonatomic, retain) UIImage *saturday_icon;
@property (nonatomic, retain) UIImage *holiday_icon;
@property (nonatomic, retain) UIImage *everyday_icon;

@property (nonatomic, assign) BOOL loadDone;

+ (id)instance;
- (UIImage *)timeButtonImage_n:(int)min;
- (UIImage *)timeButtonImage_h:(int)min;

@end
