//
//  BindedTimetable.h
//  TableSample
//
//  Created by Kotatsu RIN on 10/01/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TT_Define.h"


@interface BindedTimetable : UITableViewCell {

	
	//種類別バックグラウンドカラーの設定
	UIView *cellView;
	CGRect cellViewRect;
	CGFloat R;
	CGFloat G;
	CGFloat B;
	CGFloat A;

	//時刻表別のイメージ
	UIImage *ttColorImage;
	CGPoint ttcolorPoint;
	
	//時刻
	NSString *timeLabel;
	CGRect timeLabelRect;
	
	//種別
	NSString *kindLabel;
	CGRect kindLabelRect;
	
	//行先
	NSString *destinationLabel;
	CGRect destinationLabelRect;
	
	//残り時間
	NSString *diffLabel;
	CGRect diffLabelRect;
	BOOL diffHidden;
	BOOL diffMinus;
	
	//秒表示
	UIImage *secondGraph;
	CGRect secondViewRect;
	BOOL secondHidden;
	
}

@property (nonatomic, assign) CGFloat R;
@property (nonatomic, assign) CGFloat G;
@property (nonatomic, assign) CGFloat B;
@property (nonatomic, assign) CGFloat A;

@property (nonatomic, retain) UIImage *ttColorImage;
@property (nonatomic, retain) NSString *timeLabel;
@property (nonatomic, retain) NSString *kindLabel;
@property (nonatomic, retain) NSString *destinationLabel;
@property (nonatomic, retain) NSString *diffLabel;
@property (nonatomic, retain) UIImage *secondGraph;

@property (nonatomic, assign) BOOL diffHidden;
@property (nonatomic, assign) BOOL diffMinus;
@property (nonatomic, assign) BOOL secondHidden;

@end
