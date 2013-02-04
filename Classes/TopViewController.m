//
//  TopViewController.m
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import "TopViewController.h"
#import "TableSelect.h"

#import "GADBannerView.h"
#import "GADRequest.h"
//#import "GADInterstitial.h"


@implementation TopViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize topTable;
@synthesize dispSide;

@synthesize selectedSide;
@synthesize first_tt_name;
@synthesize second_tt_name;

@synthesize allKeys;

//@synthesize nowTimetext;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (id)init {
	if (self == [super init]) {
	}
	return self;
}

- (void)loadView {
    [super loadView];

}
*/

- (void)viewDidLoad {

    [super viewDidLoad];

	[NSFetchedResultsController deleteCacheWithName:nil];
	fetchedResultsController.delegate = self;
	
//	NSLog(@"ViewDidLoad");

	adDisp = NO;
	self.dispSide.text = self.selectedSide;
	
	diffDisp = NO;
	
    //CGRect frame = self.view.frame;

//    CGRect screen_bounds = [[UIScreen mainScreen] bounds];
//    NSLog(@"screen_bounds %@", NSStringFromCGRect(screen_bounds));
    
    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
//    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));

    topTable.frame = CGRectMake(0, 100, screen_frame.size.width, screen_frame.size.height - 100 -48);


	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tableScroll) userInfo:nil repeats:NO];
	

}

//現在時刻に近いセルへスクロール
- (IBAction)tableScroll {

	BOOL scrolled = NO;
	NSInteger row;
	NSInteger sec;
	NSInteger row_max;
	NSInteger sec_max;
	sec_max = [[fetchedResultsController sections] count];	
	NSDate *currentTime = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *nowTime = [cal components:flags fromDate:currentTime];
	
	for (sec = 0; sec < sec_max; sec++) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:sec];
		row_max = [sectionInfo numberOfObjects];
		for (row = 0; row < row_max; row++) {
			NSIndexPath *scrollindexpath = [NSIndexPath indexPathForRow:(NSUInteger)row inSection:(NSUInteger)sec];
			NSManagedObject *tableCellData = [fetchedResultsController objectAtIndexPath:scrollindexpath];
			NSInteger hour = [[tableCellData valueForKey:@"dep_hour"] integerValue];
			NSInteger unihour = [[tableCellData valueForKey:@"dep_unihour"] integerValue];
			NSInteger minute = [[tableCellData valueForKey:@"dep_minute"] integerValue];
			
			NSDateComponents *cellTime = [[NSDateComponents alloc] init];
			[cellTime setYear:[nowTime year]];
			[cellTime setMonth:[nowTime month]];
			
			if (unihour < 24 & [nowTime hour] >= kDefaultStartingHour & [nowTime hour] < 24) {
				[cellTime setDay:[nowTime day]];
				[cellTime setHour:hour];
			}
			else if (unihour >= 24 & [nowTime hour] >= kDefaultStartingHour & [nowTime hour] < 24) {
				[cellTime setDay:[nowTime day]+1];
				[cellTime setHour:hour];
			}
			else if (unihour < 24 & [nowTime hour] < kDefaultStartingHour) {
				[cellTime setDay:[nowTime day]-1];
				[cellTime setHour:hour];
			}
			else if (unihour >= 24 & [nowTime hour] < kDefaultStartingHour) {
				[cellTime setDay:[nowTime day]];
				[cellTime setHour:hour];
			}
			
			[cellTime setMinute:minute];
			[cellTime setSecond:0];
			
			NSDate *tableCellTime = [cal dateFromComponents:cellTime];
			
			
			switch ([tableCellTime compare:currentTime]) {
				case NSOrderedSame:
					[self.topTable scrollToRowAtIndexPath:scrollindexpath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
					scrolled = YES;
					break;
				case NSOrderedDescending:
					[self.topTable scrollToRowAtIndexPath:scrollindexpath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
					scrolled = YES;
					break;
				default:
					break;
			}
			
			[cellTime release];
			
			if (scrolled == YES) {
				break;
			}
		}
		if (scrolled == YES) {
			break;
		}
	}

}


