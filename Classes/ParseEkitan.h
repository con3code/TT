//
//  ParseEkitan.h
//  TT
//
//  Created by Kotatsu RIN on 09/12/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/HTMLparser.h>
#import "NSString_URLEncoding.h"
#import "WebViewController.h"
#import "TT_Define.h"

#define kEkitanNotFound		0
#define kEkitanEkiSelect	1
#define kEkitanRosenSelect	2
#define kEkitanTimeTable	3

#define kDaytypeWeekday		0
#define kDaytypeSaturday	1
#define kDaytypeHolyday		2
#define kDaytypeSomeday		4

#define kCustomCellHeight	40

#define kvehicleTypeOther	0
#define kvehicleTypeTrain	1
#define kvehicleTypeBus		2
#define kvehicleTypeBoat	3

#define kReset 0
#define kDone 1
#define kBack 2
#define kReload 3
#define kStop 4
#define kForward 5
#define kMemo 6


@interface ParseEkitan : NSObject {

	id callparent;
	NSURL *nowURL;
	NSInteger whichSite;

	//coredata
	NSManagedObjectContext	*managedObjectContext;
	
	//table
	NSInteger	viewEkitanType;
	NSString	*tableTitle;		//使われていない…
	
	UIView	*toEkitan;
	
	
	//hour,minute,kind,direction
	NSMutableDictionary	*tableAllDatas;
	NSMutableArray		*tableSectionDatas;
	NSMutableDictionary	*tableCellData;
	NSArray				*keys;
	
	
	//選択処理
	NSString	*selectedTitle;
	BOOL		selected;			//選択再入判定（セル選択）
	BOOL		selectedSeg;		//選択再入判定（セグメント選択）
	NSString	*stationValue;		//駅名
	NSString	*sfcode;			//sfcode	
	NSString	*lineValue;			//路線
	NSString	*directionValue;	//方面
	int			daytypeValue;		//曜日
	NSString	*ekitanUrl;			//URL
	
	int			selectDaytype;		//セグメントで選択している曜日
	
	NSArray	*deleteKeyword;
	
	//平日・土曜・休日
	BOOL	weekdayDone;
	BOOL	saturdayDone;
	BOOL	holydayDone;
	
	NSInteger	nextEkitanType;
	NSMutableDictionary	*allDatas;
	NSMutableArray		*sectionDatas;
	NSMutableDictionary	*cellData;
	NSMutableArray		*keyTitles;
	
	NSMutableDictionary	*weekdayAllDatas;
	NSMutableArray		*weekdayKeys;
	
	NSMutableDictionary	*saturdayAllDatas;
	NSMutableArray		*saturdayKeys;
	
	NSMutableDictionary	*holydayAllDatas;
	NSMutableArray		*holydayKeys;
	
	
	//connection
	NSURLConnection *urlConnection;
	
	//HTMLパース
	struct _xmlParserCtxt	*_parserContext;
    NSMutableString			*_currentCharacters;
	
	BOOL		typeDetect;		//駅探アクセス画面タイプ判別処理済み判定
	BOOL		inDiv;			//抽出部分判定
	NSInteger	divCount;	//抽出部分終了判定用
	BOOL		inForm;			//抽出部分判定
	NSInteger	formCount;		//抽出部分終了判定用
	BOOL		inUl;			//抽出部分判定
	NSInteger	ulCount;		//抽出部分終了判定用
	BOOL		inLi;			//抽出部分判定
	NSInteger	secNo;		//セクション登録のキー値作成用
	
	NSMutableString	*rosenValue;
	NSMutableString	*homenValue;
	NSString		*urlValue;
	
}

@property (nonatomic, retain) id callparent;
@property (nonatomic, retain) NSURL *nowURL;
@property (nonatomic, assign) NSInteger whichSite;

@property (nonatomic, retain) NSManagedObjectContext	*managedObjectContext;

@property (nonatomic, retain) NSString	*tableTitle;
@property (nonatomic, assign) NSInteger viewEkitanType;

@property (nonatomic, assign) UIView	*toEkitan;

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

@property (nonatomic, retain) NSString	*ekitanUrl;

@property (nonatomic, assign) NSInteger nextEkitanType;
@property (nonatomic, retain) NSMutableDictionary	*allDatas;
@property (nonatomic, retain) NSMutableArray		*sectionDatas;
@property (nonatomic, retain) NSMutableDictionary	*cellData;
@property (nonatomic, retain) NSMutableArray		*keyTitles;

@property (nonatomic, retain) NSMutableDictionary	*weekdayAllDatas;
@property (nonatomic, retain) NSMutableArray		*weekdayKeys;

@property (nonatomic, retain) NSMutableDictionary	*saturdayAllDatas;
@property (nonatomic, retain) NSMutableArray		*saturdayKeys;

@property (nonatomic, retain) NSMutableDictionary	*holydayAllDatas;
@property (nonatomic, retain) NSMutableArray		*holydayKeys;

@property (nonatomic, retain) NSURLConnection	*urlConnection;

@property (nonatomic, retain) NSMutableString	*_currentCharacters;

@property (nonatomic, retain) NSMutableString	*rosenValue;
@property (nonatomic, retain) NSMutableString	*homenValue;
@property (nonatomic, retain) NSString	*urlValue;


- (void)saveData;
- (void)connectionStarted;
- (void)connectionEnded;

- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes;
- (void)endElementName:(const xmlChar*)name;
- (void)charactersFound:(const xmlChar*)ch len:(int)len;

- (void)savingTimeData;

@end
