//
//  TimeInputView.m
//  TimeInput
//
//  Created by Kotatsu RIN on 10/01/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimeInputView.h"
#import "TimeInputViewController.h"
#import "TTAppDelegate.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}


@implementation TimeInputView

@synthesize parent;
@synthesize thisHour;

//@synthesize buttonImages_n;
//@synthesize buttonImages_h;
 

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

#ifdef bitmaptest
		CGAffineTransform aTransform = self.transform;
		self.transform = CGAffineTransformScale(aTransform, 1.0, -1.0);
#endif
		

#ifdef bitmap
//		NSLog(@"mod: bitmapcntx");

		int width = self.bounds.size.width;
		int height = self.bounds.size.height;
		data = malloc(width * height *4);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();		
		cntx = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);	
		CGColorSpaceRelease(colorSpace);
#endif		
#ifdef bitmaptest
//		NSLog(@"mod: bitmapcntx");
		
		int width = self.bounds.size.width;
		int height = self.bounds.size.height;
		data = malloc(width * height *4);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();		
		cntx = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);	
		CGColorSpaceRelease(colorSpace);
#endif		

		
		/*
		NSInteger min;
		NSString *img_name_n;
		NSString *img_name_h;
		UIImage *buttonImage_n;
		UIImage *buttonImage_h;
		buttonImages_n = [[NSMutableArray alloc] init];
		buttonImages_h = [[NSMutableArray alloc] init];
		
		for (NSInteger j = 0; j < 6; j++) {
			
			for (NSInteger k = 0; k < 10; k++) {
				
				min = (j*10)+k;

				img_name_n = [[NSString alloc] initWithFormat:@"TB_n_%02d.png",min];
				img_name_h = [[NSString alloc] initWithFormat:@"TB_h_%02d.png",min];
				
				buttonImage_n = [UIImage imageNamed:img_name_n];
				[buttonImages_n addObject:buttonImage_n];
				buttonImage_h = [UIImage imageNamed:img_name_h];
				[buttonImages_h addObject:buttonImage_h];
//				NSLog(@"img: %d",min);
				[img_name_n release];
				[img_name_h release];
				
			}
		}
		*/
	}

#ifdef bitmaptest
	[self drawInContext];
#endif
	[self setNeedsDisplay];
	
    return self;
}





- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	singleTapReady = NO;
	doubleTapReady = NO;

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSInteger tapCount = [[touches anyObject] tapCount];
	tapPoint = [[touches anyObject] locationInView:self];
//	NSLog(@"Tap! x:%f y:%f",tapPoint.x,tapPoint.y);
	
	
	if (2 > tapCount) {
		if (![parent currentEditing]) {
			return;
		}
		singleTapReady = YES;
		[self performSelector:@selector(singleTap) withObject:nil afterDelay:0.2f];
	}
	else if (3 > tapCount) {
		doubleTapReady = YES;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
		[self performSelector:@selector(doubleTap) withObject:nil afterDelay:0.2f];
	}
/*
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doubleTap) object:nil];
		[self performSelector:@selector(tripleTap)];
	}
*/

}

- (void)singleTap {
	if (!singleTapReady) {
		return;
	}
	
	int x = tapPoint.x;
	int y = tapPoint.y;

	if (x <= 20) {return;}
	if (x >= 300) {return;}
	if (y <= 94) {return;}
	if (y >= 400) {return;}
	
	int i = (x-20)/28;
	int j = (y-94)/51;
	
	int m = (j*10)+i;
	NSString *minute = [NSString stringWithFormat:@"%02d",m];
	NSString *hour = [NSString stringWithFormat:@"%02d",thisHour];
	
	[parent tappedButton:self minute:m hour:thisHour minutestr:minute hourstr:hour];

//	setTimeButton(time, thisHour);
//	[parent setTimeButton:time atHour:0];

#ifdef bitmaptest
	[self drawInContext];
#endif
	[self setNeedsDisplay];
	
//	NSLog(@"Time: %d",m);

}

- (void)doubleTap {
	if (!doubleTapReady) {
		return;
	}
	if (tapPoint.y < 90) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Usage", nil) message:NSLocalizedString(@"You can edit this timetable in Editing Mode. Lets Try to tap [Edit] Button. Also you can cancel anything you change before tap [Done] Button, by tap [Cancel] Button.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
		[alert show];
	}
}

- (void)tripleTap {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Thankyou!", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
	[alert show];
}



- (void)drawButtonImage {

	UIImage *buttonImage_n;
	CGRect bRect;

	
	buttonImage_n = [UIImage imageNamed:@"TB_h_01.png"];
	bRect = CGRectMake(0, 0, 28, 43);

//	bPoint = CGPointMake(20+(28*k), 98+(51*j));
//	[buttonImage_n drawAtPoint:bPoint];
	CGContextDrawImage(cntx, bRect, buttonImage_n.CGImage);
	
//	drawImage = CGBitmapContextCreateImage(cntx);
	
	CGContextRelease(cntx);
	
	[self setNeedsDisplay];
	
}

