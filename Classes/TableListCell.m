//
//  TableListCell.m
//  TT
//
//  Created by Kotatsu RIN on 10/01/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableListCell.h"
#import "ButtonImages.h"


@implementation TableListCell

@synthesize R;
@synthesize G;
@synthesize B;
@synthesize A;

@synthesize daytype;
@synthesize dayicon;
@synthesize mainTextLabel;
@synthesize subTextLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		
		self.textLabel.opaque = YES;
		self.detailTextLabel.opaque = YES;
		self.contentView.opaque = YES;
		
		dayicon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 3, 16, 16)];
		dayicon.opaque = YES;
		[self.contentView addSubview:dayicon];
				
		
//		cellViewRect = CGRectMake(0, 0, 320, 40);		
//		daytypePoint = CGPointMake(0, 0);
		
//意味なし…		
//		mainTextLabelRect = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
//		subTextLabelRect = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
		
//		subTextLabelRect = CGRectMake(8, 20, 320, 20);
//		self.textLabel.text = mainTextLabel;
//		self.detailTextLabel.text = subTextLabel;
		
    }
		
    return self;
}



- (void)layoutSubviews {
	
	[super layoutSubviews];

	/*
	CGFloat aR = 1.0f;
	CGFloat aG = 1.0f;
	CGFloat aB = 1.0f;
	CGFloat aA = 1.0f;
	*/
	
	
//	self.textLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.frame =  CGRectMake(self.textLabel.frame.origin.x+20, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);

//	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	
//	self.contentView.backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:A];
	
}



#ifdef oldcode

- (void)drawRect:(CGRect)rect {
	//	[daytype drawInRect:CGRectMake(8, 3, 16, 16)];	
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef cellCntx = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(cellCntx, R, G, B, A);
	CGContextFillRect(cellCntx, cellViewRect);
//    NSLog(@"これ");
	
	[daytype drawAtPoint:daytypePoint];
	
	[[UIColor blackColor] set];
	[mainTextLabel drawInRect:mainTextLabelRect withFont:[UIFont systemFontOfSize:16]];
	[[UIColor grayColor] set];	
	[subTextLabel drawInRect:subTextLabelRect withFont:[UIFont systemFontOfSize:14]];

	/*
	[[UIColor whiteColor] set];
	[mainTextLabel drawInRect:CGRectMake(timeLabelRect.origin.x+1, timeLabelRect.origin.y+1, timeLabelRect.size.width, timeLabelRect.size.height) withFont:[UIFont boldSystemFontOfSize:kTimeLabelFontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	*/
	
}
#endif

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];

}


@end
