//
//  TimeInputView.m
//  TT
//
//  Created by Kotatsu RIN on 09/11/03.
//  Copyright 2009 con3office. All rights reserved.
//

#import "TimeInputViewController.h"
#import "TimeInputView.h"


@implementation TimeInputViewController

@synthesize fetchedResultsController; 
@synthesize managedObjectContext;
@synthesize selectedTimeTable;

@synthesize pages;
@synthesize late_pages;

@synthesize funns_mem;
@synthesize funns_mem_original;

@synthesize hourtimes;
@synthesize hourtimes_original;

@synthesize tmp_hourtimes;

@synthesize startHour;
@synthesize sTag;

@synthesize min_editing;

@synthesize navController;


- (id)init {
	resetTimeButton();
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	[super viewDidAppear:animated];
	
//	modified = NO;
//	min_editing = NO;

	[self retrieveMinute];

//ここでスクロールビュー呼び出し	
	if (sTag >= startHour) {
//		inputScrollView.startPage = sTag-startHour;
		inputScrollView.currentPage = sTag-startHour;
	}
	else if (sTag < startHour & sTag >= 0) {
//		inputScrollView.startPage = (sTag-startHour)+24;		
		inputScrollView.currentPage = (sTag-startHour)+24;		
	}
	else {
//		inputScrollView.startPage = 0;		
		inputScrollView.currentPage = 0;		
	}


	//TimeInput内の分数ボタンのところへ描画フラグを立てる
	for (UIView *p in inputScrollView.pages) {
		[[p viewWithTag:99] setNeedsDisplay];
	}

	self.view = inputScrollView;
}


