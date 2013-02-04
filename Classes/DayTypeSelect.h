//
//  DayTypeSelect.h
//  TT
//
//  Created by Kotatsu RIN on 09/11/02.
//  Copyright 2009 con3office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTable.h"
#import "TT_Define.h"


@interface DayTypeSelect : UITableViewController {

	NSString *currentDaytype;	//曜日タイプ
	NSInteger oldIndexPathRow;	//直前に選択していたもの
	id parent;	//呼びだし元
}

@property (nonatomic, assign) NSString *currentDaytype;
@property (nonatomic, retain) id parent;

@end
