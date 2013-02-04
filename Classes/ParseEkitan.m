//
//  ParseEkitan.m
//  TT
//
//  Created by Kotatsu RIN on 09/12/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ParseEkitan.h"


static void StartElementSAXFunc(void *ctx, const xmlChar *name, const xmlChar **atts)
{
	[(ParseEkitan *)ctx startElementName:name attributes:atts];
}

static void EndElementSAXFunc(void *ctx, const xmlChar *name)
{
	[(ParseEkitan *)ctx endElementName:name];
}

static void CharactersSAXFunc(void *ctx, const xmlChar *ch, int len)
{
	[(ParseEkitan *)ctx charactersFound:ch len:len];
}

static xmlSAXHandler gSAXHandler = {
	.initialized = XML_SAX2_MAGIC,
	.startElement = StartElementSAXFunc,
	.endElement = EndElementSAXFunc, 
	.characters = CharactersSAXFunc,
};


@implementation ParseEkitan

@synthesize callparent;
@synthesize nowURL;
@synthesize whichSite;

@synthesize managedObjectContext;

@synthesize tableTitle;
@synthesize viewEkitanType;

@synthesize toEkitan;

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

@synthesize ekitanUrl;

@synthesize nextEkitanType;
@synthesize allDatas;
@synthesize sectionDatas;
@synthesize cellData;
@synthesize keyTitles;

@synthesize weekdayAllDatas;
@synthesize weekdayKeys;

@synthesize saturdayAllDatas;
@synthesize saturdayKeys;

@synthesize holydayAllDatas;
@synthesize holydayKeys;

@synthesize urlConnection;

@synthesize _currentCharacters;

@synthesize rosenValue;
@synthesize homenValue;
@synthesize urlValue;



- (id) init {
	if (self == [super init]) {
		
		deleteKeyword = [[NSArray alloc] initWithObjects:@",時刻表",@",JR時刻表",@",乗り換え案内",@",路線",@",路線図",@",駅探",nil];	

	}
	return self;
}




#pragma mark Connection Handle methods


//通信ハンドル部分

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	//	self.recieveData = [NSMutableData data];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	htmlParseChunk(_parserContext, (const char*)[data bytes], [data length], 0);
	
	//	[self.recieveData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
//	NSLog(@"Error!!");
	
	htmlParseChunk(_parserContext, NULL, 0, YES);
	
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
		selected = NO;
		selectedSeg = NO;
	}
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"No Internet Connection...",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Failed",nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	
//	NSLog(@"Connection did fail with error: %@",[error localizedDescription]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (nextEkitanType == kEkitanTimeTable) {
		
		if (daytypeValue == kDaytypeWeekday) {
//			NSLog(@"Weekday");
			
			NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
			[weekdayAllDatas setValue:sectionDatas forKey:noKey];
            if (rosenValue != nil) {
                [weekdayKeys addObject:rosenValue];
            }
			[noKey release];
			[rosenValue release];
			rosenValue = nil;
			
			[sectionDatas release];
			sectionDatas = nil;
			weekdayDone = YES;
		}
		
		if (daytypeValue == kDaytypeSaturday) {
//			NSLog(@"Saturday");
			
			NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
			[saturdayAllDatas setValue:sectionDatas forKey:noKey];
            if (rosenValue != nil) {
                [saturdayKeys addObject:rosenValue];
            }
            [noKey release];
			[rosenValue release];
			rosenValue = nil;
			
			[sectionDatas release];
			sectionDatas = nil;			
			saturdayDone = YES;
		}
		
		if (daytypeValue == kDaytypeHolyday) {
//			NSLog(@"Holyday");
			
			NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
			[holydayAllDatas setValue:sectionDatas forKey:noKey];
            if (rosenValue != nil) {
                [holydayKeys addObject:rosenValue];
            }
			[noKey release];
			[rosenValue release];
			rosenValue = nil;
			
			[sectionDatas release];
			sectionDatas = nil;			
			holydayDone = YES;
		}
		
	}
	
	//	NSLog(@"Finish!!");
	
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
	}	
	
	
	//daytypeValue = selectDaytype;
	
	[self savingTimeData];
	
}