- (void)updateclock {

	if (diffDisp == NO) {
		diffDisp = YES;
	}
	
	//NSDateで現在時刻を獲得
	NSDate *date = [NSDate date];
	
	//NSDateFormatterで時刻表示の金型をつくる
	NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
	
	//ロケールの設定
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateForm setLocale:locale];
	[locale release];
	
	//金型を調整して時刻表示スタイルを決める
	[dateForm setDateFormat:@"HH:mm .ss"];
	
	//調整した金型を使って時刻を表示用変数へ
	nowClock.text = [dateForm stringFromDate:date];
/*
	self.nowTimetext = [dateForm stringFromDate:date];
	[self.view setNeedsDisplay];
*/
	
	[dateForm setDateFormat:@"HH"];
	nowHour = [[dateForm stringFromDate:date] integerValue];
	[dateForm setDateFormat:@"mm"];
	nowMinute = [[dateForm stringFromDate:date] integerValue];
	[dateForm setDateFormat:@"ss"];
	nowSecond = [[dateForm stringFromDate:date] integerValue];
	
//	NSLog(@"Hour: %d",nowHour);
//	NSLog(@"Minute: %d",nowMinute);
//	NSLog(@"Second: %d",nowSecond);
	
	[dateForm release];
	[topTable reloadData];
}


/*
- (void)drawRect:(CGRect)rect {
	[[UIColor blackColor] set];
	[self.nowTimetext drawInRect:CGRectMake(85, 76, 108, 23) withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
/*
    CGRect screen_bounds = [[UIScreen mainScreen] bounds];
    NSLog(@"screen_bounds %@", NSStringFromCGRect(screen_bounds));

    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));
*/
	if (adDisp == NO) {
		// Request an ad
//		adMobAd = [AdMobView requestAdWithDelegate:self];
//		[adMobAd retain];

#ifdef Log
        NSLog(@"GAD Request - Top");
#endif
        
        CGRect frame = self.navigationController.view.frame;
        
        adMobAd = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, frame.size.height)] autorelease];

        adMobAd.adUnitID = MADIATION_ID;
        adMobAd.delegate = self;
        
//        adMobAd.frame = CGRectMake(0, frame.size.height, frame.size.width, CGSizeFromGADAdSize(kGADAdSizeBanner).height);
//        adMobAd.center = CGPointMake(0, frame.size.height);
        
        [adMobAd setRootViewController:self];
        [self.view addSubview:adMobAd];

        
        [adMobAd loadRequest:[GADRequest request]];
        
