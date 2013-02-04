//
//  TimeTable.m
//  TT
//
//  Created by Kotatsu RIN on 09/09/28.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import "TimeTable.h"
#import "DayTypeSelect.h"

@implementation TimeTable

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize selectedTimeTable;
@synthesize fieldLabels;
@synthesize fieldKeys;
@synthesize tempValues;
@synthesize textFieldBeingEdited;

@synthesize	timeInputView;
@synthesize testButton;

@synthesize actionSheet;
@synthesize pushNavController;

@synthesize waiting;

@synthesize soundTock;

- (void)cancel:(id)sender {
	[[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (void)save:(id)sender {
	if(textFieldBeingEdited != nil)
	{
		[tempValues setObject:textFieldBeingEdited.text forKey:[fieldLabels objectAtIndex:textFieldBeingEdited.tag]];
	}

//	NSLog(@"Pass!!! Save");


	if ([[tempValues allKeys] containsObject:@"from"]) {
		[selectedTimeTable setValue:[tempValues valueForKey:@"from"] forKeyPath:@"thisStation.name"];
	}
	if ([[tempValues allKeys] containsObject:@"route"]) {
		[selectedTimeTable setValue:[tempValues valueForKey:@"route"] forKeyPath:@"thisLine.name"];
	}
	if ([[tempValues allKeys] containsObject:@"to"]) {
		[selectedTimeTable setValue:[tempValues valueForKey:@"to"] forKey:@"direction"];
	}
	if ([[tempValues allKeys] containsObject:@"daytype"]) {
		[selectedTimeTable setValue:[tempValues valueForKey:@"daytype"] forKey:@"daytype"];
	}
	
/*
	if ([[tempValues allKeys] containsObject:@"Vehicle:"]) {
		[selectedTimeTable setValue:[tempValues valueForKey:@"Vehicle:"] forKey:@"vehicleType"];
	}
*/

/*	
	NSLog(@"%@",[selectedTimeTable valueForKey:@"orderNo"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"tableNo"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"station"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"line"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"direction"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"daytype"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"vehicletype"]);
	NSLog(@"%@",[selectedTimeTable valueForKey:@"Times"]);
//	NSLog(@"%@",[selectedTimeTable valueForKey:@""]);
	
*/	

	[[self navigationController] popViewControllerAnimated:YES];

}

- (IBAction)textFieldDone:(id)sender {
	[sender resignFirstResponder];
}


/*
- (id)init {
 
	if (self = [super init])
	return self;
}
*/

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		
//		NSLog(@"TimeTable: initWithStyle");
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	NSLog(@"TimeTable: viewDidLoad");
	
	timeInputView = nil;
	
	tempValues = [[NSMutableDictionary alloc] init];
	
    NSArray *array_name = [[NSArray alloc] initWithObjects:NSLocalizedString(@"From:",nil), NSLocalizedString(@"Route:",nil), NSLocalizedString(@"To:",nil), NSLocalizedString(@"DayType:",nil), nil];
    NSArray *array_key = [[NSArray alloc] initWithObjects:@"from", @"route", @"to", @"daytype", nil];
	self.fieldLabels = array_name;
	self.fieldKeys = array_key;
	[array_key release];
	[array_name release];
	
	editing = NO;
	waiting = NO;
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	self.tempValues = dict;
	[dict release];
	
}


- (void)loadView {
    [super loadView];
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit",nil) style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];

	int startingtime = 4;
	int k = 0;
	for (int j = 0; j < 3; j++) {
		for (int i = 0; i < 8; i++) {
			CGRect testRect = CGRectMake( 10+(37*i), 210+(50*j), 37, 37);
			testButton = [[UIButton alloc] initWithFrame:testRect];
			UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
			UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
			UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
			UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];

			if (startingtime+k < 24) {
				[testButton setTitle:[NSString stringWithFormat:@"%02d",startingtime+k] forState:UIControlStateNormal];
				[testButton setTag:startingtime+k];
			}
			else {
				[testButton setTitle:[NSString stringWithFormat:@"%02d",(startingtime+k)-24] forState:UIControlStateNormal];
				[testButton setTag:(startingtime+k)-24];
			}
			
			[testButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
			[testButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateSelected];
			[testButton addTarget:self action:@selector(TimeInputViewIn:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:testButton];
			[testButton release];

			k++;
		}
	}
	
}


- (void)edit:(id)sender {

	if (editing == NO) {
		editing = YES;
//		NSLog(@"editing YES!");
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save",nil);
		[self.tableView reloadData];
		
	}
	else {
		editing = NO;
//		NSLog(@"editing NO!");
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit",nil);
		
		[self.tableView reloadData];
		
		if(textFieldBeingEdited != nil)
		{
			[tempValues setObject:textFieldBeingEdited.text forKey:[fieldKeys objectAtIndex:textFieldBeingEdited.tag]];
		}
		
		
		if ([[tempValues allKeys] containsObject:@"from"]) {
			[selectedTimeTable setValue:[tempValues valueForKey:@"from"] forKeyPath:@"thisStation.name"];
		}
		if ([[tempValues allKeys] containsObject:@"route"]) {
			[selectedTimeTable setValue:[tempValues valueForKey:@"route"] forKeyPath:@"thisLine.name"];
		}
		if ([[tempValues allKeys] containsObject:@"to"]) {
			[selectedTimeTable setValue:[tempValues valueForKey:@"to"] forKey:@"direction"];
		}
		if ([[tempValues allKeys] containsObject:@"daytype"]) {
			[selectedTimeTable setValue:[tempValues valueForKey:@"daytype"] forKey:@"daytype"];
		}
		
/*		
		NSLog(@"%@",[selectedTimeTable valueForKey:@"orderNo"]);
		NSLog(@"%@",[selectedTimeTable valueForKey:@"tableNo"]);
		NSLog(@"%@",[selectedTimeTable valueForKeyPath:@"thisStation.name"]);
		NSLog(@"%@",[selectedTimeTable valueForKeyPath:@"thisLine.name"]);
		NSLog(@"%@",[selectedTimeTable valueForKey:@"direction"]);
		NSLog(@"%@",[selectedTimeTable valueForKey:@"daytype"]);
		NSLog(@"%@",[selectedTimeTable valueForKey:@"vehicletype"]);
		NSLog(@"%@",[selectedTimeTable valueForKey:@"Times"]);
	//	NSLog(@"%@",[selectedTimeTable valueForKey:@""]);
		
*/
	}	
	
}

- (void)settingupTimeInputView {

	int startingtime = 4;
	
	ButtonImages *bi = [ButtonImages instance];	
	while (bi.loadDone == NO) {
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//		sleep(1);
		//if (bi.loadDone == YES) {break;}
	}
	
	//	UIViewController *viewController = [[UIViewController alloc] init];
	
	TimeInputViewController *aTimeInput;
	if (timeInputView == nil) {
		aTimeInput = [[TimeInputViewController alloc] init];
		timeInputView = aTimeInput;
		timeInputView.sTag = sTag;
		timeInputView.startHour = startingtime;
		timeInputView.managedObjectContext = self.managedObjectContext;
		timeInputView.fetchedResultsController = self.fetchedResultsController;
		timeInputView.selectedTimeTable = self.selectedTimeTable;
	}
	else {
		timeInputView.sTag = sTag;
		[timeInputView.view setNeedsDisplay];
	}
	timeInputView.editing = NO;
	
	if (pushNavController == nil) {
		pushNavController = [[UINavigationController alloc] initWithRootViewController:timeInputView];	
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:timeInputView action:@selector(cancel:)];
		pushNavController.navigationBar.topItem.leftBarButtonItem = backButton;
		[backButton release];
		
//		pushNavController.navigationBar.topItem.rightBarButtonItem = [timeInputView editButtonItem];
		pushNavController.navigationBar.topItem.title = [selectedTimeTable valueForKeyPath:@"thisStation.name"];
		timeInputView.navController = pushNavController;
	}
	else {
		pushNavController.navigationBar.topItem.leftBarButtonItem.title = NSLocalizedString(@"Back",nil);
	}

	
	[[self navigationController] presentModalViewController:pushNavController animated:YES];
	
	waiting = NO;
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)TimeInputViewIn:(id)sender {
//	NSLog(@"TimeInputViewIn");

	NSURL*  url;
	url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"aif"]];
	
	// システムサウンドを作成する
	AudioServicesCreateSystemSoundID((CFURLRef)url, &soundTock);
	
	// サウンドを鳴らす
	AudioServicesPlaySystemSound(soundTock);	
	
	
	sTag = [sender tag];

	waiting = YES;

	[self performSelectorOnMainThread:@selector(waitingStarted) withObject:nil waitUntilDone:YES];
	[NSThread detachNewThreadSelector:@selector(waitingEnded) toTarget:self withObject:nil];


	
}


