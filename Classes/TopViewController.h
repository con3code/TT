//
//  TopViewController.h
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
//#import "GADInterstitialDelegate.h" GADInterstitialDelegate
#import "BindedTimetable.h"
#import "TT_Define.h"

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#define kCustomCellHeight	40

#define kvehicleTypeOther	0
#define kvehicleTypeTrain	1
#define kvehicleTypeBus		2
#define kvehicleTypeBoat	3

#define kDefaultStartingHour 3

@class GADBannerView, GADRequest, GADInterstitial;
@class AdMobView;

@interface TopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, GADBannerViewDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	IBOutlet UITableView *topTable;	//時刻の表示テーブル
	BindedTimetable *timeCellDisp;	//時刻の表示セル
	
	IBOutlet UILabel *nowClock;	//現在時刻表示部分
//	NSString *nowTimetext;
	
	NSInteger nowHour;	//現在時
	NSInteger nowMinute;	//現在分
	NSInteger nowSecond;	//現在秒
	
	BOOL diffDisp;	//差分表示のフラグ（表示してない時に秒アイコンが表示されないように判断するため）
	
	NSString *selectedSide;	//表示セット
	IBOutlet UILabel *dispSide;
	NSInteger first_tt_No;	//混合する一つ目の時刻表ID
	NSString *first_tt_name;	//混合する一つ目の時刻表の名称文字列
	IBOutlet UILabel *first_timetable;	//混合する一つ目の時刻表の名称表示部分
	NSInteger second_tt_No;	//混合する二つ目の時刻表ID
	NSString *second_tt_name;	//混合する二つ目の時刻表の名称文字列
	IBOutlet UILabel *second_timetable;	//混合する二つ目の時刻表の名称表示部分

	IBOutlet UIImageView *first_icon;	//混合する時刻表のためのカラーアイコン
	IBOutlet UIImageView *second_icon;	//混合する時刻表のためのカラーアイコン

	GADBannerView *adMobAd;
	NSTimer *refreshTimer;
	BOOL adDisp;	//広告表示フラグ

	NSMutableArray *allKeys;	//インデックス表示のためのセクション名称の配列

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *selectedSide;
@property (nonatomic, retain) NSString *first_tt_name;
@property (nonatomic, retain) NSString *second_tt_name;
@property (nonatomic, retain) IBOutlet UITableView *topTable;
@property (nonatomic, retain) IBOutlet UILabel *dispSide;

@property (nonatomic, retain) NSMutableArray *allKeys;







//@property (nonatomic,retain) NSString *nowTimetext;

- (void)updateclock;
- (IBAction)tableScroll;
- (IBAction)first_tt_select;
- (IBAction)second_tt_select;
- (void)tableSetting:(NSInteger)dochi asNo:(NSInteger)no ofName:(NSString *)name;

@end

