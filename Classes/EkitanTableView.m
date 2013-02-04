//
//  EkitanTableView.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/17.
//  Copyright 2009 con3 Office. All rights reserved.
//
//
//	表示→選択→読込→子ビューのインスタントを生成して表示に渡す
//
//

#import "EkitanTableView.h"

//ライブラリからCocoaの呼び出し
static void StartElementSAXFunc(void *ctx, const xmlChar *name, const xmlChar **atts)
{
	[(EkitanTableView *)ctx startElementName:name attributes:atts];
}

static void EndElementSAXFunc(void *ctx, const xmlChar *name)
{
	[(EkitanTableView *)ctx endElementName:name];
}

static void CharactersSAXFunc(void *ctx, const xmlChar *ch, int len)
{
	[(EkitanTableView *)ctx charactersFound:ch len:len];
}

//対応しているパーサからのデリゲートメソッドリスト
static xmlSAXHandler gSAXHandler = {
	.initialized = XML_SAX2_MAGIC,
	.startElement = StartElementSAXFunc,
	.endElement = EndElementSAXFunc, 
	.characters = CharactersSAXFunc,
};



@implementation EkitanTableView

@synthesize tableTitle;
@synthesize viewEkitanType;
//@synthesize timesTable;

@synthesize tableAllDatas;
@synthesize tableSectionDatas;
@synthesize tableCellData;
@synthesize keys;


@synthesize selectedTitle;

@synthesize stationValue;
@synthesize sfcode;
@synthesize lineValue;
@synthesize directionValue;
@synthesize daytypeValue;

@synthesize callBackValue;

@synthesize nextEkitanType;
@synthesize allDatas;
@synthesize sectionDatas;
@synthesize cellData;
@synthesize keyTitles;

@synthesize ekitanUrl;

@synthesize toEkitan;

@synthesize managedObjectContext;

@synthesize urlConnection;
@synthesize recieveData;
@synthesize _currentCharacters;

@synthesize rosenValue;
@synthesize homenValue;
@synthesize urlValue;

@synthesize overlay;
@synthesize working;
@synthesize overlayText;


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		
    }
    return self;
}
*/

- (void)gotoEkitan {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ekitan.com/"]];	
}


- (void) loadView {

#ifdef Log
	NSLog(@"Ekitan View!!! :loadView");
#endif
    
/*
	self.timesTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.timesTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.timesTable.delegate = self;
	self.timesTable.dataSource = self;
	self.tableView = self.timesTable;
*/
	
	[super loadView];
	CGRect viewRect = CGRectMake(0, 0, 320, 40);
	self.toEkitan = [[UIView alloc] initWithFrame:viewRect];
	self.toEkitan.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.6];
	CGRect titleRect = CGRectMake(10, 10, 300, 20);
	UIButton *header = [[UIButton alloc] initWithFrame:titleRect];
	header.backgroundColor = [UIColor clearColor];
	header.opaque = YES;
	[header setTitle:NSLocalizedString(@"Thankyou for & powered by駅探",nil) forState:UIControlStateNormal];
	header.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	header.titleLabel.textColor = [UIColor whiteColor];
	[header addTarget:self action:@selector(gotoEkitan) forControlEvents:UIControlEventTouchUpInside];
	[self.toEkitan addSubview:header];

 //テーブルのヘッダー
	self.tableView.tableHeaderView = self.toEkitan;
	[self.tableView reloadData];
	[header release];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

//	NSLog(@"Ekitan View!!! :viewDidLoad");

	//waittingレイヤーの設定
    CGRect screen_bounds = [[UIScreen mainScreen] bounds];
//    NSLog(@"screen_bounds %@", NSStringFromCGRect(screen_bounds));
    
//    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
//    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));
    
    
	CGRect vRect = CGRectMake(0, screen_bounds.size.height - 49, 320, 60);
//	CGRect vRect = CGRectMake(0, 431, 320, 60);
	overlay = [[UIView alloc] initWithFrame:vRect];
	overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];

	//アクティブインディケーター設定
	CGRect fRect = CGRectMake(20, 20, 20, 20);
	working = [[UIActivityIndicatorView alloc] initWithFrame:fRect];
	[overlay addSubview:working];

	//waittingレイヤーの文字列
	CGRect tRect = CGRectMake(60, 20, 240, 20);
	overlayText = [[UILabel alloc] initWithFrame:tRect];
	[overlayText setFont:[UIFont boldSystemFontOfSize:18]];
	overlayText.textAlignment = UITextAlignmentLeft;
	[overlayText setText:NSLocalizedString(@"Please Wait...",nil)];
	overlayText.textColor = [UIColor whiteColor];
	overlayText.backgroundColor = [UIColor clearColor];
	[overlay addSubview:overlayText];

	//UIViewアニメーションのON
	[UIView setAnimationsEnabled:YES];
	

	//セグメントコントローラーの設定
	if (viewEkitanType == kEkitanTimeTable) {
		NSString *info = [NSString stringWithFormat:NSLocalizedString(@"%@ <%@>",nil),lineValue, directionValue];
		self.navigationItem.prompt = info;
		
		NSArray *segmentTextContent = [NSArray arrayWithObjects:NSLocalizedString(@"Weekday",nil), NSLocalizedString(@"Saturday",nil), NSLocalizedString(@"Holiday",nil),nil];
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
		segmentedControl.selectedSegmentIndex = 0;
		segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.frame = CGRectMake(0, 0, 150, 25);
		[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];	
    
		self.navigationItem.titleView = segmentedControl;
		[segmentedControl release];
	}
	
