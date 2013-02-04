//
//  RootViewController.m
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright con3 Office 2009. All rights reserved.
//

#import "RootViewController.h"
#import "TimesViewController.h"

#import "GADBannerView.h"
#import "GADRequest.h"

@implementation RootViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize ttController;

@synthesize timetableView;
@synthesize actionSheet;

@synthesize firstInsert = _firstInsert;
@synthesize insertRow;
@synthesize insertScrollIndexPath;

#pragma mark -
#pragma mark View lifecycle


- (id) init {
	if (self == [super init]) {
		adDisp = NO;
		insertRow = NO;
		thisInsert = NO;
	}
	return self;
}


- (void) loadView {
	[super loadView];
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.delegate = self;

	self.timetableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	self.timetableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.timetableView.delegate = self;
	self.timetableView.dataSource = self;

	self.view = timetableView;
	
	
	CGRect viewRect = CGRectMake(0, 0, 320, CGSizeFromGADAdSize(kGADAdSizeBanner).height);
	AdView *adView = [[AdView alloc] initWithFrame:viewRect];
	adView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];

    
	CGRect lastRect = CGRectMake(0, 0, 320, 24);
	UIView *footerView = [[UIView alloc] initWithFrame:lastRect];
	footerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	
	//テーブルのヘッダー
	self.timetableView.tableHeaderView = adView;
	self.timetableView.tableFooterView = footerView;
	[self.timetableView reloadData];
	[footerView release];
	[adView release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)viewWillAppear:(BOOL)animated {
//	NSLog(@"Will Appear");
	
	[super viewWillAppear:animated];

	if (adDisp == NO) {
		// Request an ad
//		adMobAd = [AdMobView requestAdWithDelegate:self];
//		[adMobAd retain];
        
#ifdef Log
        NSLog(@"GAD Request - Root");
#endif
        CGRect frame = self.navigationController.view.frame;
        
        adMobAd = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner] autorelease];
        adMobAd.adUnitID = MADIATION_ID;
        adMobAd.delegate = self;
        [adMobAd setRootViewController:self];
        adMobAd.center = CGPointMake(frame.size.width/2, frame.size.height);
        [self.navigationController.view addSubview:adMobAd];
        
        [adMobAd loadRequest:[GADRequest request]];
        

	}

	[self.timetableView reloadData];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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
- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}
*/
/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (void)updateclock:(NSTimer *)timer {
	
	NSDate *date = [NSDate date];
	NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
	
	[dateForm setDateStyle:NSDateFormatterNoStyle];
	[dateForm setTimeStyle:NSDateFormatterMediumStyle];
	
	nowClock.text = [dateForm stringFromDate:date];
	
	[dateForm release];
}


- (void)waitingStarted {
//	NSLog(@"waitingStarted");
	
	id pool = [[NSAutoreleasePool alloc] init];

	// open a dialog with just an OK button
	actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleDefault];

	CGRect tRect = CGRectMake(60, 20, 240, 20);
	UILabel *overlayText = [[UILabel alloc] initWithFrame:tRect];
	[overlayText setFont:[UIFont boldSystemFontOfSize:18]];
	overlayText.textAlignment = UITextAlignmentLeft;
	[overlayText setText:NSLocalizedString(@"Please Wait...",nil)];
	overlayText.textColor = [UIColor whiteColor];
	overlayText.backgroundColor = [UIColor clearColor];
	[actionSheet addSubview:overlayText];
	[overlayText release];

	CGRect fRect = CGRectMake(20, 20, 20, 20);
	UIActivityIndicatorView *working = [[UIActivityIndicatorView alloc] initWithFrame:fRect];
	[actionSheet addSubview:working];
	[working startAnimating];
	[working release];
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)

	[pool release];
	
//	NSLog(@"waitingStarted2");
}

- (void)waitingEnded {
//	NSLog(@"waitingEnded");
	
	id pool = [[NSAutoreleasePool alloc] init];
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[actionSheet release];
	
	[pool release];
	
//	NSLog(@"waitingEnded2");
}