//        GADInterstitial *interstitial_ = [[GADInterstitial alloc] init];
//        interstitial_.adUnitID = @"0397dc82032043ee";
//        [interstitial_ loadRequest:[GADRequest request]];


	}

	[allKeys release];
	allKeys = [[NSMutableArray alloc] init];
	for (id section in [fetchedResultsController sections]) {
		[allKeys addObject:[section name]];
//		NSLog(@"Sec %@",[section name]);			
	}
	
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

	
	if ([self.selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
		first_timetable.text = [def valueForKey:@"topFirst_name"];
		second_timetable.text = [def valueForKey:@"topSecond_name"];
	}
	else if([self.selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
		first_timetable.text = [def valueForKey:@"secondFirst_name"];
		second_timetable.text = [def valueForKey:@"secondSecond_name"];
	}
	
	
	UIImage *ttIcon;	
	if ([selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
		if (first_tt_No == 0) {
			ttIcon = [UIImage imageNamed:@"tt_icon00.png"];
			[first_icon setImage:ttIcon];
		}
		else {
			ttIcon = [UIImage imageNamed:@"tt_icon01.png"];
			[first_icon setImage:ttIcon];
		}
		if (second_tt_No == 0) {
			ttIcon = [UIImage imageNamed:@"tt_icon00.png"];
			[second_icon setImage:ttIcon];
		}
		else {
			ttIcon = [UIImage imageNamed:@"tt_icon02.png"];
			[second_icon setImage:ttIcon];
		}
	}
	else if([selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
		if (first_tt_No == 0) {
			ttIcon = [UIImage imageNamed:@"tt_icon00.png"];
			[first_icon setImage:ttIcon];
		}
		else {
			ttIcon = [UIImage imageNamed:@"tt_icon03.png"];
			[first_icon setImage:ttIcon];
		}
		if (second_tt_No == 0) {
			ttIcon = [UIImage imageNamed:@"tt_icon00.png"];
			[second_icon setImage:ttIcon];
		}
		else {
			ttIcon = [UIImage imageNamed:@"tt_icon04.png"];
			[second_icon setImage:ttIcon];
		}
	}

}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*
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


#pragma mark -
#pragma mark Table view methods



//カスタムセルの高さ設定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCustomCellHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//  NSInteger section = [indexPath section];
//	NSInteger row = [indexPath row];
	static NSString *timeCellIdentifier = @"viewtime";
	
	timeCellDisp = (BindedTimetable*)[tableView dequeueReusableCellWithIdentifier:timeCellIdentifier];
    if (timeCellDisp == nil) {
        timeCellDisp = [[[BindedTimetable alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellIdentifier] autorelease];
		timeCellDisp.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	NSManagedObject *tableCellData = [fetchedResultsController objectAtIndexPath:indexPath];
	
	NSInteger which_tt = 0;
	NSInteger tt_no = [[tableCellData valueForKeyPath:@"Table.tableNo"] integerValue];
	
	if ([selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
		if (first_tt_No == tt_no) {
			which_tt = 1;
		}
		else if (second_tt_No == tt_no) {
			which_tt = 2;
		}
	}
	else if([selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
		if (first_tt_No == tt_no) {
			which_tt = 1;
		}
		else if (second_tt_No == tt_no) {
			which_tt = 2;
		}
	}
	
	
	if ([selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
		switch (which_tt) {
			case 1:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color01.png"];
				break;
			case 2:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color02.png"];
				break;
			default:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color00.png"];
				break;
		}
	}
	else if([selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
		switch (which_tt) {
			case 1:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color03.png"];
				break;
			case 2:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color04.png"];
				break;
			default:
				timeCellDisp.ttColorImage = [UIImage imageNamed:@"tt_color00.png"];
				break;
		}		
	}
	
	
	
	//時刻差分処理

	NSInteger hour = [[tableCellData valueForKey:@"dep_hour"] integerValue];
	NSInteger unihour = [[tableCellData valueForKey:@"dep_unihour"] integerValue];
	NSInteger minute = [[tableCellData valueForKey:@"dep_minute"] integerValue];
	NSString *time = [[NSString alloc] initWithFormat:@"%2d:%02d",hour,minute];

	NSDate *currentTime = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *nowTime = [cal components:flags fromDate:currentTime];
	
	NSDateComponents *cellTime = [[NSDateComponents alloc] init];
	[cellTime setYear:[nowTime year]];
	[cellTime setMonth:[nowTime month]];
	
	if (unihour < 24 & [nowTime hour] >= kDefaultStartingHour & [nowTime hour] < 24) {
		[cellTime setDay:[nowTime day]];
		[cellTime setHour:hour];
	}
	else if (unihour >= 24 & [nowTime hour] >= kDefaultStartingHour & [nowTime hour] < 24) {
		[cellTime setDay:[nowTime day]+1];
		[cellTime setHour:hour];
	}
	else if (unihour < 24 & [nowTime hour] < kDefaultStartingHour) {
		[cellTime setDay:[nowTime day]-1];
		[cellTime setHour:hour];
	}
	else if (unihour >= 24 & [nowTime hour] < kDefaultStartingHour) {
		[cellTime setDay:[nowTime day]];
		[cellTime setHour:hour];
	}

	[cellTime setMinute:minute];
	[cellTime setSecond:0];
	
	NSDate *tableCellTime = [cal dateFromComponents:cellTime];
	
	NSDateComponents *diff = [cal components:flags fromDate:currentTime toDate:tableCellTime options:0];	
	
//	NSLog(@"day: %d",[diff day]);
//	NSLog(@"hour: %d",[diff hour]);
//	NSLog(@"minute: %d",[diff minute]);
//	NSLog(@"second: %d",[diff second]);
	
	
	NSInteger diffHour;
	NSInteger diffMinute;
	NSInteger diffSecond;
	
	NSString *diffTime;
	diffHour = [diff hour];
	diffMinute = [diff minute];
	diffSecond = [diff second];
	

	if (diffHour == 0 & diffMinute >= 0) {
		diffTime = [[NSString alloc] initWithFormat:@":%02d.",diffMinute];
	}
	else if (diffHour == 0 & diffMinute < 0) {
		diffTime = [[NSString alloc] initWithFormat:@":%02d.",(0-diffMinute)];
	}
	else if (diffHour < 0 & diffMinute < 0) {
		diffTime = [[NSString alloc] initWithFormat:@"%2d:%02d.",(0-diffHour),(0-diffMinute)];
	}
	else if (diffHour < 0 & diffMinute >= 0) {
		diffTime = [[NSString alloc] initWithFormat:@"%2d:%02d.",(0-diffHour),diffMinute];		
	}
	else {
		diffTime = [[NSString alloc] initWithFormat:@"%2d:%02d.",diffHour,diffMinute];		
	}
	

//	NSLog(@"Cell");
	
	
	
	NSString *kind = [tableCellData valueForKeyPath:@"thisVehicle.kind"];
	if ([kind isEqualToString:NSLocalizedString(@"普通",nil)] | [kind isEqualToString:NSLocalizedString(@"各駅停車",nil)] | [kind isEqualToString:@""]) {
		timeCellDisp.R = 0.7f;
		timeCellDisp.G = 0.7f;
		timeCellDisp.B = 0.7f;
		timeCellDisp.A = 1.0f;
	}
	else {
		timeCellDisp.R = 0.5f;
		timeCellDisp.G = 0.6f;
		timeCellDisp.B = 0.7f;
		timeCellDisp.A = 1.0f;
	}
		
	timeCellDisp.timeLabel = time;
	timeCellDisp.kindLabel = kind;
	timeCellDisp.destinationLabel = [tableCellData valueForKeyPath:@"thisVehicle.destination"];
	
	if (((diffHour*60)+diffMinute+diffSecond) <= 0)  {
		
		timeCellDisp.diffMinus = YES;

		if (diffDisp == NO) {
			timeCellDisp.diffHidden = YES;
		}
		else {
			timeCellDisp.diffHidden = NO;
		}
		
		timeCellDisp.diffLabel = diffTime;
		
		timeCellDisp.secondGraph = [UIImage imageNamed:@"s00.png"];

	}
	else {
		
		timeCellDisp.diffMinus = NO;

		if (diffDisp == NO) {
			timeCellDisp.diffHidden = YES;
		}
		else {
			timeCellDisp.diffHidden = NO;
		}

		timeCellDisp.diffLabel = diffTime;
				

		if (diffDisp == NO) {
			timeCellDisp.secondHidden = YES;
		}
		else {
			timeCellDisp.secondHidden = NO;			
		}
		
		
		if (diffSecond < 60 & 55 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s60.png"];
		}
		else if (diffSecond < 55 & 50 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s55.png"];
		}
		else if (diffSecond < 50 & 45 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s50.png"];
		}
		else if (diffSecond < 45 & 40 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s45.png"];
		}
		else if (diffSecond < 40 & 35 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s40.png"];
		}
		else if (diffSecond < 35 & 30 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s35.png"];
		}
		else if (diffSecond < 30 & 25 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s30.png"];
		}
		else if (diffSecond < 25 & 20 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s25.png"];
		}
		else if (diffSecond < 20 & 15 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s20.png"];
		}
		else if (diffSecond < 15 & 10 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s15.png"];
		}
		else if (diffSecond < 10 & 5 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s10.png"];
		}
		else if (diffSecond < 5 & 0 <= diffSecond) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s05.png"];
		}
		else if (diffSecond == 0) {
			timeCellDisp.secondGraph = [UIImage imageNamed:@"s00.png"];
		}

	}
	
	[cellTime release];
	[diffTime release];
	[time release];
	
	[timeCellDisp setNeedsDisplay];
	
    return timeCellDisp;    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	id sectioninfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [NSString stringWithFormat:NSLocalizedString(@" %@ o'clock",nil),[sectioninfo name]];

}			


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

	return allKeys;
//	return [fetchedResultsController sectionIndexTitles];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
 	[self.topTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}
*/


- (IBAction)first_tt_select {

	TableSelect *myTT = [[TableSelect alloc] init];
	myTT.parent = self;
	myTT.managedObjectContext = self.managedObjectContext;
	myTT.dochi = 1;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myTT];	
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:myTT action:@selector(cancel:)];
	navController.navigationBar.topItem.leftBarButtonItem = backButton;
	[backButton release];

	navController.navigationBar.topItem.title = NSLocalizedString(@"Select Timetable 1",nil);

//	NSLog(@"FirstSelect!!!");
	
	[self presentModalViewController:navController animated:YES];
	
	[navController release];
	[myTT release];
	
}

- (IBAction)second_tt_select {
	
	TableSelect *myTT = [[TableSelect alloc] init];
	myTT.parent = self;
	myTT.managedObjectContext = self.managedObjectContext;
	myTT.dochi = 2;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myTT];	
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:myTT action:@selector(cancel:)];
	navController.navigationBar.topItem.leftBarButtonItem = backButton;
	[backButton release];
	
	navController.navigationBar.topItem.title = NSLocalizedString(@"Select Timetable 2",nil);

//	NSLog(@"SecondSelect!!!");
	
	[self presentModalViewController:navController animated:YES];
	
	[navController release];
	[myTT release];
	
}


- (void)tableSetting:(NSInteger)dochi asNo:(NSInteger)no ofName:(NSString *)name {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if ([selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
		switch (dochi) {
			case 1:
				self.first_tt_name = name;
				first_tt_No = no;
				first_timetable.text = first_tt_name;
				[defaults setValue:[NSNumber numberWithInteger:no] forKey:@"topFirst"];
				[defaults setValue:name forKey:@"topFirst_name"];
//				NSLog(@"A_First-Set!!! : %d",[[defaults valueForKey:@"topFirst"] integerValue]);				
				break;
			case 2:
				self.second_tt_name = name;
				second_tt_No = no;
				second_timetable.text = second_tt_name;
				[defaults setValue:[NSNumber numberWithInteger:no] forKey:@"topSecond"];
				[defaults setValue:name forKey:@"topSecond_name"];
//				NSLog(@"A_Second-Set!!! : %d",[[defaults valueForKey:@"topSecond"] integerValue]);
				break;
			default:
				break;
		}
	}
	else if([selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
		switch (dochi) {
			case 1:
				self.first_tt_name = name;
				first_tt_No = no;
				first_timetable.text = first_tt_name;
				[defaults setValue:[NSNumber numberWithInteger:no] forKey:@"secondFirst"];
				[defaults setValue:name forKey:@"secondFirst_name"];
//				NSLog(@"B_First-Set!!! : %d",[[defaults valueForKey:@"secondFirst"] integerValue]);
				
				break;
			case 2:
				self.second_tt_name = name;
				second_tt_No = no;
				second_timetable.text = second_tt_name;
				[defaults setValue:[NSNumber numberWithInteger:no] forKey:@"secondSecond"];
				[defaults setValue:name forKey:@"secondSecond_name"];
//				NSLog(@"B_Second-Set!!! : %d",[[defaults valueForKey:@"secondSecond"] integerValue]);
				break;
			default:
				break;
		}		
	}

	fetchedResultsController = nil;
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	

	[self.topTable reloadData];
	
}




#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Time" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];

	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	if ([selectedSide isEqualToString:NSLocalizedString(@"A",nil)]) {
//		NSLog(@"def1: %d",[[def valueForKey:@"topFirst"]integerValue]);
//		NSLog(@"def2: %d",[[def valueForKey:@"topSecond"]integerValue]);
		first_tt_No = [[def valueForKey:@"topFirst"] integerValue];
		second_tt_No =  [[def valueForKey:@"topSecond"] integerValue];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Table.tableNo == %d) OR (Table.tableNo == %d)",[[def valueForKey:@"topFirst"] integerValue], [[def valueForKey:@"topSecond"] integerValue]];
		[fetchRequest setPredicate:predicate];	
	}
	else if ([selectedSide isEqualToString:NSLocalizedString(@"B",nil)]) {
//		NSLog(@"def3: %d",[[def valueForKey:@"secondFirst"]integerValue]);
//		NSLog(@"def4: %d",[[def valueForKey:@"secondSecond"]integerValue]);
		first_tt_No = [[def valueForKey:@"secondFirst"] integerValue];
		second_tt_No =  [[def valueForKey:@"secondSecond"] integerValue];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Table.tableNo == %d) OR (Table.tableNo == %d)",[[def valueForKey:@"secondFirst"] integerValue], [[def valueForKey:@"secondSecond"] integerValue]];
		[fetchRequest setPredicate:predicate];	
	}

	// Edithe sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dep_unihour" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dep_minute" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
//	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"dep_hour" cacheName:@"Root"];
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"dep_unihour" cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;

	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor1 release];
	[sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.topTable reloadData];
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
	[topTable release]; topTable = nil;
	[fetchedResultsController release]; fetchedResultsController = nil;
	[managedObjectContext release]; managedObjectContext = nil;
    [super dealloc];
}




#pragma mark -
#pragma mark Admob methods


// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
//- (void)didReceiveAd:(AdMobView *)adView {
- (void)adViewDidReceiveAd:(GADBannerView *)adView {

#ifdef Log
    NSLog(@"AdMob: Did receive ad");
#endif

	[UIView setAnimationsEnabled:YES];
	

	// get the view frame
	CGRect frame = self.view.frame;
    
//    CGRect screen_bounds = [[UIScreen mainScreen] bounds];
//    NSLog(@"screen_bounds %@", NSStringFromCGRect(screen_bounds));
    
//    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
//    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));

    /*
    NSLog(@"ImageView.Frame %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"ImageView.Bounds %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"frame.Frame %@", NSStringFromCGRect(frame));
    NSLog(@"topTable -> %f,%f,%f,%f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    */
	
	// put the ad at the bottom of the screen
	adMobAd.center = CGPointMake(frame.size.width/2, frame.size.height + (CGSizeFromGADAdSize(kGADAdSizeBanner).height /2));
//	adMobAd.frame = CGRectMake(0, frame.size.height, frame.size.width, 48);
//	[self.view addSubview:adMobAd];

	[UIView beginAnimations:@"AdView" context:nil];
	[UIView setAnimationDuration:0.4f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
    adMobAd.frame = CGRectMake(0, frame.size.height - CGSizeFromGADAdSize(kGADAdSizeBanner).height, frame.size.width, CGSizeFromGADAdSize(kGADAdSizeBanner).height);
    if (adDisp == NO) {
        self.topTable.frame = CGRectMake(0, 100,  frame.size.width, self.topTable.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeBanner).height);
    }
//	self.topTable.frame = CGRectMake(0, 100, 320, 363);


	[UIView commitAnimations];
	
	adDisp = YES;
	
    /*
	[refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self selector:@selector(refreshAd:) userInfo:nil repeats:YES];
    */

}

// Sent when an ad request failed to load an ad
//- (void)didFailToReceiveAd:(AdMobView *)adView {
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {

#ifdef Log
    NSLog(@"AdMob: Did fail to receive ad");
#endif
    
//	[adMobAd release];
	adMobAd = nil;
	adDisp = NO;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
}



@end


/*

if ([selectedSide isEqualToString:@"A"]) {
	switch (dochi) {
		case 1:
			break;
		case 2:
			break;
		default:
			break;
	}
}
else if([selectedSide isEqualToString:@"B"]) {
	switch (dochi) {
		case 1:
			break;
		case 2:
			break;
		default:
			break;
	}		
}

*/