#ifdef Log
	NSLog(@"Title-> %@",tableTitle);
#endif
    
	typeDetect = NO;
 }


- (void)downloadStarted {
	[[[self navigationController] view] addSubview:self.overlay];
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y -= height;
	overlay.center = center;
	[UIView commitAnimations];
	[working startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y += height;
	overlay.center = center;
	[UIView commitAnimations];
	[working stopAnimating];
	[self performSelector:@selector(removeView:) withObject:self.overlay afterDelay:1.0f];
}

- (void)removeView:(id)sender {
	[sender removeFromSuperview];
}


- (IBAction)segmentAction:(id)sender {
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	int dayt = segmentedControl.selectedSegmentIndex;
	
	if (dayt == kDaytypeWeekday) {
#ifdef Log
		NSLog(@"Weekday");
#endif
	}
	if (dayt == kDaytypeSaturday) {
#ifdef Log
		NSLog(@"Saturday");
#endif
	}
	if (dayt == kDaytypeHolyday) {
#ifdef Log
		NSLog(@"Holyday");
#endif
	}
}


- (void)viewWillAppear:(BOOL)animated {
//	NSLog(@"Ekitan View!!! :viewWillAppear");
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
//	NSLog(@"Ekitan View!!! :viewDidAppear");
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
//	NSLog(@"Ekitan View!!! :viewWillDisappear");
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
//	NSLog(@"Ekitan View!!! :viewDidDisappear");
	[super viewDidDisappear:animated];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Connection Handle methods



//通信ハンドル部分

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	

    [recieveData release]; recieveData = nil;
	recieveData = [[NSMutableData data] retain];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
#ifndef Lump
	//データをパーサへ
	htmlParseChunk(_parserContext, (const char*)[data bytes], [data length], 0);
#endif
	
		[recieveData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
#ifdef Log
	NSLog(@"Error!!");
#endif
    
#ifndef Lump
	htmlParseChunk(_parserContext, NULL, 0, YES);
	
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
		selected = NO;
	}
#endif
    
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];

	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"No Internet Connection...",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Failed",nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	
#ifdef Log
	NSLog(@"Connection did fail with error: %@",[error localizedDescription]);
#endif
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    
#ifdef Lump
    
#ifdef Log
	NSLog(@"Lump Parse!");
#endif
    
    
	_parserContext = htmlCreatePushParserCtxt(&gSAXHandler, self, NULL, 0, nil, XML_CHAR_ENCODING_NONE);
	_currentCharacters = nil;
    
    htmlParseChunk(_parserContext, (const char*)[recieveData bytes], [recieveData length], 0);
    
//    while (!parserComplete);
	
    if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
        selected = NO;
	}
    
#ifdef Log
	NSLog(@"Parser Closed!!! :Lump");
#endif
    
#else
    
#ifdef Log
	NSLog(@"Not Lump Parse!");
#endif
    
//    if (!parserComplete) {
//        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(self) userInfo:nil repeats:NO];
//    }
    
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
	}
    
#ifdef Log
	NSLog(@"Parser Closed!!! :Not Lump");
#endif
    
#endif
    
    
    
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];

	if (nextEkitanType == kEkitanRosenSelect) {
		NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
		[allDatas setValue:sectionDatas forKey:noKey];
        if (rosenValue != nil) {
            [keyTitles addObject:rosenValue];
        }
		[noKey release];
		rosenValue = nil;
		
		[cellData release];					
		cellData = nil;
		[sectionDatas release];
		sectionDatas = nil;
	}

	if (nextEkitanType == kEkitanTimeTable) {

		NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
		[allDatas setValue:sectionDatas forKey:noKey];
        if (rosenValue != nil) {
            [keyTitles addObject:rosenValue];
        }
		[noKey release];
#ifdef Log
		NSLog(@"[MMint: %@]-------\n",[[sectionDatas lastObject] objectForKey:@"dep_hour"]);
#endif
		[rosenValue release];
		rosenValue = nil;
				
		[sectionDatas release];
		sectionDatas = nil;
	}
	
