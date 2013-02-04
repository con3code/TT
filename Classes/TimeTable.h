//
//  TimeTable.h
//  TT
//
//  Created by Kotatsu RIN on 09/09/28.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeInputViewController.h"
#import "PageScrollView.h"
#import "ButtonImages.h"
#import "TT_Define.h"

#include <AudioToolbox/AudioToolbox.h>

#define kNumberOfEditableRows	4

#define kStationName	0
#define kLineName	1
#define kDestination	2
#define kDay	3
#define kLabelTag	4096

#define kDaytypeWeekday		0
#define kDaytypeSaturday	1
#define kDaytypeHolyday		2
#define kDaytypeSomeday		4


@interface TimeTable : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, PageScrollViewDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	NSManagedObject *selectedTimeTable;	//選択された管理オブジェクト
	
	NSArray *fieldLabels;	//時刻表基本情報入力欄のラベル表示用文字列の配列
	NSArray *fieldKeys;		//入力欄のデータ保存用の対応キー
	NSMutableDictionary *tempValues;	//入力中の基本情報の一時保管領域
	UITextField *textFieldBeingEdited;	//入力開始し編集中のテキストフィールドの退避領域
	
	TimeInputViewController *timeInputView;	//時刻入力画面用ビュー
	UIButton *testButton;	//24時間分のボタン（24個）生成用

	UIActionSheet *actionSheet;	//アクションシート
	UINavigationController *pushNavController;

	BOOL editing;	//編集中フラグ
	BOOL waiting;

	int sTag;
	
	SystemSoundID	soundTock;
	
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSManagedObject *selectedTimeTable;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSArray *fieldKeys;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

@property (nonatomic, retain) TimeInputViewController *timeInputView;
@property (nonatomic, retain) UIButton *testButton;

@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UINavigationController *pushNavController;

@property (nonatomic, assign) BOOL waiting;

@property (readonly)	SystemSoundID	soundTock;


- (void)cancel:(id)sender;
- (void)save:(id)sender;
- (void)edit:(id)sender;
- (IBAction)textFieldDone:(id)sender;

- (void)settingupTimeInputView;
- (void)TimeInputViewIn:(id)sender;

- (void)waitingStarted;
- (void)waitingEnded;

- (void)setDaytype:(NSString *)daytype;


@end
