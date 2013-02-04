//
//  EkitanTimeTable.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/26.
//  Copyright 2009 con3office. All rights reserved.
//

#import "EkitanTimeTable.h"
#import "TTAppDelegate.h"


static void StartElementSAXFunc(void *ctx, const xmlChar *name, const xmlChar **atts)
{
	[(EkitanTimeTable *)ctx startElementName:name attributes:atts];
}

static void EndElementSAXFunc(void *ctx, const xmlChar *name)
{
	[(EkitanTimeTable *)ctx endElementName:name];
}

static void CharactersSAXFunc(void *ctx, const xmlChar *ch, int len)
{
	[(EkitanTimeTable *)ctx charactersFound:ch len:len];
}

static xmlSAXHandler gSAXHandler = {
	.initialized = XML_SAX2_MAGIC,
	.startElement = StartElementSAXFunc,
	.endElement = EndElementSAXFunc, 
	.characters = CharactersSAXFunc,
};


@implementation EkitanTimeTable


@synthesize managedObjectContext;

@synthesize tableTitle;
@synthesize viewEkitanType;

//@synthesize timesTable;
@synthesize timeCellDisp;
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

@synthesize weekdayUrl;
@synthesize saturdayUrl;
@synthesize holydayUrl;

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

@synthesize recieveData; //暫定

@synthesize backlay;
@synthesize overlay;
@synthesize working;
@synthesize overlayText;


- (void) loadView {
	[super loadView];
	
#ifdef Log
//	NSLog(@"tableview B: %@",[self.tableView description]);
#endif
    
/*
	self.timesTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.timesTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.timesTable.delegate = self;
	self.timesTable.dataSource = self;
	self.tableView = self.timesTable;
*/
//	NSLog(@"tableview A: %@",[self.tableView description]);
	
	CGRect viewRect = CGRectMake(0, 0, 320, 40);
	self.toEkitan = [[UIView alloc] initWithFrame:viewRect];
	self.toEkitan.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.6];
	CGRect titleRect = CGRectMake(20, 10, 300, 20);
    UILabel *headertext = [[UILabel alloc] initWithFrame:titleRect];
    headertext.textColor = [UIColor whiteColor];
    headertext.backgroundColor = [UIColor clearColor];
    headertext.opaque = YES;
    headertext.font = [UIFont boldSystemFontOfSize:18];
    headertext.text = NSLocalizedString(@"Thankyou for & powered by駅探",nil);
	[self.toEkitan addSubview:headertext];

	//テーブルのヘッダー
	self.tableView.tableHeaderView = self.toEkitan;
	[self.tableView reloadData];
	[headertext release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
#ifdef Log
	NSLog(@"EkitanTimeTable View!!!");
	NSLog(@"EkitanDay : %d",daytypeValue);
#endif
	
	deleteKeyword = [[NSArray alloc] initWithObjects:@",時刻表",@",JR時刻表",@",乗り換え案内",@",路線",@",路線図",@",駅探",nil];	

	CGRect bRect = CGRectMake(0, 0, 320, 480);
	backlay = [[UIView alloc] initWithFrame:bRect];
    
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
	[working startAnimating];
	[working release];

	CGRect tRect = CGRectMake(60, 20, 240, 20);
	overlayText = [[UILabel alloc] initWithFrame:tRect];
	[overlayText setFont:[UIFont boldSystemFontOfSize:18]];
	overlayText.textAlignment = UITextAlignmentLeft;
	[overlayText setText:NSLocalizedString(@"Please Wait...",nil)];
	overlayText.textColor = [UIColor whiteColor];
	overlayText.backgroundColor = [UIColor clearColor];
	[overlay addSubview:overlayText];
	[overlayText release];

	[backlay addSubview:overlay];
	
	[UIView setAnimationsEnabled:YES];

	weekdayDone = NO;
	saturdayDone = NO;
	holydayDone = NO;

	if (daytypeValue == kDaytypeWeekday) {
		weekdayDone = YES;
	}
	else if (daytypeValue == kDaytypeSaturday) {
		saturdayDone = YES;
	}
	else if (daytypeValue == kDaytypeHolyday) {
		holydayDone = YES;
	}
	
	selectedSeg = NO;
	
	if (viewEkitanType == kEkitanTimeTable) {
		NSString *info = [NSString stringWithFormat:NSLocalizedString(@"%@ <%@>",nil),lineValue, directionValue];
		self.navigationItem.prompt = info;
		
		NSArray *segmentTextContent = [NSArray arrayWithObjects:NSLocalizedString(@"Weekday",nil), NSLocalizedString(@"Saturday",nil), NSLocalizedString(@"Holiday",nil),nil];
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
		segmentedControl.selectedSegmentIndex = 0;
		segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.frame = CGRectMake(0, 0, 180, 30);
		[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.selectedSegmentIndex = daytypeValue;
				
		self.navigationItem.titleView = segmentedControl;
		[segmentedControl release];
	
		UIImage *save = [UIImage imageNamed:@"down.png"];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:save style:UIBarButtonItemStylePlain target:self action:@selector(saveToCd:)];
	}	
	
#ifdef Log
	NSLog(@"Title-> %@",tableTitle);
#endif
	
}


