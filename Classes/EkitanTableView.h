//
//  EkitanTableView.h
//  TT
//
//  Created by Kotatsu RIN on 09/10/17.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "NSString_URLEncoding.h"
#import "EkitanTimeTable.h"
#import "TT_Define.h"

#define kEkitanNotFound		0
#define kEkitanEkiSelect	1
#define kEkitanRosenSelect	2
#define kEkitanTimeTable	3

#define kDaytypeWeekday		0
#define kDaytypeSaturday	1
#define kDaytypeHolyday		2
#define kDaytypeSomeday		4


@interface EkitanTableView : UITableViewController <UITableViewDelegate> {

	//coredata
	NSManagedObjectContext	*managedObjectContext;
	
	//table
//	UITableView *timesTable;
	
	NSInteger	viewEkitanType;
	NSString	*tableTitle;

	NSMutableDictionary	*tableAllDatas;
	NSMutableArray		*tableSectionDatas;
	NSMutableDictionary	*tableCellData;
	NSArray				*keys;

		
	//選択処理
	NSString	*selectedTitle; //選択したセルの情報（駅名の時も，路線の時もある）
	BOOL		selected;		//選択再入判定
	NSString	*stationValue; //駅名
	NSString	*sfcode;
	NSString	*lineValue; //路線名
	NSString	*directionValue; //方面
	int			daytypeValue; //曜日
	
	NSInteger callBackValue;
	
	//next
	NSInteger	nextEkitanType;

	NSMutableDictionary	*allDatas;
	NSMutableArray		*sectionDatas;
	NSMutableDictionary	*cellData;
	NSMutableArray		*keyTitles;
	
	NSString	*ekitanUrl;
	
	IBOutlet UIView				*toEkitan;	//駅探への謝辞表示

	//connection
	NSURLConnection *urlConnection;
    NSMutableData *recieveData;
	
	//HTMLパース
	struct _xmlParserCtxt	*_parserContext;
    NSMutableString			*_currentCharacters;
	
	BOOL		typeDetect;		//駅探アクセス画面タイプ判別処理済み判定
	BOOL		inDiv;			//抽出部分判定
	NSInteger	divCount;		//抽出部分終了判定用
	BOOL		inForm;			//抽出部分判定
	NSInteger	formCount;		//抽出部分終了判定用
	NSInteger	secNo;			//セクション登録のキー値作成用

	NSMutableString	*rosenValue;
	NSMutableString	*homenValue;
	NSString		*urlValue;

	UIView		*overlay;
	UIActivityIndicatorView	*working;
	UILabel		*overlayText;

}

@property (nonatomic, retain) NSManagedObjectContext	*managedObjectContext;

@property (nonatomic, retain) NSString	*tableTitle;
@property (nonatomic, assign) NSInteger viewEkitanType;
//@property (nonatomic, retain) UITableView *timesTable;

@property (nonatomic, retain) NSMutableDictionary	*tableAllDatas;
@property (nonatomic, retain) NSMutableArray		*tableSectionDatas;
@property (nonatomic, retain) NSMutableDictionary	*tableCellData;
@property (nonatomic, retain) NSArray		*keys;

@property (nonatomic, retain) NSString	*selectedTitle;

@property (nonatomic, retain) NSString	*stationValue;
@property (nonatomic, retain) NSString	*sfcode;
@property (nonatomic, retain) NSString	*lineValue;
@property (nonatomic, retain) NSString	*directionValue;
@property (nonatomic, assign) int		daytypeValue;

@property (nonatomic, assign) NSInteger callBackValue;

@property (nonatomic, assign) NSInteger nextEkitanType;
@property (nonatomic, retain) NSMutableDictionary	*allDatas;
@property (nonatomic, retain) NSMutableArray		*sectionDatas;
@property (nonatomic, retain) NSMutableDictionary	*cellData;
@property (nonatomic, retain) NSMutableArray *keyTitles;

@property (nonatomic, retain) NSString	*ekitanUrl;

@property (nonatomic, assign) IBOutlet UIView	*toEkitan;

@property (nonatomic, retain) NSURLConnection	*urlConnection;

@property (nonatomic, assign) NSMutableData *recieveData;

@property (nonatomic, retain) NSMutableString	*_currentCharacters;

@property (nonatomic, retain) NSMutableString	*rosenValue;
@property (nonatomic, retain) NSMutableString	*homenValue;
@property (nonatomic, retain) NSString	*urlValue;

@property (nonatomic, retain) UIView		*overlay;
@property (nonatomic, retain) UIActivityIndicatorView	*working;
@property (nonatomic, retain) UILabel		*overlayText;


- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes;
- (void)endElementName:(const xmlChar*)name;
- (void)charactersFound:(const xmlChar*)ch len:(int)len;

- (void)downloadStarted;
- (void)downloadEnded;
- (void)removeView:(id)sender;

- (IBAction)segmentAction:(id)sender;

@end