- (void) loadView {
	[super loadView];
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.delegate = self;
	
}	



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
    [super viewDidLoad];
	
	navController.navigationBar.topItem.rightBarButtonItem = [self editButtonItem];
	
	funns_mem = [[[NSMutableDictionary alloc] init] retain];
	funns_mem_original = [[[NSMutableDictionary alloc] init] retain];
	pages = [[[NSMutableArray alloc] init] retain];
	ButtonImages *bi = [ButtonImages instance];
	
	for (int i = 0; i < 24; i++) {
//		NSLog(@"settting: %d",i);

		UIView *page = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		
		TimeInputView *input = [[TimeInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		input.backgroundColor = [UIColor whiteColor];
		input.parent = self;
		input.thisHour = i;
		input.tag = 99;
		[page addSubview:input];

//		NSLog(@"input done");
		
		CGRect jRect = CGRectMake(20, 12, 42, 36);
		UILabel *jikan = [[UILabel alloc] initWithFrame:jRect];
		[jikan setFont:[UIFont boldSystemFontOfSize:36]];
		jikan.textAlignment = UITextAlignmentRight;
		[jikan setText:[NSString stringWithFormat:@"%02d",i]];
		jikan.textColor = [UIColor blackColor];
		jikan.backgroundColor = [UIColor clearColor];
		[page addSubview:jikan];
		[jikan release];
		
		
		if (!(i == startHour)) {		
			CGRect lRect = CGRectMake(4, 190, 10, 24);
			UIImageView *arr_l = [[UIImageView alloc] initWithFrame:lRect];
			[arr_l setImage:bi.arrow_left];
			[page addSubview:arr_l];
			[arr_l release];
		}
		if (!(i == startHour - 1)) {			
			CGRect rRect = CGRectMake(304, 190, 10, 24);
			UIImageView *arr_r = [[UIImageView alloc] initWithFrame:rRect];
			[arr_r setImage:bi.arrow_right];
			[page addSubview:arr_r];
			[arr_r release];
		}
		
//		NSLog(@"jikan done");

		CGRect fRect = CGRectMake(70, 0, 230, 90);
		UITextView *funn = [[UITextView alloc] initWithFrame:fRect];
		[funn setFont:[UIFont systemFontOfSize:17]];
		[funn setTextColor:[UIColor blackColor]];
		funn.editable = NO;
		funn.scrollEnabled = NO;
		[funn setTag:i+9900];
		[funn setText:@""];
		funn.userInteractionEnabled = NO;
		[page addSubview:funn];
		[funn release];
		
//		NSLog(@"funn done");

		UIButton *copypush = [UIButton buttonWithType:UIButtonTypeCustom];
//		[copypush setTitle:@"copy" forState:UIControlStateNormal];
		[copypush setTag:i+8800];
		[copypush addTarget:self action:@selector(copyMinutes:) forControlEvents:UIControlEventTouchUpInside];
		copypush.frame = CGRectMake(24, 52, 36, 36);
		[copypush setBackgroundImage:bi.copy_icon_h forState:UIControlStateNormal];
		[page addSubview:copypush];
		
//		NSLog(@"copybutton done");
		
		[pages addObject:page];

//		NSLog(@"page set:%d",i);

//		NSLog(@"add done");
		
		[page release];
		[input release];		
	}
	
	[self changeStartHour:startHour];
	
	inputScrollView = [[PageScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	inputScrollView.pages = pages;
	inputScrollView.delegate = nil;

	/*
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	*/

}

- (void)changeStartHour:(int)sh {
//	NSLog(@"入れ替え");
	
	late_pages = [[NSMutableArray alloc] init];
	
	[late_pages addObjectsFromArray:[pages subarrayWithRange:NSMakeRange(0, sh)]];
	[pages addObjectsFromArray:late_pages];
	[late_pages release];
	
	[pages removeObjectsInRange:NSMakeRange(0, sh)];
	
}


//ボタン状態のリセット
void resetTimeButton() {
//	NSLog(@"reset");
	
	for (int h = 0; h < 24; ++h) {
		for (int m = 0; m < 60; ++m) {
			timeButtonSelected[h][m] = 0;
		}
	}	
}

//時刻表示部分のリセット
- (void)resetTimeDisp {
	[funns_mem removeAllObjects];
	//	funns_mem = [[[NSMutableDictionary alloc] init] retain];
	
	for (int h = 0; h < 24; ++h) {
		int aTag = h+9900;
		UITextView *min_disp = (UITextView *)[self.view viewWithTag:aTag];
		[min_disp setText:@""];
	}	
}


//TimeInput内の分数ボタンのところへ描画フラグを立てる
- (void)drawButtons {
	for (UIView *p in self.pages) {
		[[p viewWithTag:99] setNeedsDisplay];		
	}
}


- (void)cancel:(id)sender {
//	NSLog(@"cancel!");
	resetTimeButton();
	[self resetTimeDisp];
	
	modified = NO;
	self.editing = NO;
	UINavigationController *this_navCon = navController;
	[this_navCon dismissModalViewControllerAnimated:YES];
	
}


void revTimeButton(int min, int hour) {
//	NSLog(@"set");
	timeButtonSelected[hour][min] = !(timeButtonSelected[hour][min]);
}

void setTimeButton(int min, int hour, int flag) {
//	NSLog(@"set");
	timeButtonSelected[hour][min] = flag;
}

int getTimeButton(int min, int hour) {
	return timeButtonSelected[hour][min];
	
}

- (int)currentEditing {
	return self.editing;
}


/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSInteger tapCount = [[touches anyObject] tapCount];
	tapPoint = [[touches anyObject] locationInView:self.view];
//	NSLog(@"another Tap! x:%f y:%f",tapPoint.x,tapPoint.y);
	
}
*/

- (void)tappedButton:(id)target minute:(int)m hour:(int)h minutestr:(NSString*)minute hourstr:(NSString*)hour {
	
	if (!self.editing) {
//		NSLog(@"return!!");
		return;
	}
//	NSLog(@"input!!");
	
	
	int pushSelected = getTimeButton(m, h);
	
	if (pushSelected == 0) {
//		NSLog(@"pushSelect == NO");
		//Arrayへの時刻記録
		if ([[self.funns_mem allKeys] containsObject:hour]) {
			hourtimes = [funns_mem valueForKey:hour];
		}
		else{
			hourtimes = [[NSMutableArray alloc] init];
		}
		[hourtimes addObject:(NSString *)minute];
		[hourtimes sortUsingSelector:@selector(compare:)];
		[funns_mem setObject:hourtimes forKey:hour];
		
		//Arrayから時刻表示へ
		NSMutableString *fun_str = [[NSMutableString alloc] init];
		for (NSString *min in hourtimes) {
			[fun_str appendFormat:@"%@ ",min];
		}
		int aTag = h+9900;
		UITextView *min_disp = (UITextView *)[self.view viewWithTag:aTag];
		[min_disp setText:fun_str];
		
//		NSLog(@"fun: %@",fun_str);
		
		
		[min_disp setNeedsDisplay];
		[fun_str release];
		hourtimes = nil;
		
		setTimeButton(m, h, 1);
//		revTimeButton(m, h);
	}
	else {
//		NSLog(@"pushSelect == YES");
		
		//tmp_hourtimeとして複製を作成
		tmp_hourtimes = [[NSMutableArray alloc] init];
		if ([[funns_mem allKeys] containsObject:hour]) {
			hourtimes = [funns_mem valueForKey:hour];
			[tmp_hourtimes setArray:hourtimes];
			/*
			 for (NSString *min in hourtimes) {
			 [tmp_hourtimes addObject:(NSString *)min];
			 }
			 */
		}
		else{
			setTimeButton(m, h, 0);
//			push.selected = NO;
			return;
		}
		
		
		//削除時刻の検索と削除
		NSInteger count = [tmp_hourtimes count];
		NSInteger i;
		for (i = 0; i <= count-1; i ++) {
			if ([[tmp_hourtimes objectAtIndex:i] isEqualToString:minute]) {
				[tmp_hourtimes removeObjectAtIndex:i];
				break;
			}
		}
		/*
		 if (count == 1) {
		 [tmp_hourtimes removeAllObjects];
		 }
		 */
		[funns_mem setObject:tmp_hourtimes forKey:hour];
		
		//時刻表示
		NSMutableString *fun_str = [[NSMutableString alloc] init];
		for (NSString *min in tmp_hourtimes) {
			[fun_str appendFormat:@"%@ ",min];
		}
		int aTag = h+9900;
		UITextView *min_disp = (UITextView *)[self.view viewWithTag:aTag];
		[min_disp setText:fun_str];
		
		
//		NSLog(@"fun: %@",fun_str);
		
		
		[min_disp setNeedsDisplay];
		[fun_str release];
		tmp_hourtimes = nil;
		hourtimes = nil;
		
		setTimeButton(m, h, 0);
//		revTimeButton(m, h);
	}
	
	return;
}



- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    
    [super setEditing:flag animated:animated];

	UINavigationController *this_navCon = navController;

	UIButton *copy_button;
	ButtonImages *bi = [ButtonImages instance];
	
	if (flag == YES) {
//		min_editing = YES;
		modified = YES;
//		NSLog(@"editing YES!");
		
		this_navCon.navigationBar.topItem.leftBarButtonItem.title = NSLocalizedString(@"Cancel",nil);

		for (int h = 0; h <24 ; h++) {
			int aTag = h + 8800;
			copy_button = (UIButton*)[inputScrollView viewWithTag:aTag];
			[copy_button setBackgroundImage:bi.copy_icon forState:UIControlStateNormal];
		}

		/*
		for (UIView *p in inputScrollView.pages) {
			copy_button = (UIButton*)[p viewWithTag:88];
			[copy_button setBackgroundImage:bi.copy_icon forState:UIControlStateNormal];
		}
		*/
		
	}
	else {
//		min_editing = NO;
		
		this_navCon.navigationBar.topItem.leftBarButtonItem.title = NSLocalizedString(@"Back",nil);

		for (int h = 0; h <24 ; h++) {
			int aTag = h + 8800;
			copy_button = (UIButton*)[inputScrollView viewWithTag:aTag];
			[copy_button setBackgroundImage:bi.copy_icon_h forState:UIControlStateNormal];
		}
		
		/*
		for (UIView *p in inputScrollView.pages) {
			copy_button = (UIButton*)[p viewWithTag:88];
			[copy_button setBackgroundImage:bi.copy_icon_h forState:UIControlStateNormal];
		}
		*/
		
		if (modified == NO) {
	//			NSLog(@"Done&Save: return");		
			return;
		}
		
		//		NSLog(@"Done&Save");		
		
		
		NSString *hour_str;		
		NSError *error;
		NSArray *delTimes;
		NSManagedObject *delTime;
		
		for (int i = 0; i < 24; i++ ) {
			//			NSLog(@"Write 1");		
			hour_str = [NSString stringWithFormat:@"%02d",i];
			if ([[self.funns_mem allKeys] containsObject:hour_str]) {
				hourtimes = [funns_mem valueForKey:hour_str];
				hourtimes_original = [funns_mem_original valueForKey:hour_str];
				
				
				NSMutableString *fun_str = [[NSMutableString alloc] init];
				for (NSString *min in hourtimes) {
					[fun_str appendFormat:@"%@ ",min];
				}
				//				 NSLog(@"fun:%d: %@",i,fun_str);
				[fun_str release];
				
				fun_str = [[NSMutableString alloc] init];
				for (NSString *min in hourtimes_original) {
					[fun_str appendFormat:@"%@ ",min];
				}
				//				 NSLog(@"fun_org:%d: %@",i,fun_str);
				[fun_str release];
				
				
				//			NSLog(@"Write 2");		
				for (NSString *min in hourtimes) {
					//					NSLog(@"Write 3");	
					if (![hourtimes_original containsObject:min]) {
						//						NSLog(@"Done&Save: write");
						//編集結果にあってオリジナルにないものは書き込み
						NSManagedObject *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
						NSManagedObject *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:self.managedObjectContext];
						[newTime setValue:newVehicle forKey:@"thisVehicle"];
						[newTime setValue:selectedTimeTable forKey:@"Table"];
						[newVehicle setValue:selectedTimeTable forKey:@"Table"];						
						
						if ([hour_str integerValue] < 4) {
							[newTime setValue:[NSNumber numberWithInteger:[hour_str integerValue]+24] forKey:@"dep_unihour"];
							//							NSLog(@"Unihour:%@",[NSNumber numberWithInteger:[hour_str integerValue]+24]);
						}
						else {
							[newTime setValue:[NSNumber numberWithInteger:[hour_str integerValue]] forKey:@"dep_unihour"];							
							//							NSLog(@"unihour: %@",[NSNumber numberWithInteger:[hour_str integerValue]]);
						}
						[newTime setValue:[NSNumber numberWithInteger:[hour_str integerValue]] forKey:@"dep_hour"];
						[newTime setValue:[NSNumber numberWithInteger:[min integerValue]] forKey:@"dep_minute"];
						[newVehicle setValue:NSLocalizedString(@"",@"vehicle_kind") forKey:@"kind"];
						[newVehicle setValue:NSLocalizedString(@"",@"vehicle_destination") forKey:@"destination"];
					}
				}
				
			}
		}
		hourtimes = nil;
		hourtimes_original = nil;
		
		
		for (int h = 0; h < 24; h++ ) {
			//			NSLog(@"Delete 1");	
			hour_str = [NSString stringWithFormat:@"%02d",h];
//			NSLog(@"hour_str: %@",hour_str);
			if ([[self.funns_mem_original allKeys] containsObject:hour_str]) {
				hourtimes = [funns_mem valueForKey:hour_str];
				hourtimes_original = [funns_mem_original valueForKey:hour_str];
				
				
				//			NSLog(@"Delete 2");
				
				for (NSString *min_org in hourtimes_original) {
					//					NSLog(@"Delete 3");	
					
					if (![hourtimes containsObject:min_org]) {					
//						NSLog(@"Done&Save: delete");
						//オリジナルに存在して，編集結果にないものは削除
						
						NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
						NSEntityDescription *entity = [NSEntityDescription entityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
						[fetchRequest setEntity:entity];
												
						NSInteger min_int = [min_org integerValue];
						NSInteger hour_int = [hour_str integerValue];
						
						if (hour_int < 4) {
							hour_int = hour_int+24;		
						}
						
//						NSLog(@"h: %d m: %d",hour_int,min_int);
						
						NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Table == %@) AND (dep_unihour == %d) AND (dep_minute == %d)",selectedTimeTable,hour_int, min_int];
						[fetchRequest setPredicate:predicate];	
						
						NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dep_unihour" ascending:YES];
						NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dep_minute" ascending:YES];
						NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
						
						[fetchRequest setSortDescriptors:sortDescriptors];
												
						
						error = nil;
						delTimes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
						if ([delTimes count]) {
//							NSLog(@"delete Time!");
							delTime = [delTimes objectAtIndex:0];
							[self.managedObjectContext deleteObject:delTime];
						}
						delTime = nil;
						delTimes = nil;
						[fetchRequest release];
						[sortDescriptor1 release];
						[sortDescriptor2 release];
						[sortDescriptors release];					
						
						
					}
				}
			}
		}
				
		error = nil;
		[self.managedObjectContext save:&error];
		
		
		hour_str = nil;
		[funns_mem_original removeAllObjects];
		for (int i = 0; i < 24; i++ ) {
			hour_str = [NSString stringWithFormat:@"%02d",i];
			NSArray *aHourtimes = [funns_mem objectForKey:hour_str];
			//			NSLog(@"%d:%@",i,aHourtimes);
			NSArray *tmp_array = [[NSArray alloc] initWithArray:aHourtimes copyItems:TRUE];
			//			NSLog(@"%@",tmp_array);
			[funns_mem_original setObject:tmp_array forKey:hour_str];
			aHourtimes = nil;
			[tmp_array release];
		}
		
	}

}