#pragma mark HTML Parse methods



//HTMLパース部分

- (void)startElementName:(const xmlChar*)name attributes:(const xmlChar**)attributes {
	
	int attIndex;
	BOOL isFeed;
	BOOL isFeed2;
	
	/*
	 <title>要町駅 時刻表｜東京メトロ有楽町線 和光市方面 平日｜電車 時刻表｜駅探</title>
	 <meta name="keywords" content="要町駅,東京メトロ有楽町線,時刻表,JR時刻表,乗り換え案内,路線,路線図,駅探" />
	 <meta name="description" content="要町駅 東京メトロ有楽町線（和光市方面） 平日の時刻表です。" />	 
	 */
	
	if (strncmp((const char*) name, "meta", sizeof("meta")) == 0) {
		attIndex = 0;
		isFeed = NO;		
		while (attributes != NULL && attributes[attIndex] != NULL) {
			if (strncmp((const char *)attributes[attIndex], "name", sizeof("name")) == 0 && strncmp((const char *)attributes[attIndex+1], "keywords", sizeof("keywords")) == 0) {
				isFeed = YES;
			}
			
			if (isFeed == YES) {
				NSMutableString *key = [[NSMutableString alloc] initWithCString:(char*)attributes[attIndex+3] encoding:NSUTF8StringEncoding];
//				NSLog(@"keyword: %@",key);
				
				NSRange delcharRange;
				NSString *delchar;
				for (delchar in deleteKeyword) {
					delcharRange = [key rangeOfString:delchar];
					[key deleteCharactersInRange:delcharRange];
				}
				
				delcharRange = [key rangeOfString:@","];
				NSRange delstationRange = NSMakeRange(0, delcharRange.location+1);
				[key deleteCharactersInRange:delstationRange];
				
				lineValue = key;
//				NSLog(@"keyword deleted: %@",key);
				
				isFeed = NO;
			}
			attIndex += 1;
		}
	}
	
	//判別
	if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
		attIndex = 0;
		isFeed = NO;		
		while (attributes != NULL && attributes[attIndex] != NULL) {
			if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "selected", sizeof("selected")) == 0) {
				isFeed = YES;
			}
			if (isFeed == YES) {
				typeDetect= YES;
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
//				NSLog(@"Day: %d",daytypeValue);
			}
			attIndex += 1;
		}
	}
	
	
	
	
	/*
	 <form style="margin: 0px;" target="_parent" name="TimetableReSearchForm" id="TimetableReSearchForm" action="" method="get">
	 <input type="hidden" name="SFCODE" ID="SRCH_SF" value="3012" />
	 <input type="hidden" name="SFNAME" ID="SRCH_NAME" value="本郷三丁目" />
	 <input type="hidden" name="D" ID="SRCH_MONTH" value="" />
	 
	 */
	
	if (strncmp((const char *) name, "form", sizeof("form")) == 0) {
//		NSLog(@"Form In !!!!!");
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
//					NSLog(@"Form In: SFCODE !!!!!");
					isFeed = YES;
				}
				if (strncmp((const char *)attributes[attIndex], "name", sizeof("name")) == 0 && strncmp((const char *)attributes[attIndex+1], "SFNAME", sizeof("SFNAME")) == 0) {
//					NSLog(@"Form In  STATION !!!!!");
					isFeed2 = YES;
				}
				
				if (isFeed == YES) {
					NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
					self.sfcode = key;
					[key release];
//					NSLog(@"sfcode: %@",sfcode);
					isFeed = NO;
				}
				if (isFeed2 == YES) {
					NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
					self.stationValue = key;
					[key release];
//					NSLog(@"stationValue: %@",stationValue);
					isFeed2 = NO;
				}
				attIndex += 1;
			}
			
		}
	}
	
	
	
	
	
	if (nextEkitanType == kEkitanTimeTable) {
		
		/*		
		 <div class="ekimod">
		 <!--  directionTab -->
		 <ul class="tabs clearfix">
		 <li class="selected">
		 <a class="link_ttb"   href="/train/TimeStation/180-0_D1.shtml">新宿・高尾方面</a>
		 </li>
		 </ul>
		 <!-- /directionTab -->
		 </div>
		 */
		
		if (strncmp((const char *) name, "ul", sizeof("ul")) == 0) {
			if (inUl == YES) {
				ulCount += 1;
			}
			attIndex = 0;
			isFeed = NO;
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//抽出部分判別
				if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "tabs clearfix", sizeof("tabs clearfix")) == 0) {
					isFeed = YES;
				}
				if (isFeed == YES) {
					inUl = YES;
					divCount = 1; //強制的に抽出終了
				}
				attIndex += 1;
			}			
		}
		
		if (inUl == YES) {
			if (strncmp((const char *) name, "li", sizeof("li")) == 0) {
				attIndex = 0;
				isFeed = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					if (strncmp((const char *)attributes[attIndex], "class", sizeof("class")) == 0 && strncmp((const char *)attributes[attIndex+1], "selected", sizeof("selected")) == 0) {
						inLi = YES;
//						NSLog(@"Selected: !!!!!");
						isFeed = YES;
					}
					
					if (isFeed == YES) {
						isFeed = NO;
					}
					attIndex += 1;
				}
			}	
		}
		
		//<table>内抽出エリアに入っているかどうか
		if (strncmp((const char *) name, "table", sizeof("table")) == 0) {
			if (inDiv == YES) {
				divCount += 1;
			}
			
			attIndex = 0;
			isFeed = NO;
			
			while (attributes != NULL && attributes[attIndex] != NULL) {
				//抽出部分判別
				//if (strncmp((const char *)attributes[attIndex], "summary", sizeof("summary")) == 0 && strncmp((const char *)attributes[attIndex+1], "電車時刻表", sizeof("電車時刻表")) == 0) {
				if (strncmp((const char *)attributes[attIndex], "summary", sizeof("summary")) == 0 && strncmp((const char *)attributes[attIndex+1], "電車時刻表", sizeof("電車時刻表")) == 0) {
					isFeed = YES;
				}
				if (isFeed == YES) {
					inDiv = YES;
					divCount = 1; //強制的に抽出終了
				}
				attIndex += 1;
			}			
		}
		
		//抽出エリアに入っている場合の処理
		if (inDiv == YES) {
			if (strncmp((const char *) name, "ul", sizeof("ul")) == 0) {
//				NSLog(@"<%s>\n",name);
				attIndex = 0;
				isFeed = NO;
				while (attributes != NULL && attributes[attIndex] != NULL) {
					//行先と種別
					if (strncmp((const char *)attributes[attIndex], "stnm", sizeof("stnm")) == 0 && strncmp((const char *)attributes[attIndex+2], "lgkd", sizeof("lgkd")) == 0) {
						isFeed = YES;
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
						
//						NSLog(@"[行き先：%@]\n",[cellData objectForKey:@"destination"]);		
//						NSLog(@"[種別：%@]\n",[cellData objectForKey:@"kind"]);		
						
					}
					
					if (strncmp((const char *)attributes[attIndex], "lgkd", sizeof("lgkd")) == 0 && !attIndex) {
						isFeed = YES;
					}
					
					if (isFeed == YES) {
						cellData = [[NSMutableDictionary alloc] init];
						
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
						[cellData setValue:key forKey:@"kind"];
						[key release];
						
						isFeed = NO;
					}
					
					attIndex += 1;
				}
			}		
		}
		
	}
	
	[_currentCharacters release], _currentCharacters = nil;
	_currentCharacters = [[NSMutableString string] retain];
	
}