//	NSLog(@"Finish!!");
	

	//子テーブルビューの呼び出し
	
	if (nextEkitanType == kEkitanTimeTable) {

		if (daytypeValue == kDaytypeWeekday) {
			EkitanTimeTable *ekitanTable = [[EkitanTimeTable alloc] init];	//次画面の生成
			
			ekitanTable.viewEkitanType = nextEkitanType;					//次画面の表示形式を指定
			ekitanTable.managedObjectContext = self.managedObjectContext;	//コンテキストの引き継ぎ
			ekitanTable.title = self.selectedTitle;				//子ビュータイトル
			ekitanTable.tableTitle = self.selectedTitle;		//表示テーブル名
			ekitanTable.stationValue = self.stationValue;		//駅名
			ekitanTable.lineValue = self.lineValue;				//路線
			ekitanTable.directionValue = self.directionValue;	//方面
			ekitanTable.daytypeValue = daytypeValue;			//曜日
			ekitanTable.ekitanUrl = self.ekitanUrl;				//URL
			
			ekitanTable.weekdayKeys = keyTitles;				//平日の時間セクションのキー
			ekitanTable.weekdayAllDatas = self.allDatas;		//平日の時刻データ
			[keyTitles release];
			[allDatas release];
			
			[[self navigationController] pushViewController:ekitanTable animated:YES];
			
			[ekitanTable release];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			EkitanTimeTable *ekitanTable = [[EkitanTimeTable alloc] init];
			
			ekitanTable.viewEkitanType = nextEkitanType;
			ekitanTable.managedObjectContext = self.managedObjectContext;
			ekitanTable.title = self.selectedTitle;
			ekitanTable.tableTitle = self.selectedTitle;
			ekitanTable.stationValue = self.stationValue;		//駅名
			ekitanTable.lineValue = self.lineValue;				//路線
			ekitanTable.directionValue = self.directionValue;	//方面
			ekitanTable.daytypeValue = daytypeValue;			//曜日
			ekitanTable.ekitanUrl = self.ekitanUrl;				//URL
			
			ekitanTable.saturdayKeys = keyTitles;				//土曜の時間セクションのキー
			ekitanTable.saturdayAllDatas = self.allDatas;		//土曜の時刻データ
			[keyTitles release];
			[allDatas release];
			
			[[self navigationController] pushViewController:ekitanTable animated:YES];
			
			[ekitanTable release];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			EkitanTimeTable *ekitanTable = [[EkitanTimeTable alloc] init];
			
			ekitanTable.viewEkitanType = nextEkitanType;
			ekitanTable.managedObjectContext = self.managedObjectContext;
			ekitanTable.title = self.selectedTitle;
			ekitanTable.tableTitle = self.selectedTitle;
			ekitanTable.stationValue = self.stationValue;
			ekitanTable.lineValue = self.lineValue;
			ekitanTable.directionValue = self.directionValue;
			ekitanTable.daytypeValue = daytypeValue;
			ekitanTable.ekitanUrl = self.ekitanUrl;
			
			ekitanTable.holydayKeys = keyTitles;
			ekitanTable.holydayAllDatas = self.allDatas;
			[keyTitles release];
			[allDatas release];
			
			[[self navigationController] pushViewController:ekitanTable animated:YES];
			
			[ekitanTable release];
		}
		else if (daytypeValue == kDaytypeSomeday) {			
			EkitanTimeTable *ekitanTable = [[EkitanTimeTable alloc] init];
			
			ekitanTable.viewEkitanType = nextEkitanType;
			ekitanTable.managedObjectContext = self.managedObjectContext;
			ekitanTable.title = self.selectedTitle;
			ekitanTable.tableTitle = self.selectedTitle;
			ekitanTable.stationValue = self.stationValue;
			ekitanTable.lineValue = self.lineValue;
			ekitanTable.directionValue = self.directionValue;
			ekitanTable.daytypeValue = daytypeValue;
			ekitanTable.ekitanUrl = self.ekitanUrl;
			
			ekitanTable.keys = keyTitles;
			ekitanTable.tableAllDatas = self.allDatas;
			[keyTitles release];
			[allDatas release];
			
			[[self navigationController] pushViewController:ekitanTable animated:YES];
			
			[ekitanTable release];
		}
		
	}
	else {
		//路線選択データの子への受け渡し
		
		EkitanTableView *ekitanTable = [[EkitanTableView alloc] init];
		
		ekitanTable.viewEkitanType = nextEkitanType;
		ekitanTable.managedObjectContext = self.managedObjectContext;
		ekitanTable.tableTitle = self.selectedTitle;	//テーブルタイトル
		if (self.stationValue == nil) {
			ekitanTable.title = self.title;				//タイトル
			ekitanTable.stationValue = self.title;		//駅名
		}
		else {
			ekitanTable.title = self.stationValue;			//タイトル
			ekitanTable.stationValue = self.stationValue;	//駅名
		}
		ekitanTable.lineValue = self.lineValue;				//路線
		ekitanTable.directionValue = self.directionValue;	//方面

		if (nextEkitanType == kEkitanEkiSelect) {		
			ekitanTable.tableSectionDatas = self.sectionDatas;	//駅選択データ
			[sectionDatas release];
		}
		else if (nextEkitanType == kEkitanRosenSelect) {
			ekitanTable.keys = keyTitles;					//路線セクションのキー値
			ekitanTable.tableAllDatas = self.allDatas;		//路線選択データ
			[keyTitles release];
			[allDatas release];
		}

		[[self navigationController] pushViewController:ekitanTable animated:YES];
//		NSLog(@"プッシュ直後");
		
		[ekitanTable release];
	}

	selected = NO;
	
    
    
	//通信による取得データを全部表示（開発用）