//入力されている時刻表から時刻を取得し，ボタン選択に反映させる
- (void)retrieveMinute {
	
//	NSLog(@"retrieve");
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

#ifdef Log
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		abort();
	}
	
	
	NSArray *time_datas = [fetchedResultsController fetchedObjects];
	int data_count = [time_datas count];
	
	if (!data_count) {
		//		NSLog(@"time_count");
		return;
	}
	
	resetTimeButton();
	
	//	NSLog(@"retrieveMinute");
	
//	NSInteger time;
	NSInteger hour;
	NSInteger minute;
	
	for (NSManagedObject *time_data in time_datas) {
		hour = [[time_data valueForKey:@"dep_hour"] integerValue];
		minute = [[time_data valueForKey:@"dep_minute"] integerValue];
		int h = (int)hour;
		int m = (int)minute;
//		int time = (hour*100)+minute;
//		NSLog(@"time_tag: %d",time);
		
		setTimeButton(m, h, 1);
		
		/*
		 for (UIView *page in pages) {
		 UIButton *push = (UIButton *)[page viewWithTag:time];
		 if(push != nil){
		 [push setSelected:YES];
		 }
		 }
		 */
		
		if ([[self.funns_mem allKeys] containsObject:[NSString stringWithFormat:@"%02d",hour]]) {
			hourtimes = [funns_mem valueForKey:[NSString stringWithFormat:@"%02d",hour]];
		}
		else{
			hourtimes = [[NSMutableArray alloc] init];
		}
		
		if (![hourtimes containsObject:[NSString stringWithFormat:@"%02d",minute]]) {
			[hourtimes addObject:[NSString stringWithFormat:@"%02d",minute]];			
			[hourtimes sortUsingSelector:@selector(compare:)];
			[funns_mem setObject:hourtimes forKey:[NSString stringWithFormat:@"%02d",hour]];
			NSArray *tmp_array = [[NSArray alloc] initWithArray:hourtimes copyItems:TRUE];
			[funns_mem_original setObject:tmp_array forKey:[NSString stringWithFormat:@"%02d",hour]];
			[tmp_array release];
		}
		
		//Arrayから時刻表示へ
		NSMutableString *fun_str = [[NSMutableString alloc] init];
		for (NSString *min in hourtimes) {
			[fun_str appendFormat:@"%@ ",min];
		}
		int aTag = hour+9900;
		for (UIView *page in pages) {
			UITextView *min_disp = (UITextView *)[page viewWithTag:aTag];
			[min_disp setText:fun_str];
			[min_disp setNeedsDisplay];
		}
		
		//		NSLog(@"tag: %d",aTag);
		//		NSLog(@"fun: %@",fun_str);
		
		[fun_str release];
		hourtimes = nil;
		
	}
	
	
}