- (void)saveStarted {
	id pool = [[NSAutoreleasePool alloc] init];
	[[[self navigationController] view] addSubview:self.backlay];
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y -= height;
	overlay.center = center;
	[UIView commitAnimations];
	[working startAnimating];
	[pool release];
}

- (void)saveEnded {
	id pool = [[NSAutoreleasePool alloc] init];
	[overlayText setText:@"Done!"];
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y += height;
	overlay.center = center;
	[UIView commitAnimations];
	[working stopAnimating];
	[self performSelector:@selector(removeView:) withObject:self.backlay afterDelay:1.0f];
	
	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"This Timetable was recorded.",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Done",nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	
	[pool release];
}

- (void)downloadStarted {
	id pool = [[NSAutoreleasePool alloc] init];
	[overlayText setText:NSLocalizedString(@"Please Wait...",nil)];
	[[[self navigationController] view] addSubview:self.backlay];
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y -= height;
	overlay.center = center;
	[UIView commitAnimations];
	[working startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[pool release];
}

- (void)downloadEnded {
	id pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[UIView beginAnimations:@"over" context:nil];
	CGPoint center = overlay.center;
	CGRect frame = overlay.frame;
	CGFloat height = CGRectGetHeight(frame);
	center.y += height;
	overlay.center = center;
	[UIView commitAnimations];
	[working stopAnimating];
	[self performSelector:@selector(removeView:) withObject:self.backlay afterDelay:1.0f];
	[pool release];
}

- (void)removeView:(id)sender {
	[sender removeFromSuperview];
}


- (void)saveToCd:(id)sender {

#ifdef Log
	NSLog(@"CoreData!!!");
#endif
    
	[NSThread detachNewThreadSelector:@selector(saveStarted) toTarget:self withObject:nil];

	[self savingTimeData];
//	[NSThread detachNewThreadSelector:@selector(savingTimeData) toTarget:self withObject:nil];
	

}


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
#ifdef Log
	NSLog(@"fetch %d", tableCount);
#endif

	if (arrayForCount == nil) {
//		NSLog(@"CoreData Error");
	}

#ifdef Log
//	NSLog(@"max: %@", [[maxObject objectAtIndex:0] valueForKey:@"maxID"]);
#endif
    
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

#ifdef Log
	NSLog(@"max: %d", maxNum);
	NSLog(@"new: %d", newNum);
#endif
	
	
	
	if (selectDaytype == kDaytypeWeekday) {
#ifdef Log
		NSLog(@"CD:Weekday");
#endif
        
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
#ifdef Log
				NSLog(@"Starting %02d",startinghour);
#endif
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
#ifdef Log
                NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
#endif
				}
				else {
					unihour = p_hour;
				}
#ifdef Log
				NSLog(@"unihour: %02d",unihour);
#endif
				
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
#ifdef Log
		NSLog(@"CD:Saturday");
#endif
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
#ifdef Log
            NSLog(@"Starting %02d",startinghour);
#endif
                
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
#ifdef Log
                NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
#endif
				}
				else {
					unihour = p_hour;
				}
