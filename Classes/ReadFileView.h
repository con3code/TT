//
//  ReadFileView.h
//  TT
//
//  Created by Kotatsu RIN on 09/10/07.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "NSString_URLEncoding.h"
#import "TT_Define.h"

#include <AudioToolbox/AudioToolbox.h>

#define kEkitanNotFound		0
#define kEkitanEkiSelect	1
#define kEkitanRosenSelect	2
#define kEkitanTimeTable	3


@interface ReadFileView : UIViewController {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	//駅名入力画面
	
	IBOutlet UITextField	*stationName;
	IBOutlet UIButton	*searchButton;
	IBOutlet UIButton	*background;
	
	NSString	*tableTitle;	//テーブルタイトル（ここでは実質未使用…）

	NSInteger	nextEkitanType;	//次画面の駅探表示タイプ
	NSMutableDictionary	*allDatas;	//全ての時刻列
	NSMutableArray		*sectionDatas;	//セクション配列
	NSMutableDictionary	*cellData;	//セルのデータ
	NSMutableArray *keyTitles;	//セクションインデックス用配列

	BOOL		inAction;		//選択再入判定
	
	NSString	*stationValue;	//駅名
	NSString	*sfcode;	//SFコード
	NSString	*lineValue;	//路線
	NSString	*directionValue;	//行き先
	int			daytypeValue;	//曜日

	
	NSURLConnection *urlConnection;

//旧通信ハンドル
	NSMutableData *recieveData; //受信データ領域

	
//HTMLパース
	struct _xmlParserCtxt *_parserContext;
    NSMutableString *_currentCharacters;
	
	BOOL		inDiv;
	NSInteger	divCount;
	BOOL		inForm;			//抽出部分判定
	NSInteger	formCount;		//抽出部分終了判定用
	NSInteger	secNo;
	
	BOOL	typeDetect;

	NSMutableString *rosenValue;
	NSMutableString *homenValue;
	NSString *urlValue;
	
	
//XMLパース
	NSXMLParser			*myParser; //パーサ
	NSMutableDictionary	*currentRecord; //現在処理辞書領域
	NSMutableString		*currentStringValue; //現在処理文字列領域(値)
	BOOL	recordin;
	BOOL	tagin;
		

//Please wait表示
	UIView		*overlay;
	UIActivityIndicatorView	*working;
	UILabel		*overlayText;
	
	
	SystemSoundID	soundTock;


}


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UITextField	*stationName;
@property (nonatomic, retain) NSString	*tableTitle;

@property (nonatomic, assign) NSInteger nextEkitanType;
@property (nonatomic, retain) NSMutableDictionary	*allDatas;
@property (nonatomic, retain) NSMutableArray		*sectionDatas;
@property (nonatomic, retain) NSMutableDictionary	*cellData;
@property (nonatomic, retain) NSMutableArray *keyTitles;


@property (nonatomic, retain) NSString	*stationValue;
@property (nonatomic, retain) NSString	*sfcode;
@property (nonatomic, retain) NSString	*lineValue;
@property (nonatomic, retain) NSString	*directionValue;
@property (nonatomic, assign) int		daytypeValue;

@property (nonatomic, retain) NSURLConnection *urlConnection;

@property (nonatomic, retain) NSMutableData *recieveData;

@property (nonatomic, retain) NSXMLParser *myParser;
@property (nonatomic, retain) NSMutableDictionary *currentRecord;
@property (nonatomic, retain) NSMutableString *currentStringValue;

@property (nonatomic, retain) NSMutableString *rosenValue;
@property (nonatomic, retain) NSMutableString *homenValue;
@property (nonatomic, retain) NSString *urlValue;

@property (nonatomic, retain) UIView		*overlay;
@property (nonatomic, retain) UIActivityIndicatorView	*working;
@property (nonatomic, retain) UILabel		*overlayText;

@property (readonly)	SystemSoundID	soundTock;


- (IBAction)readFile:(id)sender;
- (IBAction)reset:(id)sender;
- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes;
- (void)endElementName:(const xmlChar*)name;
- (void)charactersFound:(const xmlChar*)ch len:(int)len;
- (void)downloadStarted;
- (void)downloadEnded;
- (void)removeView:(id)sender;

@end
