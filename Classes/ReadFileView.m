//
//  ReadFileView.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/07.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import "ReadFileView.h"
#import "EkitanTableView.h"


static void StartElementSAXFunc(void *ctx, const xmlChar *name, const xmlChar **atts)
{
	[(ReadFileView *)ctx startElementName:name attributes:atts];
}

static void EndElementSAXFunc(void *ctx, const xmlChar *name)
{
	[(ReadFileView *)ctx endElementName:name];
}

static void CharactersSAXFunc(void *ctx, const xmlChar *ch, int len)
{
	[(ReadFileView *)ctx charactersFound:ch len:len];
}

static xmlSAXHandler gSAXHandler = {
	.initialized = XML_SAX2_MAGIC,
	.startElement = StartElementSAXFunc,
	.endElement = EndElementSAXFunc,
	.characters = CharactersSAXFunc,
};



@implementation ReadFileView


@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize stationName;

@synthesize tableTitle;

@synthesize nextEkitanType;
@synthesize allDatas;
@synthesize sectionDatas;
@synthesize cellData;
@synthesize keyTitles;

@synthesize stationValue;
@synthesize sfcode;
@synthesize lineValue;
@synthesize directionValue;
@synthesize daytypeValue;

@synthesize urlConnection;

@synthesize recieveData;

@synthesize myParser;
@synthesize currentRecord;
@synthesize currentStringValue;

@synthesize rosenValue;
@synthesize homenValue;
@synthesize urlValue;

@synthesize overlay;
@synthesize working;
@synthesize overlayText;

@synthesize soundTock;

/*
 - (id) init {
 if (self == [super init]) {
 
 }
 return self;
 }
 */