#ifdef Log
				NSLog(@"unihour: %02d",unihour);
#endif
				
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
#ifdef Log
		NSLog(@"CD:Holyday");
#endif
        
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
#ifdef Log
				NSLog(@"Starting %02d",startinghour);
#endif
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
#ifdef Log
                NSLog(@"unihour: %02d: p %02d: s %02d: c %02d: s %02d: r %02d",unihour,p_hour,startinghour,c_sec,sec,row);
#endif
				}
				else {
					unihour = p_hour;
				}
#ifdef Log
				NSLog(@"unihour: %02d",unihour);
#endif
				
				[newTable setValue:[NSNumber numberWithInt:startinghour] forKey:@"startinghour"];
				[newTime setValue:[NSNumber numberWithInteger:unihour] forKey:@"dep_unihour"];
				[newTime setValue:[NSNumber numberWithInteger:p_hour] forKey:@"dep_hour"];
				[newTime setValue:[NSNumber numberWithInteger:[[time valueForKey:@"dep_minute"] integerValue]] forKey:@"dep_minute"];
				[newVehicle setValue:[time valueForKey:@"kind"] forKey:@"kind"];
				[newVehicle setValue:[time valueForKey:@"destination"] forKey:@"destination"];
				
#ifdef Log
				 NSLog(@"hour :%@",[newTime valueForKey:@"dep_hour"]);
				 NSLog(@"minute :%@",[newTime valueForKey:@"dep_minute"]);
				 NSLog(@"kind :%@",[newVehicle valueForKey:@"kind"]);
				 NSLog(@"destination :%@",[newVehicle valueForKey:@"destination"]);
#endif
			}
			
		}
		
	}

	
	
	[managedObjectContext save:&error];
	[self performSelectorOnMainThread:@selector(saveEnded) withObject:nil waitUntilDone:NO];

	[pool release];
}