- (void)endElementName:(const xmlChar*)name {
	
	//判別
	if (typeDetect) {
		if (strncmp((const char*) name, "li", sizeof("li")) == 0) {
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"エラー画面",nil)]) {
				nextEkitanType = kEkitanNotFound;
//				NSLog(@"------0 エラー画面---------\n\n");
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"駅名選択",nil)]) {
				nextEkitanType = kEkitanEkiSelect;
//				NSLog(@"------1 駅名選択!!!---------\n\n");
				sectionDatas = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"路線・方面選択",nil)]) {
				nextEkitanType = kEkitanRosenSelect;
//				NSLog(@"------2 路線選択!!!---------\n\n");
				allDatas = [[NSMutableDictionary alloc] init];
				keyTitles = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻表検索結果",nil)]) {
				nextEkitanType = kEkitanTimeTable;
//				NSLog(@"------3 時刻表!!!---------\n\n");
				
				if (selectDaytype == kDaytypeWeekday) {
					weekdayAllDatas = [[NSMutableDictionary alloc] init];
					weekdayKeys = [[NSMutableArray alloc] init];
				}
				if (selectDaytype == kDaytypeSaturday) {
					saturdayAllDatas = [[NSMutableDictionary alloc] init];
					saturdayKeys = [[NSMutableArray alloc] init];
				}
				if (selectDaytype == kDaytypeHolyday) {
					holydayAllDatas = [[NSMutableDictionary alloc] init];
					holydayKeys = [[NSMutableArray alloc] init];
				}
				
			}
		}
		typeDetect = NO;
	}
	
	
	
	if (nextEkitanType == kEkitanTimeTable) {
		
		/*		
		 <div class="ekimod">
		 <!--  directionTab -->
		 <ul class="tabs clearfix">
		 <li class="selected">
		 <a class="link_ttb"   href="/train/TimeStation/180-0_D1.shtml">新宿・高尾方面</a>
		 </li>
		 </ul>
		 <!-- /directionTab -->
		 </div>
		 */
		
		if (strncmp((const char *) name, "ul", sizeof("ul")) == 0) {
			if (inUl == YES) {
				ulCount -= 1;
			}
			
			if (ulCount <= 0) {
				inUl = NO;
				inLi = NO;
			}
		}
		
		
		if (inLi == YES) {
			if (strncmp((const char *) name, "a", sizeof("a")) == 0) {
				if ([_currentCharacters rangeOfString:NSLocalizedString(@"方面",nil)].length != 0) {
					directionValue = [[NSString alloc] initWithString:_currentCharacters];
//					NSLog(@"%@",_currentCharacters);
					inLi = NO;
				}
				
			}
		}
		
		
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
				
				[cellData setValue:_currentCharacters forKey:@"dep_minute"];
				[cellData setValue:rosenValue forKey:@"dep_hour"];
				[sectionDatas addObject:cellData];
				[cellData release];
				cellData = nil;
				
//				NSLog(@"[Mint: %@]-------\n",[[sectionDatas lastObject] objectForKey:@"dep_minute"]);
//				NSLog(@"</%s>\n",name);		
				
			}
			//時
			if (strncmp((const char *) name, "th", sizeof("th")) == 0) {
				if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻",nil)]) {
//					NSLog(@"[Hour: はじまっちゃいます]===============\n");
				}
				else {
					if (sectionDatas != nil) {
						//最初の一回だけ実行しない部分
						NSString *noKey = [[NSString alloc] initWithFormat:@"%d",secNo]; 
						//						NSString *noKey = [NSString stringWithFormat:@"%d",secNo]; 
						
						if (selectDaytype == kDaytypeWeekday) {
							[weekdayAllDatas setValue:sectionDatas forKey:noKey];
                            if (rosenValue != nil) {
                                [weekdayKeys addObject:rosenValue];
                            }
						}
						if (selectDaytype == kDaytypeSaturday) {
							[saturdayAllDatas setValue:sectionDatas forKey:noKey];
                            if (rosenValue != nil) {
                                [saturdayKeys addObject:rosenValue];
                            }
						}
						if (selectDaytype == kDaytypeHolyday) {
							[holydayAllDatas setValue:sectionDatas forKey:noKey];
                            if (rosenValue != nil) {
                                [holydayKeys addObject:rosenValue];
                            }
						}
						
						[noKey release];
						[rosenValue release];
						rosenValue = nil;
//						NSLog(@"[Hour: %@]============\n",[[sectionDatas lastObject] objectForKey:@"dep_hour"]);
						
						secNo += 1;
						
						[sectionDatas release];
						sectionDatas = nil;
					}
					
					sectionDatas = [[NSMutableArray alloc] init];
					rosenValue = [[NSMutableString alloc] initWithString:_currentCharacters];
				}
				