- (void)copyMinutes:(id)sender {
	
	if (!self.editing) {
		return;
	}
		
	int hour_to = [sender tag] - 8800;
	int hour_from;

	
	if (hour_to == startHour) {
		return;
	}
	else if (hour_to == 0) {
		hour_from = 23;
	}
	else {
		hour_from = hour_to - 1;
	}

#ifdef Log
	NSLog(@"copy button on this hour: %d ; copy from: %d",hour_to, hour_from);
#endif
    
	for (int m = 0; m < 60; m++) {
		if (timeButtonSelected[hour_from][m] == 1 & timeButtonSelected[hour_to][m] == 0) {

#ifdef Log
			NSLog(@"vTapped! : %d",m);
#endif

            [self tappedButton:self minute:m hour:hour_to minutestr:[NSString stringWithFormat:@"%02d",m] hourstr:[NSString stringWithFormat:@"%02d",hour_to]];
		}
	}


	for (UIView *p in inputScrollView.pages) {
		[[p viewWithTag:99] setNeedsDisplay];
	}

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



#pragma mark -
#pragma mark Fetched results controller



- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Table.tableNo == %@)",[selectedTimeTable valueForKey:@"tableNo"]];
	[fetchRequest setPredicate:predicate];	
	
	// Edithe sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dep_hour" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dep_minute" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor1 release];
	[sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;

}    


/*
// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/

- (void)dealloc {
	[funns_mem_original release];
	[funns_mem release];
	[tmp_hourtimes release];
	[hourtimes release];

    [super dealloc];
}


@end