#ifdef Log
    NSLog(@"%@",[[[NSString alloc] initWithData:recieveData encoding:NSShiftJISStringEncoding] autorelease]);
#endif
    
}




#pragma mark HTML Parse methods



//HTMLパース部分


//タグ内の情報を取得したい場合はstartElementName内で判別取得する
- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes {
	
	int attIndex;
	BOOL isFeed;
	BOOL isFeed2;
	
	//画面判別のための準備（フラグ立て）
	if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
		attIndex = 0;
		isFeed = NO;		
		while (attributes != NULL && attributes[attIndex] != NULL) {
			if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "selected", sizeof("selected")) == 0) {
				isFeed = YES;
			}
			if (isFeed == YES) {
				typeDetect= YES;
				isFeed = NO;
			}
			attIndex += 1;
		}
	}
	
	if (strncmp((const char*) name, "p", sizeof("p")) == 0) {
		attIndex = 0;
		isFeed = NO;		
		while (attributes != NULL && attributes[attIndex] != NULL) {
			if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "alert", sizeof("alert")) == 0) {
				isFeed = YES;
			}
			if (isFeed == YES) {
				nextEkitanType = kEkitanNotFound;
				isFeed = NO;
			}
			attIndex += 1;
		}
	}
	
	
	
	/* 解析データ事例
	 <form style="margin: 0px;" target="_parent" name="TimetableReSearchForm" id="TimetableReSearchForm" action="" method="get">
	 <input type="hidden" name="SFCODE" ID="SRCH_SF" value="3012" />
	 <input type="hidden" name="SFNAME" ID="SRCH_NAME" value="本郷三丁目" />
	 <input type="hidden" name="D" ID="SRCH_MONTH" value="" />
	 
	 */
	
	if (strncmp((const char *) name, "form", sizeof("form")) == 0) {
#ifdef Log
		NSLog(@"Form In !!!!!");
#endif
		if (inForm == YES) { //すでにFormタグ内か？
			formCount += 1;
		}
		attIndex = 0;
		isFeed = NO;
		//抽出部分判別のためのフラグ立て
		while (attributes != NULL && attributes[attIndex] != NULL) {
			//路線一覧部分のフラグ立て
			if (strncmp((const char *)attributes[attIndex], "style", sizeof("style")) == 0 && strncmp((const char *)attributes[attIndex+2], "target", sizeof("target")) == 0) {
				isFeed = YES;
			}
			if (isFeed == YES) {
				inForm = YES; //はじめてFromタグ内に入る
				formCount = 1;
			}
			attIndex += 1;
		}
	}
	
	
	if (inForm == YES) {
		if (strncmp((const char *) name, "input", sizeof("input")) == 0) {
			
			attIndex = 0;
			isFeed = NO;
			isFeed2 = NO;
			while (attributes != NULL && attributes[attIndex] != NULL) {
				if (strncmp((const char *)attributes[attIndex], "name", sizeof("name")) == 0 && strncmp((const char *)attributes[attIndex+1], "SFCODE", sizeof("SFCODE")) == 0) {
#ifdef Log
					NSLog(@"Form In: SFCODE !!!!!");
#endif
					isFeed = YES;
				}
				if (strncmp((const char *)attributes[attIndex], "name", sizeof("name")) == 0 && strncmp((const char *)attributes[attIndex+1], "SFNAME", sizeof("SFNAME")) == 0) {
#ifdef Log
					NSLog(@"Form In  STATION !!!!!");
#endif
					isFeed2 = YES;
				}
				
				if (isFeed == YES) {
					NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
					sfcode = key;
#ifdef Log
					NSLog(@"sfcode: %@",sfcode);
#endif
					isFeed = NO;
				}
				if (isFeed2 == YES) {
					NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
					stationValue = key;
#ifdef Log
					NSLog(@"stationValue: %@",stationValue);
#endif
					isFeed2 = NO;
				}
				attIndex += 1;
			}
			
		}
	}
	
	
	//駅選択画面の場合
	if (nextEkitanType == kEkitanEkiSelect) {
		/*
		 <select class="sug_name_list" name="SFNameList" id="SFNameList"  size=9>
		 <option selected value="4455">名古屋</option>
		*/
		if (strncmp((const char *) name, "select", sizeof("select")) == 0) {
			if (inDiv == YES) {
				divCount += 1;
			}
			
			attIndex = 0;
			isFeed = NO;
			
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//抽出部分判別
				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "sug_name_list", sizeof("sug_name_list")) == 0) {
					isFeed = YES;
				}
				if (isFeed == YES) {
					inDiv = YES;
					divCount = 1;
				}
				attIndex += 1;
			}			
		}

		if (inDiv == YES) {
			if (strncmp((const char *) name, "option", sizeof("option")) == 0) {
				attIndex = 0;
				isFeed = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					//SFCODE
					if (strncmp((const char *)attributes[attIndex], "value", sizeof("value")) == 0) {
						isFeed = YES;
					}
					
					if (isFeed == YES) {
						cellData = [[NSMutableDictionary alloc] init];
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:key forKey:@"sfcode"];
						[key release];
						isFeed = NO;
#ifdef Log
						NSLog(@"     [sfcode:%@]\n",[cellData objectForKey:@"sfcode"]);
#endif
					}
					attIndex += 1;
				}
			}		
		}		
	}
	
	
	//路線選択画面の場合
	if (nextEkitanType == kEkitanRosenSelect) {

		
		/* start
		 <div class="ekimod_header">
		 <h2>本郷三丁目駅<span style="padding-left:16px;">[ほんごうさんちょうめ]</span></h2>
		 </div>
		 <div class="ekimod_content">
		 <!--私鉄リスト--><h3>私鉄</h3><div class="line_dr_lists">
		 <dl class="clearfix">
		 <dt><span>都営大江戸線</span></dt>
		 <dd>[<a href="./TimeStation/225-21_D1.shtml">飯田橋・都庁前方面</a>]</dd>
		 <dd>[<a href="./TimeStation/225-21_D2.shtml">上野御徒町・両国方面</a>]</dd>
		 </dl>
		 */
		
		if (strncmp((const char *) name, "div", sizeof("div")) == 0) {
#ifdef Log
			NSLog(@"Div In !!!!!");
#endif
			if (inDiv == YES) {
				divCount += 1;
			}
			attIndex = 0;
			isFeed = NO;
			//抽出部分判別のためのフラグ立て
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//路線一覧部分のフラグ立て
//				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "ekimod_content", sizeof("ekimod_content")) == 0) {
//上の条件だと重複認識する部分あるため下を使用
				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "line_dr_lists", sizeof("line_dr_lists")) == 0) {
					isFeed = YES;
				}
				if (isFeed == YES) {
					inDiv = YES;
					divCount = 1;
				}
				attIndex += 1;
			}
		}
		
		if (inDiv == YES) {
			if (strncmp((const char *) name, "a", sizeof("a")) == 0) {
				
				attIndex = 0;
				isFeed = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					if (strncmp((const char *)attributes[attIndex], "href", sizeof("href")) == 0) {
						isFeed = YES;
					}
					
					if (isFeed == YES) {
						cellData = [[NSMutableDictionary alloc] init];
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:[key stringByReplacingOccurrencesOfString:@"./TimeStation/" withString:@"/"] forKey:@"url"];
						[key release];
						isFeed = NO;
					}
					attIndex += 1;
				}
				
			}		
		}
	}
	
	
	//時刻表画面の場合
	if (nextEkitanType == kEkitanTimeTable) {

		
		if (strncmp((const char *) name, "div", sizeof("div")) == 0) {
			
			attIndex = 0;
			isFeed = NO;
			
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//曜日判別
				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0) {
					isFeed = YES;
				}
				if (isFeed) {
					if (strncmp((const char *)attributes[attIndex], "ekimod weekday", sizeof("ekimod weekday")) == 0) {
						daytypeValue = kDaytypeWeekday;
					}
					if (strncmp((const char *)attributes[attIndex], "ekimod saturday", sizeof("ekimod saturday")) == 0) {
						daytypeValue = kDaytypeSaturday;
					}
					if (strncmp((const char *)attributes[attIndex], "ekimod holiday", sizeof("ekimod holiday")) == 0) {
						daytypeValue = kDaytypeHolyday;
					}
				}
				attIndex += 1;
			}			
		}

		
		if (strncmp((const char *) name, "table", sizeof("table")) == 0) {
			if (inDiv == YES) {
				divCount += 1;
			}
			
			attIndex = 0;
			isFeed = NO;
			
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//抽出部分判別
				if (strncmp((const char *)attributes[attIndex], "summary", sizeof("summary")) == 0 && strncmp((const char *)attributes[attIndex+1], "電車時刻表", sizeof("電車時刻表")) == 0) {
					isFeed = YES;
				}
				if (isFeed == YES) {
					inDiv = YES;
					divCount = 1;
				}
				attIndex += 1;
			}			
		}
		
		if (inDiv == YES) {
			if (strncmp((const char *) name, "ul", sizeof("ul")) == 0) {
#ifdef Log
				NSLog(@"<%s>\n",name);
#endif
				attIndex = 0;
				isFeed = NO;
				isFeed2 = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					//行先と種別
                    //20130130変更
					if (strncmp((const char *)attributes[attIndex], "stnm", sizeof("stnm")) == 0) {
                        if (attributes[attIndex+2] != NULL) {                            
                            if (strncmp((const char *)attributes[attIndex+2], "lgkd", sizeof("lgkd")) == 0) {
                                isFeed = YES;
                            }
                        }
					}

					if (isFeed == YES) {
						cellData = [[NSMutableDictionary alloc] init];
						
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:key forKey:@"destination"];
						[key release];

						key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+3] encoding:NSUTF8StringEncoding];
						[cellData setValue:key forKey:@"kind"];
						[key release];

						isFeed = NO;
						