- (void)viewWillAppear:(BOOL)animated {

	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(textFieldBeingEdited != nil)
	{
		[tempValues setObject:textFieldBeingEdited.text forKey:[fieldKeys objectAtIndex:textFieldBeingEdited.tag]];
	}
}

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


- (void)waitingStarted {
//	NSLog(@"waitingStarted");
	
	id pool = [[NSAutoreleasePool alloc] init];
	
	// open a dialog with just an OK button

	if (actionSheet == nil) {
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
	}

	
//	[actionSheet showInView:self.view];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];	
	// show from our table view (pops up in the middle of the table)	

	
	[pool release];
	
//	NSLog(@"waitingStarted2");
}

- (void)waitingEnded {
//	NSLog(@"waitingEnded");
	
	id pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(settingupTimeInputView) withObject:nil waitUntilDone:YES];
	
	[pool release];
	
//	NSLog(@"waitingEnded2");
}



#pragma mark Table view methods



/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
*/

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.highlighted = NO;

		UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
		label.tag = kLabelTag;
		label.font = [UIFont boldSystemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentRight;
		[cell.contentView addSubview:label];
		[label release];
		
		if ([indexPath row] == 3) {
			UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
			typeLabel.font = [UIFont systemFontOfSize:18];
            typeLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:typeLabel];
			[typeLabel release];
		}
		else {
			UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
			textField.clearsOnBeginEditing = NO;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.font = [UIFont systemFontOfSize:18];
            textField.backgroundColor = [UIColor clearColor];
			[textField setDelegate:self];
			textField.returnKeyType = UIReturnKeyDone;
			[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[cell.contentView addSubview:textField];
			[textField release];
		}
	}
	
	NSUInteger row = [indexPath row];
	UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];

	UITextField *textField = nil;
	UILabel *typeField;
	
	if (row == 3) {
		for (UIView *oneView in cell.contentView.subviews) {
			if ([oneView isMemberOfClass:[UILabel class]]) {
				typeField = (UILabel *)oneView;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}		
	}
	else{
		for (UIView *oneView in cell.contentView.subviews) {
			if ([oneView isMemberOfClass:[UITextField class]]) {
				textField = (UITextField *)oneView;
				if (editing == NO) {
					textField.enabled = NO;
				}
				else {
					textField.enabled = YES;	
				}
			}
		}
	}
	
	label.text = [fieldLabels objectAtIndex:row];
	
	switch (row) {
		case 0:
			if ([[tempValues allKeys] containsObject:@"from"]) {
				textField.text = [tempValues objectForKey:@"from"];
			}
			else {
				textField.text = [[selectedTimeTable valueForKey:@"thisStation"] valueForKey:@"name"];
			}
//			NSLog(@"Pass!!! Case0");
			break;
		case 1:
			if ([[tempValues allKeys] containsObject:@"route"]) {
				textField.text = [tempValues objectForKey:@"route"];
			}
			else {
				textField.text = [[selectedTimeTable valueForKey:@"thisLine"] valueForKey:@"name"];
			}
//			NSLog(@"Pass!!! Case1");
			break;
		case 2:
			if ([[tempValues allKeys] containsObject:@"to"]) {
				textField.text = [tempValues objectForKey:@"to"];
			}
			else {
				textField.text = [selectedTimeTable valueForKey:@"direction"];
			}
//			NSLog(@"Pass!!! Case2");
			break;
		case 3:
			if ([[tempValues allKeys] containsObject:@"daytype"]) {
					typeField.text = [tempValues objectForKey:@"daytype"];
			}
			else {
					typeField.text = [selectedTimeTable valueForKey:@"daytype"];
			}
//			NSLog(@"Pass!!! Case3");
			break;
		default:
			break;
	}
	
	//現在編集中なのは判定後，ならはnilを設定
	if (textFieldBeingEdited == textField) {
		textFieldBeingEdited = nil;
	}
	textField.tag = row;

    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	//3行目以外は選択禁止
	if ([indexPath row] == 3 & editing == YES) {
		return indexPath;
	}
	else {
		return nil;		
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:NO];	
	if ([indexPath row] == 3) {
		DayTypeSelect *dtsController = [[DayTypeSelect alloc] initWithStyle:UITableViewStyleGrouped];
		dtsController.title = NSLocalizedString(@"DayType",nil);
		dtsController.parent = self;
		if ([[tempValues allKeys] containsObject:@"daytype"]) {
			dtsController.currentDaytype = [tempValues objectForKey:@"daytype"];
		}
		else {
			dtsController.currentDaytype = [selectedTimeTable valueForKey:@"daytype"];
		}
		[[self navigationController] pushViewController:dtsController animated:YES];
		[dtsController release];
	}
	
}


- (void)setDaytype:(NSString *)daytype {
//	NSLog(@"set !!!!");

	[tempValues setObject:daytype forKey:@"daytype"];

}


#pragma mark textField view methods


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[tempValues setObject:textField.text forKey:[fieldKeys objectAtIndex:textField.tag]];
}

- (void)dealloc {
//allocしてないものはコメントアウト
//	[textFieldBeingEdited release];
	[pushNavController release];

	[actionSheet release];
	[timeInputView release];
	[tempValues release];
	[fieldKeys release];
	[fieldLabels release];

//	[fetchedResultsController release];
//	[managedObjectContext release];
	
    [super dealloc];
}


@end