- (void)drawButtonAll {
	[self setNeedsDisplay];
}

/*
- (void)drawButton {
	resetTimeButton();
	[parent resetTimeDisp];
	[self setNeedsDisplay];
}
*/

#ifdef cg_context


-(void)drawRect:(CGRect)rect
{	
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)currentCntx {
		
	NSInteger min;
	CGRect bRect;
	UIImage *buttonImage;
	
	ButtonImages *bi = [ButtonImages instance];

	/*
	bRect = CGRectMake(4, 190, 10, 24);
	[bi.arrow_left drawInRect:bRect];
	bRect = CGRectMake(304, 190, 10, 24);
	[bi.arrow_right drawInRect:bRect];
	*/
	
	for (NSInteger j = 0; j < 6; j++) {
		for (NSInteger k = 0; k < 10; k++) {
			
			int select = getTimeButton((j*10)+k, thisHour);
//			int select = [parent getTimeButton:(j*10)+k atHour:thisHour];
			min = (j*10)+k;
			
//			NSLog(@"min: context:%d",min);
			
			if (select) {
				buttonImage = [bi.buttonImages_h objectAtIndex:min];
			}
			else {
				buttonImage = [bi.buttonImages_n objectAtIndex:min];
			}
			
//			NSLog(@"mod: context");
			
			bRect = CGRectMake(20+(28*k), 98+(51*j), 28, -43);
			[buttonImage drawInRect:bRect];
			/*
			 CGContextSaveGState
			 CGContextSetBlendMode
			 CGContextSetAlpha
			 CGContextTranslateCTM
			 CGContextScaleCTM
			 CGContextDrawImage
			 CGContextRestoreGState
			 */
			buttonImage = nil;
			
		}
	}	
}

#endif //context

#ifdef bitmap

-(void)drawRect:(CGRect)rect
{	
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)currentCntx {
	
	
	NSInteger min;
	UIImage *buttonImage;
	CGRect bRect;
	
	for (NSInteger j = 0; j < 6; j++) {
		for (NSInteger k = 0; k < 10; k++) {
			
			int select = getTimeButton((j*10)+k, thisHour);
//			int select = [parent getTimeButton:(j*10)+k atHour:thisHour];
			min = (j*10)+k;

//			NSLog(@"min: bitmap:%d",min);
			
			if (select) {						
				buttonImage = [buttonImages_h objectAtIndex:min];
			}
			else {
				buttonImage = [buttonImages_n objectAtIndex:min];
			}
			
			bRect = CGRectMake(20+(28*k), 98+(51*j), 28, -43);

//			NSLog(@"mod: bitmap");
			CGContextDrawImage(cntx, bRect, buttonImage.CGImage);
			buttonImage = nil;			

#ifdef test
//			NSLog(@"mod: test");
			CGContextDrawImage(currentCntx, bRect, buttonImage.CGImage);
			buttonImage = nil;			
#endif


		}
	}
	
	
//	NSLog(@"mod: bitmap");
	CGImageRef image = CGBitmapContextCreateImage(cntx);
	CGContextDrawImage(currentCntx, CGRectMake(0, 0, 320, 460), image);
	CGImageRelease(image);	

}

#endif //bitmap

#ifdef bitmaptest

-(void)drawRect:(CGRect)rect
{
//	NSLog(@"mod: bitmaptest");
	CGContextRef currentCntx = UIGraphicsGetCurrentContext();
//	CGContextScaleCTM(currentCntx, 0.5, 0.5);
//	CGContextTranslateCTM(currentCntx, 160, 230);
	CGImageRef image = CGBitmapContextCreateImage(cntx);
	CGContextDrawImage(currentCntx, rect, image);
	CGImageRelease(image);	
}


-(void)drawInContext {
	
//	CGContextTranslateCTM(cntx, 160, 230);
//	CGContextScaleCTM(cntx, 0.5, 0.5);
		
	NSInteger min;
	UIImage *buttonImage;
	CGRect bRect;
	

	for (NSInteger j = 0; j < 6; j++) {
		for (NSInteger k = 0; k < 10; k++) {
			
			int select = getTimeButton((j*10)+k, thisHour);
			min = (j*10)+k;
			
			//			NSLog(@"min: %d",min);
			
			if (select) {						
				buttonImage = [buttonImages_h objectAtIndex:min];
			}
			else {
				buttonImage = [buttonImages_n objectAtIndex:min];
			}
			
			bRect = CGRectMake(20+(28*k), 98+(51*j), 28, -43);

//			NSLog(@"mod: bitmaptest");
			CGContextDrawImage(cntx, bRect, buttonImage.CGImage);
			buttonImage = nil;
			
		}
	}

	
}

#endif //bitmaptest


- (void)dealloc {
	[drawImage release];
//	[buttonImages_h release];
//	[buttonImages_n release];
#ifdef bitmap
	free(data);
	CGContextRelease(cntx);
#endif
    [super dealloc];
}


@end
