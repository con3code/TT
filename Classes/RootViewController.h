//
//  RootViewController.h
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright con3 Office 2009. All rights reserved.
//

#import "TimeTable.h"
#import "TimeInputView.h"
#import "AdView.h"
#import "GADBannerViewDelegate.h"
#import "TableListCell.h"
#import "TT_Define.h"


#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#define kCustomCellHeight	40

@class GADBannerView, GADRequest;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, GADBannerViewDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	TimeTable *ttController;	//時刻表示ビュー
	UITableView *timetableView;	//時刻表一覧表示テーブル
		
	UIActionSheet *actionSheet;	//アクションシート
	
	UILabel *nowClock;	//現在時刻表示部（まだ無いけど…）
	
	GADBannerView *adMobAd;
	NSTimer *refreshTimer;
	BOOL adDisp;

	BOOL _firstInsert; //初めての新規挿入かどうか
	BOOL insertRow;	//新規挿入操作かどうか
	NSIndexPath *insertScrollIndexPath; //新規挿入位置（スクロールのため）
	BOOL thisInsert; //このクラスでの挿入操作か（ネット時刻表の挿入処理ではないことを判別）
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) TimeTable *ttController;
@property (nonatomic, retain) UITableView *timetableView;

@property (nonatomic, retain) UIActionSheet *actionSheet;

@property (nonatomic, assign) BOOL firstInsert;
@property (nonatomic, assign) BOOL insertRow;
@property (nonatomic, retain) NSIndexPath *insertScrollIndexPath;

- (void)waitingStarted;
- (void)waitingEnded;
- (void)removeView:(id)sender;

- (void)updateclock:(NSTimer *)timer;

@end