- (IBAction)segmentAction:(id)sender {

	if (selectedSeg){
		return;
	}
	
	selectedSeg = YES;

	secNo = 0;
	inDiv = NO;
	divCount = 0;
	sectionDatas = nil;
	cellData = nil;
	typeDetect = NO;
	
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	selectDaytype = segmentedControl.selectedSegmentIndex;
	
#ifndef Lump
	_parserContext = htmlCreatePushParserCtxt(&gSAXHandler, self, NULL, 0, nil, XML_CHAR_ENCODING_NONE);
	_currentCharacters = nil;
#endif
    
	NSRange range;
	range = [ekitanUrl rangeOfString:@"_"];	
	NSRange topRenge;
	topRenge = NSMakeRange(1, range.location);
	NSString *filenameTop;
	filenameTop = [ekitanUrl substringWithRange:topRenge];
	NSRange dirRenge;
	dirRenge = NSMakeRange(range.location+1,2);
	NSString *filenameDir;
	filenameDir = [ekitanUrl substringWithRange:dirRenge];
	
#ifdef Log
	NSLog(@"filename_top :%@",filenameTop);
	NSLog(@"filename_dir :%@",filenameDir);
#endif
    
	if (selectDaytype == kDaytypeWeekday) {
#ifdef Log
		NSLog(@"Weekday");
#endif
		NSMutableString *ekitanBase = [[NSMutableString alloc] init];
					  
		[ekitanBase setString:@"http://timetable.ekitan.com/train/TimeStation/"];
		[ekitanBase appendString:filenameTop];
		[ekitanBase appendString:@"_"];
		[ekitanBase appendString:filenameDir];
		[ekitanBase appendString:@"_DW0"];
		[ekitanBase appendString:@".shtml"];
			
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ekitanBase]];

		[req setHTTPMethod:@"GET"];
		
		if (!weekdayDone) {
			weekdayUrl = [[NSString alloc] initWithString:ekitanBase];	
#ifdef Log
			NSLog(@"URL :%@",weekdayUrl);
#endif
			self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
			[self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];			
		}
		else {
			daytypeValue = selectDaytype;
			[self.tableView reloadData];
//			[self.timesTable reloadData];
			selected = NO;
			selectedSeg = NO;			
		}
		[ekitanBase release];
	}
	else if (selectDaytype == kDaytypeSaturday) {
#ifdef Log
		NSLog(@"Saturday");
#endif
		NSMutableString *ekitanBase = [[NSMutableString alloc] init];
		
		[ekitanBase setString:@"http://timetable.ekitan.com/train/TimeStation/"];
		[ekitanBase appendString:filenameTop];
		[ekitanBase appendString:filenameDir];
		[ekitanBase appendString:@"_DW1"];
		[ekitanBase appendString:@".shtml"];
				
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ekitanBase]];
	
		[req setHTTPMethod:@"GET"];
		
		if (!saturdayDone) {
			saturdayUrl = [[NSString alloc] initWithString:ekitanBase];
#ifdef Log
			NSLog(@"URL :%@",saturdayUrl);
#endif
			self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
			[self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:YES];
		}
		else {
			daytypeValue = selectDaytype; //セグメントで選択した曜日を非表示用の曜日に
			[self.tableView reloadData];
//			[self.timesTable reloadData];
			selected = NO;
			selectedSeg = NO;			
		}
		[ekitanBase release];	
	}
	else if (selectDaytype == kDaytypeHolyday) {
#ifdef Log
		NSLog(@"Holyday");
#endif
		NSMutableString *ekitanBase = [[NSMutableString alloc] init];
		
		[ekitanBase setString:@"http://timetable.ekitan.com/train/TimeStation/"];
		[ekitanBase appendString:filenameTop];
		[ekitanBase appendString:filenameDir];
		[ekitanBase appendString:@"_DW2"];
		[ekitanBase appendString:@".shtml"];
		
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ekitanBase]];

		[req setHTTPMethod:@"GET"];

		if (!holydayDone) {
			holydayUrl = [[NSString alloc] initWithString:ekitanBase];	
#ifdef Log
			NSLog(@"URL :%@",holydayUrl);
#endif
			self.urlConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
			[self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:YES];
		}
		else {
			daytypeValue = selectDaytype;
			[self.tableView reloadData];
//			[self.timesTable reloadData];
			selected = NO;
			selectedSeg = NO;			
		}
		[ekitanBase release];
	}

}


#pragma mark Connection Handle methods


//通信ハンドル部分

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	

    [recieveData release]; recieveData = nil;
	recieveData = [[NSMutableData data] retain];

    //	self.recieveData = [NSMutableData data];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
#ifndef Lump
	htmlParseChunk(_parserContext, (const char*)[data bytes], [data length], 0);
#endif

    [recieveData appendData:data];

//	[self.recieveData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
//	NSLog(@"Error!!");
	
#ifndef Lump
	htmlParseChunk(_parserContext, NULL, 0, YES);
	
	if (_parserContext) {
		htmlFreeParserCtxt(_parserContext), _parserContext = NULL;
		selected = NO;
		selectedSeg = NO;
	}
#endif
    
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];

	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"No Internet Connection...",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Failed",nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	
