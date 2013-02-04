//
//  TimeInputView.h
//  TimeInput
//
//  Created by Kotatsu RIN on 10/01/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonImages.h"
#import "TT_Define.h"

#define cg_context
//#define bitmaptest

@interface TimeInputView : UIView {

	id parent;
	int thisHour;
		
	void *data;
	CGContextRef cntx;
	int drawMode;
	int drawMin;
	UIImage *drawImage;
//	NSMutableArray *buttonImages_n;
//	NSMutableArray *buttonImages_h;
	
	BOOL singleTapReady;
	BOOL doubleTapReady;
	CGPoint tapPoint;

}

@property (nonatomic, retain) id parent;
@property (nonatomic, assign) int thisHour;

//@property (nonatomic, retain) NSMutableArray *buttonImages_n;
//@property (nonatomic, retain) NSMutableArray *buttonImages_h;


#ifdef bitmaptest
-(void)drawInContext;
#endif

#ifndef bitmaptest
-(void)drawInContext:(CGContextRef)currentCntx;
#endif

- (void)drawButtonImage;
- (void)drawButtonAll;
//- (void)drawButton;

@end