#ifdef Log
						NSLog(@"[行き先：%@]\n",[cellData objectForKey:@"destination"]);
						NSLog(@"[種別：%@]\n",[cellData objectForKey:@"kind"]);		
#endif
					}

					if (strncmp((const char *)attributes[attIndex], "lgkd", sizeof("lgkd")) == 0 && !attIndex) {
						isFeed2 = YES;
					}
						
					if (isFeed2 == YES) {
						cellData = [[NSMutableDictionary alloc] init];
			
						NSString *key;							
						key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:key forKey:@"kind"];
						[key release];
						
						isFeed2 = NO;
					}

					attIndex += 1;
				}
			}		
		}

	}
	
	
	[_currentCharacters release], _currentCharacters = nil;
	_currentCharacters = [[NSMutableString string] retain];
	
}



//タグで挟まれた情報を取得したい場合はendElementName内で判別取得する
- (void)endElementName:(const xmlChar*)name {
	
	//画面の判別
	if (typeDetect) {
		if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"エラー画面",nil)]) {
#ifdef Log
			NSLog(@"------0 エラー画面---------\n\n");
#endif
				nextEkitanType = kEkitanNotFound;
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"駅名選択",nil)]) {
#ifdef Log
				NSLog(@"------1 駅名選択!!!---------\n\n");
#endif
				nextEkitanType = kEkitanEkiSelect;
				sectionDatas = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"路線・方面選択",nil)]) {
#ifdef Log
				NSLog(@"------2 路線選択!!!---------\n\n");
#endif
				nextEkitanType = kEkitanRosenSelect;
				allDatas = [[NSMutableDictionary alloc] init];
				keyTitles = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻表検索結果",nil)]) {
#ifdef Log
				NSLog(@"------3 時刻表!!!---------\n\n");
#endif
				nextEkitanType = kEkitanTimeTable;
				allDatas = [[NSMutableDictionary alloc] init];
				keyTitles = [[NSMutableArray alloc] init];
			}
		}
		typeDetect = NO;
	}
	
	
	//駅名取得用start部分と対応（もっとも必要ないかもね…）
	if (strncmp((const char *) name, "form", sizeof("form")) == 0) {
		if (inForm == YES) {
			formCount -= 1;
		}
		
		if (formCount <= 0 && inForm == YES) {
			if (inForm == YES) {
			}
			inForm = NO;
		}
		
	}
	
	
	
	//駅選択画面の場合
	if (nextEkitanType == kEkitanEkiSelect) {
		/*
		 <select class="sug_name_list" name="SFNameList" id="SFNameList"  size=9>
		 <option selected value="4455">名古屋</option>
		 <option  value="4104">近鉄名古屋</option>
		 <option  value="4267">名鉄名古屋</option>
		*/
		if (strncmp((const char *) name, "select", sizeof("select")) == 0) {
			if (inDiv == YES) {
				divCount -= 1;
			}
			
			if (divCount <= 0) {
				inDiv = NO;
			}
		}
		
		if (inDiv == YES) {		
			//駅名
			if (strncmp((const char *) name, "option", sizeof("option")) == 0) {
				[cellData setValue:_currentCharacters forKey:@"ekiname"];
				[sectionDatas addObject:cellData];
				[cellData release];
#ifdef Log
				NSLog(@"     [eki:%@]\n",[[sectionDatas lastObject] objectForKey:@"ekiname"]);
#endif
			}
		}
	}
	
	
	//路線選択画面の場合
	if (nextEkitanType == kEkitanRosenSelect) {
		
		/* end
		 <div class="ekimod_header">
		 <h2>本郷三丁目駅<span style="padding-left:16px;">[ほんごうさんちょうめ]</span></h2>
		 </div>
		 <div class="ekimod_content">
		 <!--私鉄リスト--><h3>私鉄</h3><div class="line_dr_lists">
		 <dl class="clearfix">
		 <dt><span>都営大江戸線</span></dt>
		 <dd>[<a href="./TimeStation/225-21_D1.shtml">飯田橋・都庁前方面</a>]</dd>
		 <dd>[<a href="./TimeStation/225-21_D2.shtml">上野御徒町・両国方面</a>]</dd>
		 </dl>
		*/
		
		//抽出部分判別
		if (strncmp((const char *) name, "div", sizeof("div")) == 0) {
			if (inDiv == YES) {
				divCount -= 1;
			}
			
			if (divCount <= 0 && inDiv == YES) {
				if (inDiv == YES) {
#ifdef Log
					NSLog(@"END-section-last");
#endif
				}
				inDiv = NO;
			}
						
		}
		
		
		if (inDiv == YES) {		
			//路線
			if (strncmp((const char *) name, "span", sizeof("span")) == 0) {
				
				if (sectionDatas != nil) {
					//最初の一回だけ実行しない部分
					
					NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
					[allDatas setValue:sectionDatas forKey:noKey];
                    if (rosenValue != nil) {
                        [keyTitles addObject:rosenValue];
                    }
					[noKey release];
					[rosenValue release];
					rosenValue = nil;
					
					secNo += 1;
					
					[sectionDatas release];
					sectionDatas = nil;
				}
				
				sectionDatas = [[NSMutableArray alloc] init];
				rosenValue = [[NSMutableString alloc] initWithString:_currentCharacters];
				
			}
			
			//方面
			if (strncmp((const char *) name, "a", sizeof("a")) == 0) {
				homenValue = [[NSMutableString alloc] initWithString:_currentCharacters];
				[cellData setValue:rosenValue forKey:@"rosen"];
				[cellData setValue:homenValue forKey:@"direction"];
				[homenValue release];
				[sectionDatas addObject:cellData];
				[cellData release];
				cellData = nil;

#ifdef Log
				NSLog(@"        -> [1:%@]",[[sectionDatas lastObject] objectForKey:@"rosen"]);
				NSLog(@"        -> [2:%@]",[[sectionDatas lastObject] objectForKey:@"direction"]);
				NSLog(@"        -> [3:%@]\n\n",[[sectionDatas lastObject] objectForKey:@"url"]);
#endif
			}
		}

	}
	
	
	
	//時刻表画面の場合
	if (nextEkitanType == kEkitanTimeTable) {
		
		if (strncmp((const char *) name, "table", sizeof("table")) == 0) {
			if (inDiv == YES) {
				divCount -= 1;
			}
			
			if (divCount <= 0) {
				inDiv = NO;
			}
		}
		
		if (inDiv == YES) {
			//分
			if (strncmp((const char *) name, "em", sizeof("em")) == 0) {

				[cellData setObject:_currentCharacters forKey:@"dep_minute"];
				[cellData setObject:rosenValue forKey:@"dep_hour"];
//				[cellData setValue:rosenValue forKey:@"dep_hour"];
				
#ifdef Log
				NSLog(@"[Min: %@]-------\n",_currentCharacters);
//				NSLog(@"[Mint: %@]-------\n",[[sectionDatas lastObject] objectForKey:@"dep_minute"]);
				NSLog(@"</%s>\n",name);
#endif
                if (sectionDatas != nil && cellData != nil) {
                    [sectionDatas addObject:cellData];
                }
                else {
                    NSLog(@"sectionDatas Nil!!!");
                }
				[cellData release];
				cellData = nil;
                
			}
			//時
			if (strncmp((const char *) name, "th", sizeof("th")) == 0) {
				if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻",nil)]) {
#ifdef Log
					NSLog(@"[Hour: はじまっちゃいます]===============\n");
#endif
				}
				else {
					if (sectionDatas != nil) {
						//最初の一回だけ実行しない部分
						NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
						[allDatas setValue:sectionDatas forKey:noKey];
                        if (rosenValue != nil) {
                            [keyTitles addObject:rosenValue];
                        }
						[noKey release];
						[rosenValue release];
						rosenValue = nil;
#ifdef Log
						NSLog(@"[Hour: %@]============\n",[[sectionDatas lastObject] objectForKey:@"dep_hour"]);
#endif
						secNo += 1;
						
						[sectionDatas release];
						sectionDatas = nil;
					}
					
					sectionDatas = [[NSMutableArray alloc] init];
					rosenValue = [[NSMutableString alloc] initWithString:_currentCharacters];
				}

#ifdef Log
				NSLog(@"</%s>\n",name);
#endif
                
			}
		}
		
	}
	
	
	[_currentCharacters release], _currentCharacters = nil;
	
	
}