- (void)removeView:(id)sender {
	
	[sender removeFromSuperview];
    
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
	
	//ストレッチボタンイメージの設定
	UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
	UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	[searchButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	
	UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
	UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	[searchButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
    
	
	//読み込み中表示
    CGRect screen_bounds = [[UIScreen mainScreen] bounds];
//    NSLog(@"screen_bounds %@", NSStringFromCGRect(screen_bounds));
    
//    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
//    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));
    
    
	CGRect vRect = CGRectMake(0, screen_bounds.size.height - 49, 320, 60);
//	CGRect vRect = CGRectMake(0, 431, 320, 60);
	overlay = [[UIView alloc] initWithFrame:vRect];
	overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    
	CGRect fRect = CGRectMake(20, 20, 20, 20);
	working = [[UIActivityIndicatorView alloc] initWithFrame:fRect];
	[overlay addSubview:working];
    
	CGRect tRect = CGRectMake(60, 20, 240, 20);
	overlayText = [[UILabel alloc] initWithFrame:tRect];
	[overlayText setFont:[UIFont boldSystemFontOfSize:18]];
	overlayText.textAlignment = UITextAlignmentLeft;
	[overlayText setText:NSLocalizedString(@"Please Wait...",nil)];
	overlayText.textColor = [UIColor whiteColor];
	overlayText.backgroundColor = [UIColor clearColor];
	[overlay addSubview:overlayText];
    
	[UIView setAnimationsEnabled:YES];
    
	stationName.clearsOnBeginEditing = NO;
	stationName.clearButtonMode = UITextFieldViewModeWhileEditing;
	[stationName addTarget:self action:@selector(readFile:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[stationName becomeFirstResponder];
	
	stationValue = nil;
	lineValue = nil;
	directionValue = nil;
	
	recordin = NO;
	tagin = NO;
	typeDetect = NO;
    
}


- (IBAction)readFile:(id)sender {
	
	if (inAction){
		return;
	}
    /*
     NSURL*  url;
     url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"aif"]];
     
     // システムサウンドを作成する
     AudioServicesCreateSystemSoundID((CFURLRef)url, &soundTock);
     
     // サウンドを鳴らす
     AudioServicesPlaySystemSound(soundTock);
     */
	
	inAction = YES;
    
	secNo = 0;
	inDiv = NO;
	divCount = 0;
	sectionDatas = nil;
	
	if ([stationName.text isEqualToString:@""]) {
		inAction = NO;
		return;
	}
    
	[stationName resignFirstResponder];
	
	//ハンドルリストを使ってパーサのコンテキストの獲得
    
#ifndef Lump
	_parserContext = htmlCreatePushParserCtxt(&gSAXHandler, self, NULL, 0, nil, XML_CHAR_ENCODING_NONE);
	_currentCharacters = nil;
#endif
	currentRecord = [[[NSMutableDictionary alloc] init] retain];
    
	stationValue = [[NSString alloc] initWithString:stationName.text];
	
	NSMutableString *ekitanBase = [[NSMutableString alloc] init];
	
	[ekitanBase setString:@"http://timetable.ekitan.com/train/"];
	[ekitanBase appendString:@"TimeSearch?SFNAME="];
	[ekitanBase appendString:[stationValue stringByURLEncoding:NSShiftJISStringEncoding]];
	
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ekitanBase]];
	[ekitanBase release];
	
	[req setHTTPMethod:@"GET"];
	
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
    
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
    
    
#ifdef Log
    NSLog(@"\nDownload Done!!!!!!");
#endif
    
}


- (IBAction)reset:(id)sender {
	[stationName resignFirstResponder];
}


//通信ハンドル部分

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    [recieveData release]; recieveData = nil;
	recieveData = [[NSMutableData data] retain];

    //  self.recieveData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
#ifndef Lump
	htmlParseChunk(_parserContext, (const char*)[data bytes], [data length], 0);
#endif

    [recieveData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
#ifdef Log
    NSLog(@"Error!! - No Connection!");
#endif
    
#ifndef Lump
    htmlParseChunk(_parserContext, NULL, 0, YES);
	
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
		inAction = NO;
	}
#endif
    
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
    
	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"No Internet Connection...",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Failed",nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        inAction = NO;

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
		[cellData release];
		[sectionDatas release];
	}
    
#ifdef Log
    NSLog(@"Finish!!");
#endif
    
    
    
	//次画面への情報受け渡し（共通部分）
	EkitanTableView *ekitanTable = [[EkitanTableView alloc] init];	//次画面の生成
	ekitanTable.managedObjectContext = self.managedObjectContext;
	ekitanTable.viewEkitanType = nextEkitanType;	//次画面の表示タイプ
	ekitanTable.tableTitle = self.stationValue;
	ekitanTable.stationValue = self.stationValue;		//駅名
	ekitanTable.directionValue = self.directionValue;	//方面
	ekitanTable.lineValue = self.lineValue;				//路線
	
	
	//次画面への情報受け渡し（タイプ別）
	if (nextEkitanType == kEkitanRosenSelect) {
		ekitanTable.title = self.stationValue;
		ekitanTable.keys = keyTitles;
		ekitanTable.tableAllDatas = self.allDatas;
		[keyTitles release];
		[allDatas release];
	}
	else if (nextEkitanType == kEkitanEkiSelect) {
		ekitanTable.title = self.stationName.text;
		ekitanTable.tableSectionDatas = self.sectionDatas;
		[sectionDatas release];
	}
	else if (nextEkitanType == kEkitanTimeTable) {
		ekitanTable.title = self.stationValue;
		ekitanTable.keys = keyTitles;
		ekitanTable.tableAllDatas = self.allDatas;
		[keyTitles release];
		[allDatas release];
	}
	
	[[self navigationController] pushViewController:ekitanTable animated:YES];
	
	[ekitanTable release];
    
	inAction = NO;
    
#ifdef Log
	//通信による取得データを全部表示（開発用）
	NSLog(@"%@",[[[NSString alloc] initWithData:recieveData encoding:NSShiftJISStringEncoding] autorelease]);
#endif
    
}







//HTMLパース部分

- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes {
    
	int attIndex;
	BOOL isFeed;
	BOOL isFeed2;
    
	
	if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
		attIndex = 0;
		isFeed = NO;
		while (attributes != NULL && attributes[attIndex] != NULL) {
			if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "selected", sizeof("selected")) == 0) {
				isFeed = YES;
			}
			if (isFeed) {
				typeDetect= YES;
			}
			attIndex += 1;
		}
	}
	
	
	/* 解析ソース事例
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
                    sfcode = key;	//文字列ポインタ受け渡し（keyの解放は必要なし）
#ifdef Log
                    NSLog(@"sfcode: %@",sfcode);
#endif
                    isFeed = NO;
                }
                
                if (isFeed2 == YES) {
                    NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
                    stationValue = key;	//文字列ポインタ受け渡し（keyの解放は必要なし）
#ifdef Log
					NSLog(@"stationValue: %@",stationValue);
#endif
                    isFeed2 = NO;
                }
                attIndex += 1;
            }
			
		}
        
    }
    
	
    
	
    if (nextEkitanType == kEkitanEkiSelect) {
		
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

                if (isFeed) {
#ifdef Log
                    NSLog(@"inDiv = YES");
#endif
                    inDiv = YES;
                    divCount = 1;
                }
                attIndex += 1;
            }
            
        }
		
        if (inDiv) {
            if (strncmp((const char *) name, "option", sizeof("option")) == 0) {
                attIndex = 0;
                isFeed = NO;
                
                while (attributes != NULL && attributes[attIndex] != NULL) {
#ifdef Log
                    NSLog(@"[[%s]][[%s]][[%s]]",attributes[attIndex],attributes[attIndex+1],attributes[attIndex+2]);
#endif
                    //SFCODE
                    if (strncmp((const char *)attributes[attIndex], "value", sizeof("value")) == 0) {
                        isFeed = YES;
#ifdef Log
                        NSLog(@"inFeed = YES");
#endif
                    }
					
                    if (isFeed) {
                        cellData = [[NSMutableDictionary alloc] init];
                        NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
                        [cellData setValue:key forKey:@"sfcode"];
                        [key release];
                        isFeed = NO;
#ifdef Log
                        NSLog(@"     [sfcode:%@]\n",[cellData objectForKey:@"sfcode"]);
#endif
                    }

                    if (strncmp((const char *)attributes[attIndex], "selected", sizeof("selected")) == 0) {
                        attIndex += 2;
                    }
                    else {
                        attIndex += 1;
                    }
                }

            }
        }
    }
	
	
	
	if (nextEkitanType == kEkitanRosenSelect) {
		if (strncmp((const char *) name, "div", sizeof("div")) == 0) {
			if (inDiv == YES) {
				divCount += 1;
			}
			attIndex = 0;
			isFeed = NO;
			//抽出部分判別
			while (attributes != NULL && attributes[attIndex] != NULL) {
				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "line_dr_lists", sizeof("line_dr_lists")) == 0) {
					isFeed = YES;
				}
				if (isFeed) {
					inDiv = YES;
					divCount = 1;
				}
				attIndex += 1;
			}
		}
		if (inDiv) {
			if (strncmp((const char *) name, "a", sizeof("a")) == 0) {
				
				attIndex = 0;
				isFeed = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					if (strncmp((const char *)attributes[attIndex], "href", sizeof("href")) == 0) {
						isFeed = YES;
					}
					
					if (isFeed) {
						cellData = [[NSMutableDictionary alloc] init];
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:[key stringByReplacingOccurrencesOfString:@"./TimeStation/" withString:@"/"] forKey:@"url"];
                        //						[cellData setValue:key forKey:@"url"];
						[key release];
						isFeed = NO;
					}
					attIndex += 1;
				}
				
			}
		}
	}
	
	
	if (nextEkitanType == kEkitanTimeTable) {
        //		NSLog(@"<%s>\n",name);
	}
	
	
	[_currentCharacters release], _currentCharacters = nil;
	_currentCharacters = [[NSMutableString string] retain];
    
}




- (void)endElementName:(const xmlChar*)name {
    
	if (typeDetect) {
		if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"エラー画面",nil)]) {
				nextEkitanType = kEkitanNotFound;
#ifdef Log
				NSLog(@"\n\n------0 エラー画面---------\n\n");
#endif
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"駅名選択",nil)]) {
				nextEkitanType = kEkitanEkiSelect;
#ifdef Log
				NSLog(@"\n\n------1 駅名選択!!!---------\n\n");
#endif
				sectionDatas = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"路線・方面選択",nil)]) {
				nextEkitanType = kEkitanRosenSelect;
#ifdef Log
				NSLog(@"\n\n------2 路線選択!!!---------\n\n");
#endif
				allDatas = [[NSMutableDictionary alloc] init];
				keyTitles = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻表検索結果",nil)]) {
				nextEkitanType = kEkitanTimeTable;
#ifdef Log
				NSLog(@"\n\n------3 時刻表!!!---------\n\n");
#endif
			}
		}
		typeDetect = NO;
	}
	
	
	if (nextEkitanType == kEkitanRosenSelect) {
		//抽出部分判別
		if (strncmp((const char *) name, "div", sizeof("div")) == 0) {
			if (inDiv) {
				divCount -= 1;
			}
            
			if (divCount <= 0 && inDiv == YES) {
				if (inDiv) {
#ifdef Log
                    NSLog(@"END-section-last");
#endif
				}
				inDiv = NO;
			}
		}
        
		
		if (inDiv) {
			//路線
			if (strncmp((const char *) name, "span", sizeof("span")) == 0) {
                
				if (sectionDatas != nil) {
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
                 NSLog(@"\n\n    -> [1:%@]",[cellData objectForKey:@"rosen"]);
                 NSLog(@"    -> [2:%@]",[cellData objectForKey:@"direction"]);
                 NSLog(@"    -> [3:%@]",[cellData objectForKey:@"url"]);
                 NSLog(@"\n\n        -> [1:%@]",[[sectionDatas lastObject] objectForKey:@"rosen"]);
                 NSLog(@"        -> [2:%@]",[[sectionDatas lastObject] objectForKey:@"direction"]);
                 NSLog(@"        -> [3:%@]",[[sectionDatas lastObject] objectForKey:@"url"]);
#endif
			}
		}
	}
    
	
	if (nextEkitanType == kEkitanEkiSelect) {
        
		if (strncmp((const char *) name, "select", sizeof("select")) == 0) {
			if (inDiv) {
				divCount -= 1;
			}
			
			if (divCount <= 0) {
				inDiv = NO;
			}
		}
		
		if (inDiv) {
			//駅名
#ifdef Log
            NSLog(@"     [_currentCharacters:%@]\n",_currentCharacters);
#endif
			if (strncmp((const char *) name, "option", sizeof("option")) == 0) {
                if (cellData != nil) {
                    [cellData setValue:_currentCharacters forKey:@"ekiname"];
                    [sectionDatas addObject:cellData];
                    [cellData release];
                }
                else{
                    cellData = [[NSMutableDictionary alloc] init];
                    [cellData setValue:_currentCharacters forKey:@"ekiname"];
                    [sectionDatas addObject:cellData];
                    [cellData release];
                    
                }
#ifdef Log
                NSLog(@"     [eki:%@]\n",[[sectionDatas lastObject] objectForKey:@"ekiname"]);
#endif
			}
		}
		
		
	}
    
	
	if (nextEkitanType == kEkitanTimeTable) {
#ifdef Log
            NSLog(@"<%s>\n",name);
#endif
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





/*（別アプリの残骸）
 
 //XMLパース部分
 - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
 
 //レコード開始処理，currentRecordの記憶領域確保
 if ([elementName isEqualToString:@"record"]) {
 recordin = YES;
 currentRecord = [[[NSMutableDictionary alloc] init] autorelease];
 }
 tagin = YES;
 }
 
 - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
 
 tagin = NO;
 if ([elementName isEqualToString:@"record"]) {
 recordin = NO;
 
 //record毎にで個別辞書の記録を行なう
 
 //		NSString *refKey = [currentRecord objectForKey:@"id"];
 //		time = [NSEntityDescription insertNewObjectForEntityForName:@"time" inManagedObjectContext:managedObjectContext];
 
 //		[time setValue:[NSDate date] forKey:@""];
 //		[time setValue:[tempValues objectForKey:@"Station:"] forKey:@"stationName"];
 
 //		NSLog(@"-------------------Pass!!:%@",[currentRecord objectForKey:@"paper_author"]);
 
 //		[currentRecord release];
 //		autoreleseしているのでいらない
 
 return;
 }
 else if ([elementName isEqualToString:@"records"]) {
 
 //全レコードが読み込み完了したら，分類した配列をlistsに統合して記録
 
 NSError *error;
 [managedObjectContext save:&error];
 
 return;
 }
 else {
 //キー値とcurrentStringValueの値をcurrentRecord(Dic)に追記
 if (recordin) {
 [currentRecord setObject:currentStringValue forKey:elementName];
 }
 }
 
 //	NSLog(@"Get!!:  %@",[currentRecord objectForKey:elementName]);
 
 [currentStringValue release];
 currentStringValue = nil;
 
 }
 
 
 - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
 
 //currentStringValueを領域確保し文字を追記
 if (!currentStringValue) {
 currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
 }
 
 if (recordin && tagin) {
 [currentStringValue appendString:string];
 }
 
 }
 
 （別アプリの残骸）*/


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


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


- (void)dealloc {
	[super dealloc];
	
	[stationName release];
    
	[urlValue release];
	[homenValue release];
	[rosenValue release];
	
	
	[currentStringValue release];
	[currentRecord release];
	[myParser release];
	
	[recieveData release];
	
	[urlConnection release];
    
    
	[managedObjectContext release];
	[fetchedResultsController release];
	
	
	[directionValue release];
	[lineValue release];
	[sfcode release];
	[stationValue release];
	
    
	
    /*
     //判別によってメモリ確保する場合しない場合があるため
     [keyTitles release];
     [cellData release];
     [sectionDatas release];
     [allDatas release];
     //	[nextEkitanType release];
     */
	
	
	[tableTitle release];
	
	//下があるとタブタップでクラッシュする
	//[_currentCharacters release];
    
}


@end