- (void)removeView:(id)sender {
	
	[sender removeFromSuperview];
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject {
	
	self.firstInsert = [self.fetchedResultsController.sections count] == 0;
//	NSLog(@"firstInsert %d", self.firstInsert);
	
	thisInsert = YES;
	
	NSInteger maxNum = 0;
	NSInteger newNum = 0;
		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *mng_context = [self.fetchedResultsController managedObjectContext];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Table" inManagedObjectContext:mng_context];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tableNo" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *arrayForCount = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSInteger tableCount = [arrayForCount count];
//	NSLog(@"fetch %d", tableCount);
	
	
	if (arrayForCount == nil) {
		NSLog(@"CoreData Error");
	}
	
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
	
	
	NSManagedObject *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:self.managedObjectContext];
	NSManagedObject *newStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
	NSManagedObject *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
	[newTable setValue:newStation forKey:@"thisStation"];
	[newTable setValue:newLine forKey:@"thisLine"];
	
	[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"orderNo"];
	[newTable setValue:[NSNumber numberWithInteger:newNum] forKey:@"tableNo"];
	[newTable setValue:NSLocalizedString(@"there",nil) forKey:@"direction"];
	[newTable setValue:NSLocalizedString(@"here",nil) forKeyPath:@"thisStation.name"];
	[newTable setValue:NSLocalizedString(@"via",nil) forKeyPath:@"thisLine.name"];
	[newTable setValue:NSLocalizedString(@"Everyday",nil) forKey:@"daytype"];
	
	
	error = nil;
	if (![self.managedObjectContext save:&error]) {
		// Handle the error...
	}

}


/*
- (void)MakeTimeInputView {
	
	id pool = [[NSAutoreleasePool alloc] init];
	
	
	//時間入力画面を作成（前倒し）
	//	TimeInputView *aTimeInput = [[TimeInputView alloc] init];
	//	ttController.timeInputView = aTimeInput;
	//	[aTimeInput release];
	
	
	//時間入力画面を作成
	TimeInputView *aTimeInput = [[TimeInputView alloc] init];
	ttController.timeInputView = aTimeInput;
	[aTimeInput release];	
	
	
	[pool release];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
	NSString *tableCellIdentifier = @"tableCell";
    
    TableListCell *cell = (TableListCell*)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];

    if (cell == nil) {
        cell = [[[TableListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableCellIdentifier] autorelease];
    }

	// Configure the cell.
	ButtonImages *bi = [ButtonImages instance];
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];

	cell.textLabel.font = [UIFont systemFontOfSize:16];
	NSString *daytype_str = [managedObject valueForKey:@"daytype"];
	
	if ([daytype_str length]) {
//		NSString *daychar = [[managedObject valueForKey:@"daytype"] substringWithRange:NSMakeRange(0, 1)];
		
		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ -> %@",nil),[managedObject valueForKeyPath:@"thisStation.name"],[managedObject valueForKey:@"direction"]];
//		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"[%@] %@ -> %@",nil),daychar,[managedObject valueForKeyPath:@"thisStation.name"],[managedObject valueForKey:@"direction"]];

		if ([daytype_str isEqualToString:NSLocalizedString(@"Weekday",nil)]) {
			cell.dayicon.image = bi.weekday_icon;
//			cell.daytype = bi.weekday_icon;
		}
		else if ([daytype_str isEqualToString:NSLocalizedString(@"Saturday",nil)]) {
			cell.dayicon.image = bi.saturday_icon;
//			cell.daytype = bi.saturday_icon;			
		}
		else if ([daytype_str isEqualToString:NSLocalizedString(@"Holiday",nil)]) {
			cell.dayicon.image = bi.holiday_icon;
//			cell.daytype = bi.holiday_icon;			
		}
		else if ([daytype_str isEqualToString:NSLocalizedString(@"Everyday",nil)]) {
			cell.dayicon.image = bi.everyday_icon;
//			cell.daytype = bi.everyday_icon;			
		}
	}
	else {
		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ -> %@",nil),NSLocalizedString(@" ",@"no daytype"),[managedObject valueForKeyPath:@"thisStation.name"],[managedObject valueForKey:@"direction"]];
	}

	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[managedObject valueForKeyPath:@"thisLine.name"]];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.showsReorderControl = YES;
	
/*	
	cell.R = 0.8f;
	cell.G = 0.9f;
	cell.B = 1.0f;
	cell.A = 1.0f;		
*/	
	
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TimesViewController *timeController = [[TimesViewController alloc] init];
	
	NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	timeController.selectedTimeTable = selectedObject;					//選択されたセル
	timeController.title = [NSString stringWithFormat:NSLocalizedString(@"%@:%@:%@",nil),[selectedObject valueForKeyPath:@"thisStation.name"],[selectedObject valueForKeyPath:@"thisLine.name"],[selectedObject valueForKey:@"direction"]];
	timeController.managedObjectContext = self.managedObjectContext;			//管理オブジェクトコンテキスト
	timeController.callparent = self;
	
	[[self navigationController] pushViewController:timeController animated:YES];

	[selectedObject release];
	[timeController release];

}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	TimeTable *editingController = [[TimeTable alloc] initWithStyle:UITableViewStyleGrouped];	
	NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	editingController.selectedTimeTable = selectedObject;					//選択されたセル
	editingController.managedObjectContext = self.managedObjectContext;

	[[self navigationController] pushViewController:editingController animated:YES];

	[selectedObject release];
	[editingController release];
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {

			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}   
}

