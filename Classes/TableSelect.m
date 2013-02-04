//
//  TableSelect.m
//  TT
//
//  Created by Kotatsu RIN on 09/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableSelect.h"
#import "TopViewController.h"
#import "TableListCell.h"
#import "ButtonImages.h"

//空白セルと境界線
@implementation NoView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		// Initialization code
		self.frame = frame;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, 0.2);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 40.0f);
	CGContextAddLineToPoint(context, 320.0f, 40.0f);
	CGContextStrokePath(context);
//	CGContextRelease(context);
}


- (void)dealloc {
    [super dealloc];
}

@end


//混合する時刻表選択のためのテーブル表示
@implementation TableSelect

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize dochi;
@synthesize parent;



- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect viewRect = CGRectMake(0, 0, 320, 40);
	NoView *noView = [[NoView alloc] initWithFrame:viewRect];
	noView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];

	CGRect titleRect = CGRectMake(10, 10, 300, 20);
	UIButton *header = [[UIButton alloc] initWithFrame:titleRect];
	header.backgroundColor = [UIColor whiteColor];
	header.opaque = YES;
	[header setTitle:NSLocalizedString(@"No Selection",nil) forState:UIControlStateNormal];
	header.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	header.titleLabel.textColor = [UIColor grayColor];
	[header addTarget:self action:@selector(noSelect) forControlEvents:UIControlEventTouchUpInside];
	 
	[noView addSubview:header];
	[header release];
	
	//テーブルのヘッダー
	self.tableView.tableHeaderView = noView;
	[self.tableView reloadData];
	[noView release];
	
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


- (void)cancel:(id)sender {
	
	//	NSLog(@"cancel!");
	[parent dismissModalViewControllerAnimated:YES];
	
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CGRect viewRect = CGRectMake(0, 0, 320, 40);
	
	context = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(context, viewRect);
	CGContextSetLineWidth(context, 0.2);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 40.0f);
	CGContextAddLineToPoint(context, 320.0f, 40.0f);
	CGContextStrokePath(context);
//	CGContextRelease(context);

}

- (void)noSelect {

	NSString *selectTitle = [NSString stringWithFormat:@""];		//駅名
	NSInteger TableNo = 0;
	[parent tableSetting:dochi asNo:TableNo ofName:selectTitle];
		
	[self dismissModalViewControllerAnimated:YES];
	
}


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

	NSString *selectCellIdentifier = @"selectCell";
    
    TableListCell *cell = (TableListCell*)[tableView dequeueReusableCellWithIdentifier:selectCellIdentifier];
	//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	
    if (cell == nil) {
        cell = [[[TableListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:selectCellIdentifier] autorelease];
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
		
    return cell;
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSString *selectTitle = [NSString stringWithFormat:NSLocalizedString(@"%@:%@:%@",nil),[selectedObject valueForKeyPath:@"thisStation.name"],[selectedObject valueForKeyPath:@"thisLine.name"],[selectedObject valueForKey:@"direction"]];
	NSInteger TableNo = (NSInteger)[[selectedObject valueForKey:@"tableNo"] integerValue];
	[parent tableSetting:dochi asNo:TableNo ofName:selectTitle];
	
//	[parent setTT:dochi asNo:TableNo ofName:title];
	
	[self dismissModalViewControllerAnimated:YES];
}



- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
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
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    



// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
}






/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
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
	[fetchedResultsController release];
	[managedObjectContext release];
	[super dealloc];
}


@end

