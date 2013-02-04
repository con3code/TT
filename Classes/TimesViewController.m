//
//  TimesViewController.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/06.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import "TimesViewController.h"

#import "GADBannerView.h"
#import "GADRequest.h"


@implementation TimesViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize callparent;

@synthesize timesTable;

@synthesize selectedTimeTable;

@synthesize allTime;
@synthesize allKeys;


- (id) init {
	
	if (self == [super init]) {
	}
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void) loadView {
	[super loadView];
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.delegate = self;
	
	self.timesTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	self.timesTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.timesTable.delegate = self;
	self.timesTable.dataSource = self;
	
	self.view = self.timesTable;
	
	[self.timesTable reloadData];
}	

- (void)viewDidLoad {
    [super viewDidLoad];
	   
	stationValue = [selectedTimeTable valueForKeyPath:@"thisStation.name"];
	lineValue = [selectedTimeTable valueForKeyPath:@"thisLine.name"];
	directionValue = [selectedTimeTable valueForKey:@"direction"];
	daytypeValue = (int)[selectedTimeTable valueForKey:@"daytype"];

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	

	//時刻列からセクション名称を取得
	allKeys = [[NSMutableArray alloc] init];
	for (id section in [fetchedResultsController sections]) {
		[allKeys addObject:[section name]];
//		NSLog(@"Sec %@",[section name]);
	}

/*
	NSArray* fetchedObj = [fetchedResultsController fetchedObjects];
	int prevName, fetchedName;
	for (NSManagedObject *ti in fetchedObj) {
		fetchedName = [[ti valueForKey:@"dep_hour"] integerValue];
		if (prevName != fetchedName) {
			NSString *sectionName = [[NSString alloc] initWithFormat:@"%d",[[ti valueForKey:@"dep_hour"] integerValue]];
			[allKeys addObject:sectionName];
			prevName = fetchedName;
		}		
//		NSLog(@"Dep: %d",[[ti valueForKey:@"dep_hour"] integerValue]);
//		NSLog(@"Uni: %d",[[ti valueForKey:@"dep_unihour"] integerValue]);
	}
	for (NSString *sm in allKeys) {
		NSLog(@"SecNm: %@",sm);
	}
	
	
	
	NSArray* fetchedTitles = [fetchedResultsController sectionIndexTitles];
	for (NSString *secname in fetchedTitles) {
		NSLog(@"SecTitles: %@",secname);
	}
*/

	
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
					[self.timesTable scrollToRowAtIndexPath:scrollindexpath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
					scrolled = YES;
					break;
				case NSOrderedDescending:
					[self.timesTable scrollToRowAtIndexPath:scrollindexpath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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



- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }    

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Time" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:30];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Table == %@",selectedTimeTable];
	[fetchRequest setPredicate:predicate];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"dep_unihour" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dep_minute" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];

//	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dep_hour" cacheName:@"Root"];
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dep_unihour" cacheName:nil];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor2 release];
	[sortDescriptor1 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    




/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (adDisp == NO) {
		// Request an ad
//		adMobAd = [AdMobView requestAdWithDelegate:self];
//		[adMobAd retain];
//		NSLog(@"retain: %d",[adMobAd retainCount]);
        
#ifdef Log
        NSLog(@"GAD Request- Times");
#endif

        CGRect frame = self.navigationController.view.frame;

        adMobAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        adMobAd.adUnitID = MADIATION_ID;
        adMobAd.delegate = self;
        [adMobAd setRootViewController:self];
        adMobAd.center = CGPointMake(frame.size.width/2, frame.size.height + (CGSizeFromGADAdSize(kGADAdSizeBanner).height /2));
//        adMobAd.center = CGPointMake(0, frame.size.height);
        adHide = YES;
        
        [self.navigationController.view addSubview:adMobAd];
        adDisp = YES;

        [adMobAd loadRequest:[GADRequest request]];
        adReq = YES;


	}
	[self.timesTable reloadData];
	
}



- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

#ifdef Log
	NSLog(@"will Disappear");
#endif
	if (adHide == NO) {
		
		CGRect frame = self.navigationController.view.frame;
		
		[UIView beginAnimations:@"AdView" context:nil];
		[UIView setAnimationDuration:0.4f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		// put the ad at the bottom of the screen
		adMobAd.frame = CGRectMake(0, frame.size.height + CGSizeFromGADAdSize(kGADAdSizeBanner).height, 320, CGSizeFromGADAdSize(kGADAdSizeBanner).height);
		self.navigationController.view.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height + CGSizeFromGADAdSize(kGADAdSizeBanner).height);
		adHide = YES;
        
		[UIView commitAnimations];
	}
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

#ifdef Log
	NSLog(@"Did Disappear");
#endif
	
	if (adDisp == YES) {
		[adMobAd removeFromSuperview];
		adDisp = NO;		
	}

#ifdef Log
	NSLog(@"retain: %d",[adMobAd retainCount]);
#endif

    if (adReq == YES) {
#ifdef Log
        NSLog(@"adReq:YES");
#endif
        [adMobAd release]; adMobAd = nil;
        adReq = NO;        
    }
    
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
    return [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *timeCellIdentifier = @"timecell";
	
	timeCellDisp = (TimeCell*)[tableView dequeueReusableCellWithIdentifier:timeCellIdentifier];
	
    if (timeCellDisp == nil) {
		timeCellDisp = [[[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellIdentifier] autorelease];
		timeCellDisp.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	NSManagedObject *tableCellData = [fetchedResultsController objectAtIndexPath:indexPath];

	NSInteger hour = [[tableCellData valueForKey:@"dep_hour"] integerValue];
	NSInteger minute = [[tableCellData valueForKey:@"dep_minute"] integerValue];
	NSString *time = [[NSString alloc] initWithFormat:@"%2d:%02d",hour,minute];
	

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

	[time release];
	[timeCellDisp setNeedsDisplay];

    return timeCellDisp;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectioninfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [NSString stringWithFormat:NSLocalizedString(@" %@ o'clock",nil),[sectioninfo name]];
}			

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//	return [fetchedResultsController sectionIndexTitles];
	return allKeys;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
//allocしてない３つはコメントアウト
//	[directionValue release];
//	[lineValue release];
//	[stationValue release];

//	[selectedTimeTable release];
	
    [allKeys release];
	[allTime release];
	[timeCellDisp release];
	[timesTable release];
	[fetchedResultsController release];
	[managedObjectContext release];
	
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
	  
    if (adHide == YES) {
    
        [UIView setAnimationsEnabled:YES];
        
        
        // get the view frame
        CGRect frame = self.navigationController.view.frame;
        
        // put the ad at the bottom of the screen
        //	adMobAd.frame = CGRectMake(0, frame.size.height, frame.size.width, 48);
        //	[self.navigationController.view addSubview:adMobAd];
        
        adMobAd.center = CGPointMake(frame.size.width/2, frame.size.height + (CGSizeFromGADAdSize(kGADAdSizeBanner).height /2));
        
        
        [UIView beginAnimations:@"AdView" context:nil];
        [UIView setAnimationDuration:0.4f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        adMobAd.frame = CGRectMake(0, frame.size.height - CGSizeFromGADAdSize(kGADAdSizeBanner).height, frame.size.width, CGSizeFromGADAdSize(kGADAdSizeBanner).height);
        self.navigationController.view.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height - CGSizeFromGADAdSize(kGADAdSizeBanner).height);
        adHide = NO;
        
#ifdef Log
        NSLog(@"Times -> %f,%f,%f,%f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
#endif
        [UIView commitAnimations];
        

    }
    
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
    adReq = NO;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
}


@end

