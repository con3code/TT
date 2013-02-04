//
//  DayTypeSelect.m
//  TT
//
//  Created by Kotatsu RIN on 09/11/02.
//  Copyright 2009 con3office. All rights reserved.
//

#import "DayTypeSelect.h"
#import "TimeTable.h"


@implementation DayTypeSelect

@synthesize currentDaytype;
@synthesize parent;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

}


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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DayCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	
	switch ([indexPath indexAtPosition:1]) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Weekday",nil);
			if ([currentDaytype isEqual:NSLocalizedString(@"Weekday",nil)]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			oldIndexPathRow = indexPath.row;
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Saturday",nil);
			if ([currentDaytype isEqual:NSLocalizedString(@"Saturday",nil)]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			oldIndexPathRow = indexPath.row;
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"Holiday",nil);
			if ([currentDaytype isEqual:NSLocalizedString(@"Holiday",nil)]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			oldIndexPathRow = indexPath.row;
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"Everyday",nil);
			if ([currentDaytype isEqual:NSLocalizedString(@"Everyday",nil)]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			oldIndexPathRow = indexPath.row;
			break;
		default:
			break;
	}

	
	
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
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];	

	if (oldIndexPathRow == indexPath.row) {
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	UITableViewCell *editcell = [tableView cellForRowAtIndexPath:indexPath];
	
	switch ([indexPath indexAtPosition:1]) {
		case 0:
			editcell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		case 1:
			editcell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		case 2:
			editcell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		case 3:
			editcell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		default:
			break;
	}
	[tableView reloadData];
	


	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndexPathRow inSection:0];
	UITableViewCell *oldcell = [tableView cellForRowAtIndexPath:oldIndexPath];
	oldcell.accessoryType = UITableViewCellAccessoryNone;
	
	
	switch ([indexPath indexAtPosition:1]) {
		case 0:
//			NSLog(@"set 0");
			[self.parent setDaytype:NSLocalizedString(@"Weekday",nil)];
			break;
		case 1:
//			NSLog(@"set 1");
			[self.parent setDaytype:NSLocalizedString(@"Saturday",nil)];
			break;
		case 2:
//			NSLog(@"set 2");
			[self.parent setDaytype:NSLocalizedString(@"Holiday",nil)];
			break;
		case 3:
//			NSLog(@"set 3");
			[self.parent setDaytype:NSLocalizedString(@"Everyday",nil)];
			break;
		default:
//			NSLog(@"set 99");
			break;
	}
	
	[self.navigationController popViewControllerAnimated:YES];

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

