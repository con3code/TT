//
//  WebViewController.h
//  TT
//
//  Created by Kotatsu RIN on 09/12/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "NSString_URLEncoding.h"
#import "ParseEkitan.h"
#import "TT_Define.h"

#define kSiteEkitan 1
#define kSiteYahooJapan 2
#define kSiteDoconavi 3

#define kReset 0
#define kDone 1
#define kBack 2
#define kReload 3
#define kStop 4
#define kForward 5
#define kMemo 6

@interface WebViewController : UIViewController <UIWebViewDelegate> {

	id callparent;
	NSString *url;
	UIWebView *netView;
	UIToolbar *toolbar;
	NSMutableArray *items;
	NSURL *nowURL;
	NSInteger whichSite;

	UIBarButtonItem *space;
	UIBarButtonItem *fix_space;
	UIBarButtonItem *done;
	UIBarButtonItem *back;
	UIBarButtonItem *reload;
	UIBarButtonItem *stop;
	UIBarButtonItem *forward;
	UIBarButtonItem *memo;

	
	//coredata
	NSManagedObjectContext	*managedObjectContext;
	
	
}

@property (nonatomic, retain) id callparent;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSURL *nowURL;
@property (nonatomic, assign) NSInteger whichSite;

@property (nonatomic, retain) NSManagedObjectContext	*managedObjectContext;


- (void)saveCd;
- (void)toolbarButtonSetting:(NSInteger)button enable:(BOOL)yesno;
- (void)connectionStarted;
- (void)connectionEnded;

- (void)saveDataDone;


@end
