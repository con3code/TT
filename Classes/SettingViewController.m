//
//  SettingViewController.m
//  TT
//
//  Created by Kotatsu RIN on 09/12/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"


@implementation SettingViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 1;
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	//複数セクションのテーブルビューの場合
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Online Timetables",nil);
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					break;
			}
			break;
		case 1:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Help",nil);
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		case 2:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"About This App",nil);
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];		
	
	OnlineTimetableViewController *sitelist;

	NSBundle *mainBundle = [NSBundle mainBundle];

	UIViewController *help;
	UIWebView *helpview;
	NSString *helpFilePath = [mainBundle pathForResource:@"help" ofType:@"html"];
#ifdef Log
    NSLog(@"[helpFilePath -> %@]",helpFilePath);
#endif
	NSURL *helpUrl = [NSURL  fileURLWithPath:helpFilePath];

	UIViewController *about;
	UIWebView *aboutview;
	NSString *aboutFilePath = [mainBundle pathForResource:@"about" ofType:@"html"];
#ifdef Log
    NSLog(@"[aboutFilePath -> %@]",aboutFilePath);
#endif
	NSURL *aboutUrl = [NSURL fileURLWithPath:aboutFilePath];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	CGRect webframe =  CGRectMake(self.navigationController.view.frame.origin.x , self.navigationController.view.frame.origin.x, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height-64);
	
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					sitelist = [[OnlineTimetableViewController alloc] initWithStyle:UITableViewStyleGrouped];
					sitelist.managedObjectContext = self.managedObjectContext;
					sitelist.title = NSLocalizedString(@"Online Timetables",nil);
					[self.navigationController pushViewController:sitelist animated:YES];
					[sitelist release];
					break;
			}
			break;
		case 1:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					helpview = [[UIWebView alloc] initWithFrame:webframe];
					help = [[UIViewController alloc] init];
					[help.view addSubview:helpview];
					helpview.delegate = self;
					[helpview loadRequest:[NSURLRequest requestWithURL:helpUrl]];
					help.title = NSLocalizedString(@"Help",nil);
					[self.navigationController pushViewController:help animated:YES];
					[helpview release];
					[help release];
					break;
			}
			break;
		case 2:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					aboutview = [[UIWebView alloc] initWithFrame:webframe];
					about = [[UIViewController alloc] init];
					[about.view addSubview:aboutview];
					aboutview.delegate = self;
					[aboutview loadRequest:[NSURLRequest requestWithURL:aboutUrl]];
					about.title = NSLocalizedString(@"About",nil);
					[self.navigationController pushViewController:about animated:YES];
					[aboutview release];
					[about release];
					break;
			}
			break;
		default:
			break;
	}
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"",nil);
			break;
		case 1:
			return NSLocalizedString(@"",nil);
			break;
		case 2:
			return NSLocalizedString(@"",nil);
			break;
	}
	return @"";
}


- (void)webdone {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *requestURL = [request URL]; 
	
	switch (navigationType) {
		case UIWebViewNavigationTypeLinkClicked:
			// Check to see what protocol/scheme the requested URL is. 
			if ([[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"]) { 
				return ![[UIApplication sharedApplication] openURL:[request URL]];
			} 
			// Auto release 
//			[requestURL release];
			// If request url is something other than http or https it will open 
			// in UIWebView. You could also check for the other following 
			// protocols: tel, mailto and sms 
			break;
		case UIWebViewNavigationTypeFormSubmitted:
			break;
		case UIWebViewNavigationTypeFormResubmitted:
			break;
		case UIWebViewNavigationTypeBackForward:
			break;
		case UIWebViewNavigationTypeReload:
			break;
		case UIWebViewNavigationTypeOther:
			break;
		default:
			break;
	}
	
	return YES;
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
    [super dealloc];
}


@end

/*

//複数セクションのテーブルビューの場合
switch ([indexPath indexAtPosition:0]) {
	case 0:
		switch ([indexPath indexAtPosition:1]) {
			case 0:
				break;
			case 1:
				break;
			default:
				break;
		}
		break;
	case 1:
		switch ([indexPath indexAtPosition:1]) {
			case 0:
				break;
			case 1:
				break;
			default:
				break;
		}
		break;
	default:
		break;
}
 
*/	



#pragma mark OnlineTimetableViewController


@implementation OnlineTimetableViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;


/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 3;
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	//複数セクションのテーブルビューの場合
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Ekitan Search",nil);
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					break;
			}
			break;
		case 1:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Ekitan Web",nil);
					//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"Yahoo Transit Web",nil);
					//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Toretabi Web",nil);
					//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	ReadFileView *readView;
	WebViewController *web;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					readView = [[ReadFileView alloc] initWithNibName:@"ReadFileView" bundle:nil];					
					readView.managedObjectContext = self.managedObjectContext;
					[self.navigationController pushViewController:readView animated:YES];
					[readView release];
					break;
				default:
					break;
			}
			break;
		case 1:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					web = [[WebViewController alloc] init];
					web.whichSite = kSiteEkitan;
					web.url = @"http://timetable.ekitan.com/train/TimeLineList/0.shtml";
					web.managedObjectContext = self.managedObjectContext;
					web.callparent = self;
					[self.navigationController presentModalViewController:web animated:YES];
					[web release];
					break;
				case 1:
					web = [[WebViewController alloc] init];
					web.whichSite = kSiteYahooJapan;
					web.url = @"http://transit.map.yahoo.co.jp/station/list";
					web.managedObjectContext = self.managedObjectContext;
					web.callparent = self;
					[self.navigationController presentModalViewController:web animated:YES];
					[web release];
					break;
				case 2:
					web = [[WebViewController alloc] init];
					web.whichSite = kSiteDoconavi;
					web.url = @"http://jikoku.toretabi.jp/cgi-bin/tra.cgi/cond";
//					web.url = @"http://www.doconavi.com/cgi-bin/tra.cgi/cond";
					web.managedObjectContext = self.managedObjectContext;
					web.callparent = self;
					[self.navigationController presentModalViewController:web animated:YES];
					[web release];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}


- (void)webdone {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
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
    [super dealloc];
}


@end



