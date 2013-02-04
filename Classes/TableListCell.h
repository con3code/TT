//
//  TableListCell.h
//  TT
//
//  Created by Kotatsu RIN on 10/01/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TT_Define.h"


@interface TableListCell : UITableViewCell {

	//種類別バックグラウンドカラーの設定
	UIView *cellView;
	CGRect cellViewRect;
	CGFloat R;
	CGFloat G;
	CGFloat B;
	CGFloat A;
	
	//イメージ
	UIImage *daytype;
	UIImageView *dayicon;
	CGPoint daytypePoint;
	
	//文字
	NSString *mainTextLabel;
	CGRect mainTextLabelRect;
	
	NSString *subTextLabel;
	CGRect subTextLabelRect;

}

@property (nonatomic, assign) CGFloat R;
@property (nonatomic, assign) CGFloat G;
@property (nonatomic, assign) CGFloat B;
@property (nonatomic, assign) CGFloat A;

@property (nonatomic, retain) UIImage *daytype;
@property (nonatomic, retain) UIImageView *dayicon;
@property (nonatomic, retain) NSString *mainTextLabel;
@property (nonatomic, retain) NSString *subTextLabel;

@end