/*
- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
	[super setEditing:flag animated:animated];
	NSLog(@"setEditing: %d : %d",flag,animated);
	
}	
*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

	NSInteger c_row;
	NSInteger s_row = sourceIndexPath.row;
	NSInteger d_row = destinationIndexPath.row;
	NSInteger counts = [[self.fetchedResultsController fetchedObjects] count];
	NSManagedObject *tableToReorder;
//	NSLog(@"count %d",counts);
	
	if (s_row < d_row) {
		for (c_row = 0; c_row < counts; c_row ++) {
			if (c_row < s_row & c_row < d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row+1] forKey:@"orderNo"];
//				NSLog(@"A %@",[tableToReorder valueForKey:@"orderNo"]);
			}
			else if (c_row > s_row & c_row <= d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row] forKey:@"orderNo"];
//				NSLog(@"B %@",[tableToReorder valueForKey:@"orderNo"]);
			}
			else if (c_row > s_row & c_row > d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row+1] forKey:@"orderNo"];
//				NSLog(@"C %@",[tableToReorder valueForKey:@"orderNo"]);
			}
		}
		tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:s_row inSection:sourceIndexPath.section]];
		[tableToReorder setValue:[NSNumber numberWithInteger:d_row+1] forKey:@"orderNo"];
//		NSLog(@"move to %@",[tableToReorder valueForKey:@"orderNo"]);

	}
	
	if (s_row > d_row) {
		for (c_row = 0; c_row < counts; c_row ++) {
			if (c_row < s_row & c_row < d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row+1] forKey:@"orderNo"];
//				NSLog(@"a %@",[tableToReorder valueForKey:@"orderNo"]);
			}
			else if (c_row < s_row & c_row >= d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row+2] forKey:@"orderNo"];
//				NSLog(@"b %@",[tableToReorder valueForKey:@"orderNo"]);
			}
			else if (c_row > s_row & c_row > d_row) {
				tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:c_row inSection:sourceIndexPath.section]];
				[tableToReorder setValue:[NSNumber numberWithInteger:c_row+1] forKey:@"orderNo"];
//				NSLog(@"c %@",[tableToReorder valueForKey:@"orderNo"]);
			}
		}
		tableToReorder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:s_row inSection:sourceIndexPath.section]];
		[tableToReorder setValue:[NSNumber numberWithInteger:d_row+1] forKey:@"orderNo"];
//		NSLog(@"move to %@",[tableToReorder valueForKey:@"orderNo"]);
	}
	
	tableToReorder = nil;
	NSError *error;
	[managedObjectContext save:&error];	
	
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Table" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNo" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	aFetchedResultsController = nil;
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.timetableView beginUpdates];
}
*/

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath {
	
	if(NSFetchedResultsChangeUpdate == type) {
		
	} else if(NSFetchedResultsChangeMove == type) {
		//		[self.timetableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	} else if(NSFetchedResultsChangeInsert == type) {
		if (thisInsert) {
			thisInsert = NO;
			[self.timetableView beginUpdates];
			if(!self.firstInsert) {
				[self.timetableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
			} else {
				[self.timetableView insertSections:[[[NSIndexSet alloc] initWithIndex:0] autorelease] withRowAnimation:UITableViewRowAnimationRight];
			}
			
			self.insertScrollIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
			insertRow = YES;
			/*
			 if(!self.firstInsert) {
			 [self.timetableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
			 } else {
			 [self.timetableView insertSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
			 }
			 
			 NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
			 [self.timetableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			 */
			
		}
		
	} else if(NSFetchedResultsChangeDelete == type) {
		
		[self.timetableView beginUpdates];
		NSInteger sectionCount = [[fetchedResultsController sections] count];
		if(0 == sectionCount) {
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:indexPath.section];
			[self.timetableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[self.timetableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
		
	}
}

// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.timetableView endUpdates];
	if (insertRow == YES) {
		insertRow = NO;
		[self.timetableView scrollToRowAtIndexPath:self.insertScrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
	//追加アニメーション処理のために変更している
}



/*
 Instead of using controllerDidChangeContent: to respond to all changes, you can implement all the delegate methods to update the table view in response to individual changes.  This may have performance implications if a large number of changes are made simultaneously.

// Notifies the delegate that section and object changes are about to be processed and notifications will be sent. 
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	// Update the table view appropriately.
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	// Update the table view appropriately.
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
} 
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[timetableView release];
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
	
	adMobAd.alpha = 0.0f;
	
	self.timetableView.tableHeaderView = adMobAd;

	[UIView setAnimationsEnabled:YES];
	[UIView beginAnimations:@"AdView" context:nil];
	[UIView setAnimationDuration:1.0f];

	adMobAd.alpha = 1.0f;
	
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