- (void)charactersFound:(const xmlChar*)ch len:(int)len {
    // 文字列を追加する
    if (_currentCharacters) {
        NSString*   string;
        string = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
        [_currentCharacters appendString:string];
        [string release];
    }
}




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

#ifdef Log
    NSLog(@"numOfSec");
    NSLog(@"numOfSec::%d",[keys count]);
#endif
    
	if (viewEkitanType == kEkitanEkiSelect) {
		return 1;
	}
	else if (viewEkitanType == kEkitanRosenSelect) {
		return [keys count];
	}
	else if (viewEkitanType == kEkitanTimeTable) {
		return [keys count];
	}
	return 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

#ifdef Log
    NSLog(@"numOfRowInSec");
	NSLog(@"numOfRowInSec::%d",[[tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
    
	if (viewEkitanType == kEkitanEkiSelect) {
		return [tableSectionDatas count];
	}
	else if (viewEkitanType == kEkitanRosenSelect) {
		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		NSInteger ret = [[tableAllDatas valueForKey:key_str] count];
		[key_str release];
		return ret;	
	}
	else if (viewEkitanType == kEkitanTimeTable) {
		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		NSInteger ret = [[tableAllDatas valueForKey:key_str] count];
		[key_str release];
		return ret;	
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
#ifdef Log
	NSLog(@"cellFor");
#endif
    
    NSInteger section = [indexPath section];
	NSInteger row = [indexPath row];
	static NSString *CellIdentifier = @"EkiCell";
		
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (viewEkitanType == kEkitanTimeTable) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
    }
    
	
	if (viewEkitanType == kEkitanEkiSelect) {
		tableCellData = [tableSectionDatas objectAtIndex:row];
		cell.textLabel.text = [[tableCellData valueForKey:@"ekiname"] description];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if (viewEkitanType == kEkitanRosenSelect) {
		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		tableSectionDatas = [tableAllDatas objectForKey:key_str];
		[key_str release];
		tableCellData = [tableSectionDatas objectAtIndex:row];
		cell.textLabel.text = [[tableCellData valueForKey:@"direction"] description];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
	if (viewEkitanType == kEkitanTimeTable) {
		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		tableSectionDatas = [tableAllDatas objectForKey:key_str];
		[key_str release];
		tableCellData = [tableSectionDatas objectAtIndex:row];
		NSString *hour = [tableCellData valueForKey:@"dep_hour"];
		NSString *minute = [tableCellData valueForKey:@"dep_minute"];
		NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
		cell.textLabel.text = time;
		cell.detailTextLabel.text = [tableCellData valueForKey:@"kind"];
	}
    
	return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

#ifdef Log
	NSLog(@"secName:%@",[keys objectAtIndex:section]);
#endif
    
	if (viewEkitanType == kEkitanTimeTable) {
		return [NSString stringWithFormat:NSLocalizedString(@"%@ 時",nil),[keys objectAtIndex:section]];
	}
	else {
		return [keys objectAtIndex:section];		
	}

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (selected){
		return;
	}
	
	selected = YES;
	
    NSInteger section = [indexPath section];
	NSInteger row = [indexPath row];

	secNo = 0;
	inDiv = NO;
	divCount = 0;
	allDatas = nil;
	sectionDatas = nil;
	cellData = nil;
	
#ifndef Lump
	//ハンドルリストを使ってパーサのコンテキストの獲得
	_parserContext = htmlCreatePushParserCtxt(&gSAXHandler, self, NULL, 0, nil, XML_CHAR_ENCODING_NONE);
	_currentCharacters = nil;
#endif
    
	NSMutableString *ekitanBase = [[NSMutableString alloc] init];

	if (viewEkitanType == kEkitanEkiSelect) {
		tableCellData = [tableSectionDatas objectAtIndex:row];
		selectedTitle = [tableCellData objectForKey:@"ekiname"]; //駅名（kEkitanEkiSelect&selectedTitle）
		[ekitanBase setString:@"http://timetable.ekitan.com/train/TimeSearch?"];
		[ekitanBase appendString:@"SFNAME="];
		[ekitanBase appendString:[selectedTitle stringByURLEncoding:NSShiftJISStringEncoding]]; 
		[ekitanBase appendString:@"&SFCODE="];
		[ekitanBase appendString:[[tableSectionDatas objectAtIndex:row] objectForKey:@"sfcode"]];
		stationValue = selectedTitle;
	}
	else if (viewEkitanType == kEkitanRosenSelect) {
		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		tableSectionDatas = [tableAllDatas objectForKey:key_str];
		[key_str release];
		tableCellData = [tableSectionDatas objectAtIndex:row];
		selectedTitle = [tableCellData objectForKey:@"direction"];
		[ekitanBase setString:@"http://timetable.ekitan.com/train/TimeStation"];
		NSString *url =[tableCellData objectForKey:@"url"];
		[ekitanBase appendString:url];
		ekitanUrl = [[NSString alloc] initWithString:url];
		directionValue = selectedTitle;
		lineValue = [tableCellData objectForKey:@"rosen"];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		selected = NO;
		[ekitanBase release];
		return;	
	}


	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ekitanBase]];
	[ekitanBase release];

	[req setHTTPMethod:@"GET"];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];

    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
	
#ifdef Log
	NSLog(@"\nDownload Done!!!!!!");
#endif
    
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {

//ほとんどが受け渡しのために用意されているのでメモリ解放しない

	[overlay release];
	[working release];	
	
	[urlValue release];
	
	[urlConnection release];
	
	[ekitanUrl release];
	
//	[timesTable release];

/*
//判別によってメモリ確保する場合しない場合があるため

	[homenValue release];
	[rosenValue release];
	[_currentCharacters release];
 
	[keyTitles release];
	[cellData release];
	[sectionDatas release];
	[allDatas release];
	[nextEkitanType release];

	[daytypeValue release];
	[directionValue release];
	[lineValue release];
	[stationValue release];
	[selectedTitle release];
	
	[keys release];
	[tableCellData release];
	[tableSectionDatas release];
	[tableAllDatas release];
	[viewEkitanType release];
	[tableTitle release];
	[managedObjectContext release];

*/

    [super dealloc];
}

@end
