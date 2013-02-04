//
//  TimesViewController.h
//  TT
//
//  Created by Kotatsu RIN on 09/10/06.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
#import "TimeCell.h"
#import "TT_Define.h"

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#define kCustomCellHeight	40

#define kDefaultStartingHour 3

@class GADBannerView, GADRequest;

@interface TimesViewController : UITableViewController <NSFetchedResultsControllerDelegate, GADBannerViewDelegate> {

	NSFetchedResultsController	*fetchedResultsController;
	NSManagedObjectContext		*managedObjectContext;
	
	id callparent;
	
	UITableView *timesTable;	//時刻表示テーブル
	TimeCell *timeCellDisp;	//時刻表示セル

	NSManagedObject *selectedTimeTable;	//時刻表一覧で選択された管理オブジェクト

	NSString		*stationValue;	//駅名
	NSString		*lineValue;	//路線名
	NSString		*directionValue;	//方面
	int				daytypeValue;	//曜日

	NSArray *allTime;	//全ての時刻
	NSMutableArray *allKeys;	//テーブルインデックスのためのセクション名称配列
	
	GADBannerView *adMobAd;
	NSTimer *refreshTimer;
	BOOL adDisp;	//広告表示フラグ
    BOOL adHide;   //広告隠れ
    BOOL adReq;     //広告リクエスト
	
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) id callparent;

@property (nonatomic, retain) UITableView *timesTable;

@property (nonatomic, retain) NSManagedObject *selectedTimeTable;

@property (nonatomic, retain) NSArray *allTime;
@property (nonatomic, retain) NSMutableArray *allKeys;


- (IBAction)tableScroll;

@end