//				NSLog(@"</%s>\n",name);		
				
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



- (void)saveData {	
	
	secNo = 0;
	inDiv = NO;
	divCount = 0;
	sectionDatas = nil;
	cellData = nil;
	typeDetect = NO;
	
	
	_parserContext = htmlCreatePushParserCtxt(&gSAXHandler, self, NULL, 0, nil, XML_CHAR_ENCODING_NONE);
	_currentCharacters = nil;
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:nowURL];
	
	[req setHTTPMethod:@"GET"];
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];			
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	
}



- (void)connectionStarted {
	//	id pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//	[pool release];
}

- (void)connectionEnded {
	//	id pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//	[pool release];
}





#pragma mark SavetoCD methods




- (void)savingTimeData {
	
	id pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger maxNum;
	NSInteger newNum;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Table" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tableNo" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *arrayForCount = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSInteger tableCount = [arrayForCount count];
//	NSLog(@"fetch %d", tableCount);
	
	
	if (arrayForCount == nil) {
//		NSLog(@"CoreData Error");
	}
	
	//	NSLog(@"max: %@", [[maxObject objectAtIndex:0] valueForKey:@"maxID"]);
	
	[sortDescriptor release];
	[sortDescriptors release];
	[request release];
	
	if (tableCount == 0) {
		newNum = 1;
	}
	else {
		maxNum = [[[arrayForCount objectAtIndex:0] valueForKey:@"tableNo"] integerValue];
		newNum = (NSInteger)maxNum + 1;
		if (tableCount == newNum) {
			newNum += 1;
		}
	}
	
//	NSLog(@"max: %d", maxNum);
//	NSLog(@"new: %d", newNum);
	
	
	
	
	if (selectDaytype == kDaytypeWeekday) {
//		NSLog(@"CD:Weekday");
		
		NSManagedObject *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
		
		[newTable setValue:newLine forKey:@"thisLine"];
		[newTable setValue:newStation forKey:@"thisStation"];
		
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"orderNo"];
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"tableNo"];
		[newTable setValue:directionValue forKey:@"direction"];
		[newLine setValue:lineValue forKey:@"name"];
		[newStation setValue:stationValue forKey:@"name"];
		
		if (daytypeValue == kDaytypeWeekday) {
			[newTable setValue:NSLocalizedString(@"Weekday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			[newTable setValue:NSLocalizedString(@"Saturday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			[newTable setValue:NSLocalizedString(@"Holiday",nil) forKey:@"daytype"];
		}
		else {			
			[newTable setValue:NSLocalizedString(@"Everyday",nil) forKey:@"daytype"];
		}
		
		int sec = [weekdayKeys count];
		
		int startinghour = 99;
		for (int c_sec = 0; c_sec < sec; c_sec += 1) {
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",c_sec];
			NSArray *section = [weekdayAllDatas objectForKey:key_str];
			[key_str release];
			
			int unihour;
			if (startinghour == 99) {
				startinghour = [[[section objectAtIndex:0] valueForKey:@"dep_hour"] intValue];
//				NSLog(@"Starting %02d",startinghour);
				
			}
			
			int row = [section count];
			for (int c_row = 0; c_row < row; c_row +=1) {
				NSManagedObject *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
				NSManagedObject *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:self.managedObjectContext];
				[newTime setValue:newVehicle forKey:@"thisVehicle"];
				[newTime setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newLine forKey:@"Line"];
				
				NSDictionary *time = [section objectAtIndex:c_row];
				
				int p_hour = [[time valueForKey:@"dep_hour"] intValue];
				if (p_hour < startinghour) {
					unihour = startinghour + c_sec;
//					NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
				}
				else {
					unihour = p_hour;
				}
//				NSLog(@"unihour: %02d",unihour);
				
				[newTable setValue:[NSNumber numberWithInt:startinghour] forKey:@"startinghour"];
				[newTime setValue:[NSNumber numberWithInteger:unihour] forKey:@"dep_unihour"];
				[newTime setValue:[NSNumber numberWithInteger:p_hour] forKey:@"dep_hour"];
				[newTime setValue:[NSNumber numberWithInteger:[[time valueForKey:@"dep_minute"] integerValue]] forKey:@"dep_minute"];
				[newVehicle setValue:[time valueForKey:@"kind"] forKey:@"kind"];
				[newVehicle setValue:[time valueForKey:@"destination"] forKey:@"destination"];
				
			}
		}
	}
	
	if (selectDaytype == kDaytypeSaturday) {
//		NSLog(@"CD:Saturday");
		
		NSManagedObject *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
		
		[newTable setValue:newLine forKey:@"thisLine"];
		[newTable setValue:newStation forKey:@"thisStation"];
		
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"orderNo"];
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"tableNo"];
		[newLine setValue:lineValue forKey:@"name"];
		[newStation setValue:stationValue forKey:@"name"];
		[newTable setValue:directionValue forKey:@"direction"];
		
		if (daytypeValue == kDaytypeWeekday) {
			[newTable setValue:NSLocalizedString(@"Weekday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			[newTable setValue:NSLocalizedString(@"Saturday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			[newTable setValue:NSLocalizedString(@"Holiday",nil) forKey:@"daytype"];
		}
		else {			
			[newTable setValue:NSLocalizedString(@"Everyday",nil) forKey:@"daytype"];
		}
		
		int sec = [saturdayAllDatas count];
		
		int startinghour = 99;
		for (int c_sec = 0; c_sec < sec; c_sec += 1) {
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",c_sec];
			NSArray *section = [saturdayAllDatas valueForKey:key_str];
			[key_str release];
			
			int unihour;
			if (startinghour == 99) {
				startinghour = [[[section objectAtIndex:0] valueForKey:@"dep_hour"] intValue];
//				NSLog(@"Starting %02d",startinghour);
				
			}
			
			int row = [section count];
			for (int c_row = 0; c_row < row; c_row +=1) {
				NSManagedObject *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
				NSManagedObject *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:self.managedObjectContext];
				[newTime setValue:newVehicle forKey:@"thisVehicle"];
				[newTime setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newLine forKey:@"Line"];
				
				NSDictionary *time = [section objectAtIndex:c_row];
				
				int p_hour = [[time valueForKey:@"dep_hour"] intValue];
				if (p_hour < startinghour) {
					unihour = startinghour + c_sec;
//					NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
				}
				else {
					unihour = p_hour;
				}
//				NSLog(@"unihour: %02d",unihour);
				
				[newTable setValue:[NSNumber numberWithInt:startinghour] forKey:@"startinghour"];
				[newTime setValue:[NSNumber numberWithInteger:unihour] forKey:@"dep_unihour"];
				[newTime setValue:[NSNumber numberWithInteger:p_hour] forKey:@"dep_hour"];
				[newTime setValue:[NSNumber numberWithInteger:[[time valueForKey:@"dep_minute"] integerValue]] forKey:@"dep_minute"];
				[newVehicle setValue:[time valueForKey:@"kind"] forKey:@"kind"];
				[newVehicle setValue:[time valueForKey:@"destination"] forKey:@"destination"];
			}
			
		}
		
	}
	
	if (selectDaytype == kDaytypeHolyday) {
//		NSLog(@"CD:Holyday");
		
		NSManagedObject *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
		NSManagedObject *newStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
		
		[newTable setValue:newLine forKey:@"thisLine"];
		[newTable setValue:newStation forKey:@"thisStation"];
		
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"orderNo"];
		[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"tableNo"];
		[newLine setValue:lineValue forKey:@"name"];
		[newStation setValue:stationValue forKey:@"name"];
		[newTable setValue:directionValue forKey:@"direction"];
		
		
		if (daytypeValue == kDaytypeWeekday) {
			[newTable setValue:NSLocalizedString(@"Weekday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			[newTable setValue:NSLocalizedString(@"Saturday",nil) forKey:@"daytype"];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			[newTable setValue:NSLocalizedString(@"Holiday",nil) forKey:@"daytype"];
		}
		else {			
			[newTable setValue:NSLocalizedString(@"Everyday",nil) forKey:@"daytype"];
		}
		
		int sec = [holydayAllDatas count];
		
		int startinghour = 99;
		for (int c_sec = 0; c_sec < sec; c_sec += 1) {
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",c_sec];
			NSArray *section = [holydayAllDatas valueForKey:key_str];
			[key_str release];
			
			int unihour;
			if (startinghour == 99) {
				startinghour = [[[section objectAtIndex:0] valueForKey:@"dep_hour"] intValue];
//				NSLog(@"Starting %02d",startinghour);
				
			}
			
			int row = [section count];
			for (int c_row = 0; c_row < row; c_row +=1) {
				NSManagedObject *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
				NSManagedObject *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:self.managedObjectContext];
				[newTime setValue:newVehicle forKey:@"thisVehicle"];
				[newTime setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newTable forKey:@"Table"];
				[newVehicle setValue:newLine forKey:@"Line"];
				
				NSDictionary *time = [section objectAtIndex:c_row];
				
				int p_hour = [[time valueForKey:@"dep_hour"] intValue];
				if (p_hour < startinghour) {
					unihour = startinghour + c_sec;
//					NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
				}
				else {
					unihour = p_hour;
				}
//				NSLog(@"unihour: %02d",unihour);
				
				[newTable setValue:[NSNumber numberWithInt:startinghour] forKey:@"startinghour"];
				[newTime setValue:[NSNumber numberWithInteger:unihour] forKey:@"dep_unihour"];
				[newTime setValue:[NSNumber numberWithInteger:p_hour] forKey:@"dep_hour"];
				[newTime setValue:[NSNumber numberWithInteger:[[time valueForKey:@"dep_minute"] integerValue]] forKey:@"dep_minute"];
				[newVehicle setValue:[time valueForKey:@"kind"] forKey:@"kind"];
				[newVehicle setValue:[time valueForKey:@"destination"] forKey:@"destination"];
				
				/*				
				 NSLog(@"hour :%@",[newTime valueForKey:@"dep_hour"]);
				 NSLog(@"minute :%@",[newTime valueForKey:@"dep_minute"]);
				 NSLog(@"kind :%@",[newTime valueForKey:@"kind"]);
				 NSLog(@"destination :%@",[newTime valueForKey:@"destination"]);
				 */
			}
			
		}
		
	}
	
	
	
	[managedObjectContext save:&error];
//	[self performSelectorOnMainThread:@selector(saveEnded) withObject:nil waitUntilDone:NO];
	
	[callparent saveDataDone];
	
	[pool release];
}


- (void)dealloc {
	
//	[backlay release];
//	[overlay release];
	[urlValue release];
	
	[urlConnection release];
	
	[toEkitan release];
	
	[deleteKeyword release];
	
	
//	[timesTable release];
	
	/*
	 [working release];
	 [homenValue release];
	 [rosenValue release];
	 
	 [_currentCharacters release];
	 
	 [sectionDatas release];
	 [cellData release];
	 
	 [weekdayAllDatas release];
	 [weekdayKeys release];
	 
	 [saturdayAllDatas release];
	 [saturdayKeys release];
	 
	 [holydayAllDatas release];
	 [holydayKeys release];
	 
	 [ekitanUrl release];
	 
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
