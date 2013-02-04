//
//  SettingViewController.h
//  TT
//
//  Created by Kotatsu RIN on 09/12/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadFileView.h"
#import "WebViewController.h"
#import "TT_Define.h"

#define kSiteEkitan 1
#define kSiteYahooJapan 2
#define kSiteDoconavi 3



@interface SettingViewController : UITableViewController <UIWebViewDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)webdone;

@end

@interface OnlineTimetableViewController : UITableViewController {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)webdone;
	
@end
