//
//  TimeInputView.h
//  TT
//
//  Created by Kotatsu RIN on 09/11/03.
//  Copyright 2009 con3office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollView.h"
#import "TT_Define.h"

@interface TimeInputViewController : UIViewController <NSFetchedResultsControllerDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	NSManagedObject *selectedTimeTable;	//選択された管理オブジェクト

	NSMutableArray	*pages;	//24時間分の時間入力画面
	NSMutableArray	*late_pages;	//

	NSMutableDictionary	*funns_mem;	//入力された直後の最新の分数状態
	NSMutableDictionary	*funns_mem_original;	//入力直前の元分数状態

	NSMutableArray *hourtimes;	//時間単位の入力直後の分数状態
	NSMutableArray *hourtimes_original;	//時間単位の入力直前の元分数状態

	NSMutableArray *tmp_hourtimes;	//作業用分数状態一時領域

	
	int	startHour;	//開始時間
	int sTag;

	BOOL min_editing;	//編集中フラグ
	BOOL modified;	//変更フラグ
	
	UINavigationController *navController;	//呼びだし元のnavigationViewController

	PageScrollView *inputScrollView;	
	CGPoint tapPoint;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *selectedTimeTable;

@property (nonatomic, retain) NSMutableArray	*pages;
@property (nonatomic, retain) NSMutableArray	*late_pages;

@property (nonatomic, retain) NSMutableDictionary	*funns_mem;
@property (nonatomic, retain) NSMutableDictionary	*funns_mem_original;

@property (nonatomic, retain) NSMutableArray *hourtimes;
@property (nonatomic, retain) NSMutableArray *hourtimes_original;

@property (nonatomic, retain) NSMutableArray *tmp_hourtimes;

@property (nonatomic, assign) int startHour;
@property (nonatomic, assign) int sTag;

@property (nonatomic, assign) BOOL min_editing;

@property (nonatomic, retain) UINavigationController *navController;


- (void)resetTimeDisp;
- (void)tappedButton:(id)target minute:(int)m hour:(int)h minutestr:(NSString*)minute hourstr:(NSString*)hour;
- (void)changeStartHour:(int)sh;
- (void)drawButtons;
- (int)currentEditing;

- (void)cancel:(id)sender;
- (void)retrieveMinute;
- (void)copyMinutes:(id)sender;


#ifdef objC
- (void)setSelected:(int)min atHour:(int)hour;
- (int)getSelected:(int)min atHour:(int)hour;
- (void)resetSelected;
#endif

#ifdef oldcode
- (IBAction)touchMinute:(id)sender;
#endif

@end

int timeButtonSelected[24][60];

void revTimeButton(int min, int hour);
void setTimeButton(int min, int hour, int flag);
int getTimeButton(int min, int hour);
void resetTimeButton();