//	NSLog(@"Connection did fail with error: %@",[error localizedDescription]);
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

	if (nextEkitanType == kEkitanTimeTable) {
		
		if (selectDaytype == kDaytypeWeekday) {
#ifdef Log
			NSLog(@"Weekday");
#endif
            
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
		
		if (selectDaytype == kDaytypeSaturday) {
#ifdef Log
			NSLog(@"Saturday");
#endif
            
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
		
		if (selectDaytype == kDaytypeHolyday) {
#ifdef Log
			NSLog(@"Holyday");
#endif
			
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
	
#ifdef Log
	NSLog(@"Finish!!");
#endif
    
	
	daytypeValue = selectDaytype;
	[self.tableView reloadData];
//	[self.timesTable reloadData];
	
	selected = NO;
	selectedSeg = NO;

	
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
#ifdef Log
				NSLog(@"keyword: %@",key);
#endif
				
				NSRange delcharRange;
				NSString *delchar;
				for (delchar in deleteKeyword) {
					delcharRange = [key rangeOfString:delchar];
					[key deleteCharactersInRange:delcharRange];
				}
				
				delcharRange = [key rangeOfString:@","];
				NSRange delstationRange = NSMakeRange(0, delcharRange.location+1);
				[key deleteCharactersInRange:delstationRange];

#ifdef Log
				NSLog(@"keyword deleted: %@",key);
#endif
				[key release];
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
#ifdef Log
				NSLog(@"Day: %d",daytypeValue);
#endif
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
					sfcode = key;
//					[key release];
#ifdef Log
					NSLog(@"sfcode: %@",sfcode);
#endif
					isFeed = NO;
				}
				if (isFeed2 == YES) {
					NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+5] encoding:NSUTF8StringEncoding];
					stationValue = key;
//					[key release];
#ifdef Log
					NSLog(@"stationValue: %@",stationValue);
#endif
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
#ifdef Log
						NSLog(@"Selected: !!!!!");
#endif
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
#ifdef Log
				NSLog(@"<%s>\n",name);
#endif
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
						
#ifdef Log
						NSLog(@"[行き先：%@]\n",[cellData objectForKey:@"destination"]);
						NSLog(@"[種別：%@]\n",[cellData objectForKey:@"kind"]);
#endif
						
					}
					
					if (strncmp((const char *)attributes[attIndex], "lgkd", sizeof("lgkd")) == 0 && !attIndex) {
						isFeed = YES;
					}
					
					if (isFeed == YES) {
						cellData = [[NSMutableDictionary alloc] init];
						NSString *key = [[NSString alloc] initWithCString:(char*)attributes[attIndex+1] encoding:NSUTF8StringEncoding];
#ifdef Log
                        NSLog(@"<<kind>>[%@]",key);
#endif
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
#ifdef Log
				NSLog(@"------0 エラー画面---------\n\n");
#endif
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"駅名選択",nil)]) {
				nextEkitanType = kEkitanEkiSelect;
#ifdef Log
				NSLog(@"------1 駅名選択!!!---------\n\n");
#endif
				sectionDatas = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"路線・方面選択",nil)]) {
				nextEkitanType = kEkitanRosenSelect;
#ifdef Log
				NSLog(@"------2 路線選択!!!---------\n\n");
#endif
				allDatas = [[NSMutableDictionary alloc] init];
				keyTitles = [[NSMutableArray alloc] init];
			}
			if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻表検索結果",nil)]) {
				nextEkitanType = kEkitanTimeTable;
#ifdef Log
				NSLog(@"------3 時刻表!!!---------\n\n");
#endif
				
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
#ifdef Log
					NSLog(@"%@",_currentCharacters);
#endif
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
				
				[cellData setObject:_currentCharacters forKey:@"dep_minute"];
				[cellData setObject:rosenValue forKey:@"dep_hour"];
				
#ifdef Log
                NSLog(@"[Mint: %@]-------\n",[[sectionDatas lastObject] objectForKey:@"dep_minute"]);
				NSLog(@"</%s>\n",name);
