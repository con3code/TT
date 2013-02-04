//
//  BindedTimetable.m
//  TableSample
//
//  Created by Kotatsu RIN on 10/01/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BindedTimetable.h"

#define kTimeLabelFontSize 30
#define kKindLabelFontSize 14
#define kDestinationLabelFontSize 16
#define kDiffLabelFontSize 16

@implementation BindedTimetable

@synthesize R;
@synthesize G;
@synthesize B;
@synthesize A;

@synthesize ttColorImage;
@synthesize timeLabel;
@synthesize kindLabel;
@synthesize destinationLabel;
@synthesize diffLabel;
@synthesize secondGraph;

@synthesize diffHidden;
@synthesize diffMinus;
@synthesize secondHidden;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		
		cellViewRect = CGRectMake(0, 0, 320, 40);
		ttcolorPoint = CGPointMake(0, 0);
		timeLabelRect = CGRectMake(92, 1, 81, 38);
		kindLabelRect = CGRectMake(181, 2, 130, 19);
		destinationLabelRect = CGRectMake(180, 18, 130, 20);
		diffLabelRect = CGRectMake(11, 11, 62, 16);
		secondViewRect = CGRectMake(70, 11, 16, 16);
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef cellCntx = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(cellCntx, R, G, B, A);
	CGContextFillRect(cellCntx, cellViewRect);
	
	[ttColorImage drawAtPoint:ttcolorPoint];
	
	[[UIColor blackColor] set];
	[destinationLabel drawInRect:destinationLabelRect withFont:[UIFont systemFontOfSize:kDestinationLabelFontSize]];
	[kindLabel drawInRect:kindLabelRect withFont:[UIFont systemFontOfSize:kKindLabelFontSize]];

	[[UIColor whiteColor] set];
	[kindLabel drawInRect:CGRectMake(kindLabelRect.origin.x-1, kindLabelRect.origin.y-1, kindLabelRect.size.width, kindLabelRect.size.height) withFont:[UIFont boldSystemFontOfSize:kKindLabelFontSize]];
	[timeLabel drawInRect:CGRectMake(timeLabelRect.origin.x+1, timeLabelRect.origin.y+1, timeLabelRect.size.width, timeLabelRect.size.height) withFont:[UIFont boldSystemFontOfSize:kTimeLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];

	[[UIColor blackColor] set];
	[timeLabel drawInRect:timeLabelRect withFont:[UIFont boldSystemFontOfSize:kTimeLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];

	if (diffHidden) {
	}
	else {
		if (self.diffMinus) {
			[[UIColor whiteColor] set];
			[diffLabel drawInRect:diffLabelRect withFont:[UIFont boldSystemFontOfSize:kDiffLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
			[[UIColor darkGrayColor] set];
			[diffLabel drawInRect:CGRectMake(diffLabelRect.origin.x-1, diffLabelRect.origin.y-1, diffLabelRect.size.width, diffLabelRect.size.height) withFont:[UIFont boldSystemFontOfSize:kDiffLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
		}
		else {
			[[UIColor blackColor] set];
			[diffLabel drawInRect:diffLabelRect withFont:[UIFont boldSystemFontOfSize:kDiffLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
			[[UIColor whiteColor] set];
			[diffLabel drawInRect:CGRectMake(diffLabelRect.origin.x-1, diffLabelRect.origin.y-1, diffLabelRect.size.width, diffLabelRect.size.height) withFont:[UIFont boldSystemFontOfSize:kDiffLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
		}		
	}

	if (secondHidden) {
	}
	else {		
		[secondGraph drawInRect:secondViewRect];
	}

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