#endif
                if (sectionDatas != nil && cellData != nil) {
                    [sectionDatas addObject:cellData];
                }
                else {
                    NSLog(@"sectionDatas Nil!!!");
                }
				[cellData release];
				cellData = nil;
				
#ifdef Log
                NSLog(@"[Mint: %@]-------\n",[[sectionDatas lastObject] objectForKey:@"dep_minute"]);
				NSLog(@"</%s>\n",name);
#endif
				
			}
			//時
			if (strncmp((const char *) name, "th", sizeof("th")) == 0) {
				if ([_currentCharacters isEqualToString:NSLocalizedString(@"時刻",nil)]) {
#ifdef Log
					NSLog(@"[Hour: はじまっちゃいます]===============\n");
#endif
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
#ifdef Log
                        NSLog(@"[Hour: %@]============\n",[[sectionDatas lastObject] objectForKey:@"dep_hour"]);
#endif
						secNo += 1;
						
						[sectionDatas release];
						sectionDatas = nil;
					}
					
					sectionDatas = [[NSMutableArray alloc] init];
					rosenValue = [[NSMutableString alloc] initWithString:_currentCharacters];
				}
				
#ifdef Log
				NSLog(@"</%s>\n",name);
#endif
				
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




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

#ifdef Log
    NSLog(@"numOfSec");
    NSLog(@"numOfSec::%d",[keys count]);
#endif
    
	if (viewEkitanType == kEkitanEkiSelect) {
		return 1;
	}
	else if (viewEkitanType == kEkitanRosenSelect) {
		return [keys count];
	}
	else if (viewEkitanType == kEkitanTimeTable) {
		if (daytypeValue == kDaytypeWeekday) {
#ifdef Log
			NSLog(@"numOfSec::%d",[weekdayKeys count]);
#endif
			return [weekdayKeys count];
		}
		else if (daytypeValue == kDaytypeSaturday) {
#ifdef Log
			NSLog(@"numOfSec::%d",[saturdayKeys count]);
#endif
			return [saturdayKeys count];
		}
		else if (daytypeValue == kDaytypeHolyday) {
#ifdef Log
			NSLog(@"numOfSec::%d",[holydayKeys count]);
#endif
			return [holydayKeys count];
		}
		else {			
#ifdef Log
			NSLog(@"numOfSec::%d",[keys count]);
#endif
			return [keys count];
		}
	}
	return 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

#ifdef Log
	NSLog(@"numOfRowInSec");
	NSLog(@"numOfRowInSec::%d",[[tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
    
	if (viewEkitanType == kEkitanEkiSelect) {
		return [tableSectionDatas count];
	}
	else if (viewEkitanType == kEkitanRosenSelect) {

		NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
		NSInteger ret = [[tableAllDatas valueForKey:key_str] count];
		[key_str release];
		return ret;	
		
//		return [[tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count];	
	}
	else if (viewEkitanType == kEkitanTimeTable) {
		if (daytypeValue == kDaytypeWeekday) {

			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			NSInteger ret = [[weekdayAllDatas valueForKey:key_str] count];
			[key_str release];
			return ret;	
			
#ifdef Log
			NSLog(@"numOfRowInSec::%d",[[weekdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
//			return [[weekdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			NSInteger ret = [[saturdayAllDatas valueForKey:key_str] count];
			[key_str release];
			return ret;	
			
#ifdef Log
			NSLog(@"numOfRowInSec::%d",[[saturdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
//			return [[saturdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			NSInteger ret = [[holydayAllDatas valueForKey:key_str] count];
			[key_str release];
			return ret;	
			
#ifdef Log
			NSLog(@"numOfRowInSec::%d",[[holydayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
//			return [[holydayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count];
		}
		else {
			
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			NSInteger ret = [[tableAllDatas valueForKey:key_str] count];
			[key_str release];
			return ret;	
			
#ifdef Log
			NSLog(@"numOfRowInSec::%d",[[tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count]);
#endif
//			return [[tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]] count];
		}
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//	NSLog(@"cellFor");
	
    NSInteger section = [indexPath section];
	NSInteger row = [indexPath row];
	static NSString *timeCellIdentifier = @"ekitime";
	
	timeCellDisp = (TimeCell*)[tableView dequeueReusableCellWithIdentifier:timeCellIdentifier];
	if (timeCellDisp == nil) {
		timeCellDisp = [[[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellIdentifier] autorelease];
		timeCellDisp.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	
	if (viewEkitanType == kEkitanTimeTable) {


		//テーブル表示は曜日ごとのデータ切り替えをする必要がある
		if (daytypeValue == kDaytypeWeekday) {

			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			tableSectionDatas = [weekdayAllDatas objectForKey:key_str];
			[key_str release];
			
/*			
			tableSectionDatas = [weekdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
			tableCellData = [tableSectionDatas objectAtIndex:row];
			NSString *hour = [tableCellData valueForKey:@"dep_hour"];
			NSString *minute = [tableCellData valueForKey:@"dep_minute"];
			NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
			cell.textLabel.text = time;
			cell.detailTextLabel.text = [tableCellData valueForKey:@"kind"];
	//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
*/
		}
		else if (daytypeValue == kDaytypeSaturday) {

			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			tableSectionDatas = [saturdayAllDatas objectForKey:key_str];
			[key_str release];
			
/*			
			tableSectionDatas = [saturdayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
			tableCellData = [tableSectionDatas objectAtIndex:row];
			NSString *hour = [tableCellData valueForKey:@"dep_hour"];
			NSString *minute = [tableCellData valueForKey:@"dep_minute"];
			NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
			cell.textLabel.text = time;
			cell.detailTextLabel.text = [tableCellData valueForKey:@"kind"];
	//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
*/
		}
		else if (daytypeValue == kDaytypeHolyday) {

			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			tableSectionDatas = [holydayAllDatas objectForKey:key_str];
			[key_str release];
			
/*
			tableSectionDatas = [holydayAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
			tableCellData = [tableSectionDatas objectAtIndex:row];
			NSString *hour = [tableCellData valueForKey:@"dep_hour"];
			NSString *minute = [tableCellData valueForKey:@"dep_minute"];
			NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
			cell.textLabel.text = time;
			cell.detailTextLabel.text = [tableCellData valueForKey:@"kind"];
	//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 */
		}
		else {

			
			NSString *key_str = [[NSString alloc] initWithFormat:@"%d",section];
			tableSectionDatas = [tableAllDatas objectForKey:key_str];
			[key_str release];
			
			
/*			
			tableSectionDatas = [tableAllDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
			tableCellData = [tableSectionDatas objectAtIndex:row];
			NSString *hour = [tableCellData valueForKey:@"dep_hour"];
			NSString *minute = [tableCellData valueForKey:@"dep_minute"];
			NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
			cell.textLabel.text = time;
			cell.detailTextLabel.text = [tableCellData valueForKey:@"kind"];
	//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 */
		}
		
		
		
		/*
		NSString *hour = [self.tableCellData valueForKey:@"dep_hour"];
		NSString *minute = [self.tableCellData valueForKey:@"dep_minute"];
		NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
		*/
		
		tableCellData = [self.tableSectionDatas objectAtIndex:row];

		NSInteger hour = [[tableCellData valueForKey:@"dep_hour"] integerValue];
		NSInteger minute = [[tableCellData valueForKey:@"dep_minute"] integerValue];
		NSString *time = [[NSString alloc] initWithFormat:@"%d:%02d",hour,minute];
		
		

		NSString *kind = [tableCellData objectForKey:@"kind"];
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
		timeCellDisp.destinationLabel = [tableCellData objectForKey:@"destination"];
		
		[time release];
		[timeCellDisp setNeedsDisplay];
		
		
		/*
		
		UIView *cellView = [timeCell viewWithTag:99];
		NSString *kind = [tableCellData objectForKey:@"kind"];
		if ([kind isEqualToString:NSLocalizedString(@"普通",nil)] | [kind isEqualToString:NSLocalizedString(@"各駅停車",nil)] | [kind isEqualToString:@""]) {
			[cellView setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			UILabel *label;
			label = (UILabel *)[timeCell viewWithTag:1];
			[label setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			label.text = time;
			
			label = (UILabel *)[timeCell viewWithTag:2];
			[label setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			label.text = kind;
//			label.text = [tableCellData objectForKey:@"kind"];
			
			label = (UILabel *)[timeCell viewWithTag:3];
			[label setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			label.text = [tableCellData objectForKey:@"destination"];
		}
		else {
			[cellView setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.6f alpha:1.0f]];
//			[cellView setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
			UILabel *label;
			label = (UILabel *)[timeCell viewWithTag:1];
			[label setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.6f alpha:1.0f]];
			label.text = time;
			
			label = (UILabel *)[timeCell viewWithTag:2];
			[label setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.6f alpha:1.0f]];
			label.text = kind;
//			label.text = [tableCellData objectForKey:@"kind"];
			
			label = (UILabel *)[timeCell viewWithTag:3];
			[label setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.6f alpha:1.0f]];
			label.text = [tableCellData objectForKey:@"destination"];
		}		 
		*/
		
	}
	return timeCellDisp;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	NSLog(@"secName:%@",[keys objectAtIndex:section]);
	
	if (viewEkitanType == kEkitanTimeTable) {
		if (daytypeValue == kDaytypeWeekday) {
			NSString *ret = [[[NSString alloc] initWithFormat:NSLocalizedString(@"平日 %@ 時",nil),[weekdayKeys objectAtIndex:section]] autorelease];
			return ret;
//			return [NSString stringWithFormat:@"平日 %@ 時",[weekdayKeys objectAtIndex:section]];
		}
		else if (daytypeValue == kDaytypeSaturday) {
			NSString *ret = [[[NSString alloc] initWithFormat:NSLocalizedString(@"土曜 %@ 時",nil),[saturdayKeys objectAtIndex:section]] autorelease];
			return ret;
//			return [NSString stringWithFormat:@"土曜 %@ 時",[saturdayKeys objectAtIndex:section]];
		}
		else if (daytypeValue == kDaytypeHolyday) {
			NSString *ret = [[[NSString alloc] initWithFormat:NSLocalizedString(@"休日 %@ 時",nil),[holydayKeys objectAtIndex:section]] autorelease];
			return ret;
		}
		else {			
			NSString *ret = [[[NSString alloc] initWithFormat:NSLocalizedString(@"%@ 時",nil),[keys objectAtIndex:section]] autorelease];
			return ret;
//			return [NSString stringWithFormat:@"%@ 時",[keys objectAtIndex:section]];
		}
	}
	else {
		return [keys objectAtIndex:section];		
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (selected){
		return;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	selected = NO;
	return;	
	
}


- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
		if (daytypeValue == kDaytypeWeekday) {
			return weekdayKeys;
		}
		else if (daytypeValue == kDaytypeSaturday) {
			return saturdayKeys;
		}
		else if (daytypeValue == kDaytypeHolyday) {
			return holydayKeys;
		}
		else {			
			return keys;
		}	
}


//カスタムセルの高さ設定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCustomCellHeight;
}



- (void)dealloc {

	[backlay release];
	[overlay release];
	[urlValue release];
	
	[urlConnection release];

	[toEkitan release];
	
	[deleteKeyword release];
	
	[weekdayUrl release];
	[saturdayUrl release];
	[holydayUrl release];
 
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


/*

 if (daytypeValue == kDaytypeWeekday) {
 }
 else if (daytypeValue == kDaytypeSaturday) {
 }
 else if (daytypeValue == kDaytypeHolyday) {
 }
 else {			
 }
 
*/
