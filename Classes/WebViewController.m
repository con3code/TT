//
//  WebViewController.m
//  TT
//
//  Created by Kotatsu RIN on 09/12/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize callparent;
@synthesize url;
@synthesize nowURL;
@synthesize whichSite;

@synthesize managedObjectContext;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	[super loadView];
    
    CGRect screen_frame = [[UIScreen mainScreen] applicationFrame];
    
//    NSLog(@"screen_frame %@", NSStringFromCGRect(screen_frame));

	
	CGRect webRect = CGRectMake(0, 0, 320, screen_frame.size.height-44);
//	CGRect webRect = CGRectMake(0, 0, 320, 416);
	netView = [[UIWebView alloc] initWithFrame:webRect];
	netView.scalesPageToFit = YES;
	netView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	netView.delegate = self;
	[self.view addSubview:netView];
	
	CGRect toolbarRect = CGRectMake(0, screen_frame.size.height-44, 320, 44);
//	CGRect toolbarRect = CGRectMake(0, 416, 320, 44);
	toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
	
	[self toolbarButtonSetting:kReset enable:YES];
	
	[self.view addSubview:toolbar];
	[toolbar release];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	NSURL *nsurl = [[NSURL alloc] initWithString:url];
	NSURLRequest *urlrequest = [[NSURLRequest alloc] initWithURL:nsurl];
	
	[netView loadRequest:urlrequest];
	[urlrequest release];
	[nsurl release];
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		netView.frame = CGRectMake(0, 0, 320, 416);
		netView.bounds = CGRectMake(0, 0, 320, 416);		
		toolbar.frame = CGRectMake(0, 416, 320, 44);
		toolbar.bounds = CGRectMake(0, 0, 320, 44);
	}
	else {
		netView.frame = CGRectMake(0, 0, 480, 256);
		netView.bounds = CGRectMake(0, 0, 480, 256);
		toolbar.frame = CGRectMake(0, 256, 480, 32);		
		toolbar.bounds = CGRectMake(0, 0, 480, 32);		
	}
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark WebView methods



- (void)toolbarButtonSetting:(NSInteger)button enable:(BOOL)yesno {

	UIImage *fix_space_img;
	UIImage *triangle_back;
	UIImage *triangle_forward;
	UIImage *memo_icon;

	switch (button) {
		case kReset:
			space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			fix_space_img = [UIImage imageNamed:@"space.png"];
			fix_space = [[UIBarButtonItem alloc] initWithImage:fix_space_img style:UIBarButtonItemStylePlain target:nil action:nil];

			reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
			stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop)];
			done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:callparent action:@selector(webdone)];
			triangle_back = [UIImage imageNamed:@"triangle_back.png"];
			back = [[UIBarButtonItem alloc] initWithImage:triangle_back style:UIBarButtonItemStylePlain target:self action:@selector(pageBack)];
			triangle_forward = [UIImage imageNamed:@"triangle_forward.png"];
			forward = [[UIBarButtonItem alloc] initWithImage:triangle_forward style:UIBarButtonItemStylePlain target:self action:@selector(pageForward)];
			memo_icon = [UIImage imageNamed:@"memo.png"];
			memo = [[UIBarButtonItem alloc] initWithImage:memo_icon style:UIBarButtonItemStylePlain target:self action:@selector(saveCd)];

//			[memo_icon release];
//			[triangle_forward release];
//			[triangle_back release];
//			[fix_space_img release];

			space.enabled = NO;
			fix_space.enabled = NO;
			back.enabled = NO;
			forward.enabled = NO;
			memo.enabled = NO;

			items = [[NSMutableArray alloc] init];
			
			[items addObject:done];
			[items addObject:space];
			[items addObject:back];
			[items addObject:fix_space];
			[items addObject:reload];
			[items addObject:fix_space];
			[items addObject:forward];
			[items addObject:fix_space];
			[items addObject:fix_space];
			[items addObject:space];
			[items addObject:memo];
			
			[toolbar setItems:items];
			[items release];
			break;
		case kDone:
			if (yesno == YES) {
				done.enabled = YES;
			}
			else {
				done.enabled = NO;
			}			
			break;
		case kBack:
			if (yesno == YES) {
				back.enabled = YES;
			}
			else {
				back.enabled = NO;
			}
			break;
		case kReload:
			if (yesno == YES) {
				stop.enabled = NO;
				reload.enabled = YES;
				items = [[NSMutableArray alloc] init];
				[items addObject:done];
				[items addObject:space];
				[items addObject:back];
				[items addObject:fix_space];
				[items addObject:reload];
				[items addObject:fix_space];
				[items addObject:forward];
				[items addObject:fix_space];
				[items addObject:fix_space];
				[items addObject:space];
				[items addObject:memo];
				
				[toolbar setItems:items];
				[items release];
			}
			else {
				stop.enabled = YES;
				reload.enabled = NO;
				items = [[NSMutableArray alloc] init];
				[items addObject:done];
				[items addObject:space];
				[items addObject:back];
				[items addObject:fix_space];
				[items addObject:reload];
				[items addObject:fix_space];
				[items addObject:forward];
				[items addObject:fix_space];
				[items addObject:fix_space];
				[items addObject:space];
				[items addObject:memo];
				
				[toolbar setItems:items];
				[items release];
			}
			break;
		case kStop:
			if (yesno == YES) {
				reload.enabled = NO;
				stop.enabled = YES;
				items = [[NSMutableArray alloc] init];
				[items addObject:done];
				[items addObject:space];
				[items addObject:back];
				[items addObject:fix_space];
				[items addObject:stop];
				[items addObject:fix_space];
				[items addObject:forward];
				[items addObject:fix_space];
				[items addObject:fix_space];
				[items addObject:space];
				[items addObject:memo];
				
				[toolbar setItems:items];
				[items release];
			}
			else {
				reload.enabled = YES;
				stop.enabled = NO;
				items = [[NSMutableArray alloc] init];
				[items addObject:done];
				[items addObject:space];
				[items addObject:back];
				[items addObject:fix_space];
				[items addObject:stop];
				[items addObject:fix_space];
				[items addObject:forward];
				[items addObject:fix_space];
				[items addObject:fix_space];
				[items addObject:space];
				[items addObject:memo];
				
				[toolbar setItems:items];
				[items release];
			}
			break;
		case kForward:
			if (yesno == YES) {
				forward.enabled = YES;
			}
			else {
				forward.enabled = NO;
			}
			break;
		case kMemo:
			if (yesno == YES) {
				memo.enabled = YES;
			}
			else {
				memo.enabled = NO;
			}
			break;
		default:
			space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			fix_space_img = [UIImage imageNamed:@"space.png"];
			fix_space = [[UIBarButtonItem alloc] initWithImage:fix_space_img style:UIBarButtonItemStylePlain target:nil action:nil];
			
			reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
			stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop)];
			done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:callparent action:@selector(webdone)];
			triangle_back = [UIImage imageNamed:@"triangle_back.png"];
			back = [[UIBarButtonItem alloc] initWithImage:triangle_back style:UIBarButtonItemStylePlain target:self action:@selector(pageBack)];
			triangle_forward = [UIImage imageNamed:@"triangle_forward.png"];
			forward = [[UIBarButtonItem alloc] initWithImage:triangle_forward style:UIBarButtonItemStylePlain target:self action:@selector(pageForward)];
			memo_icon = [UIImage imageNamed:@"memo.png"];
			memo = [[UIBarButtonItem alloc] initWithImage:memo_icon style:UIBarButtonItemStylePlain target:self action:@selector(saveCd)];

//			[memo_icon release];
//			[triangle_forward release];
//			[triangle_back release];
//			[fix_space_img release];
			
			space.enabled = NO;
			fix_space.enabled = NO;
			back.enabled = NO;
			forward.enabled = NO;
			memo.enabled = NO;
			
			items = [[NSMutableArray alloc] init];
			
			[items addObject:done];
			[items addObject:space];
			[items addObject:back];
			[items addObject:fix_space];
			[items addObject:reload];
			[items addObject:fix_space];
			[items addObject:forward];
			[items addObject:fix_space];
			[items addObject:fix_space];
			[items addObject:space];
			[items addObject:memo];			

			[toolbar setItems:items];
			[items release];
			break;
	}
		
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	switch (navigationType) {
		case UIWebViewNavigationTypeLinkClicked:
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


- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	if (webView.loading == YES) {
		[self toolbarButtonSetting:kMemo enable:NO];
	}
	
	[self connectionStarted];
	[self toolbarButtonSetting:kStop enable:YES];	
	[self toolbarButtonSetting:kBack enable:[webView canGoBack]];
	[self toolbarButtonSetting:kForward enable:[webView canGoForward]];
	
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {

	[self connectionEnded];
	[self toolbarButtonSetting:kReload enable:YES];	
	[self toolbarButtonSetting:kBack enable:[webView canGoBack]];
	[self toolbarButtonSetting:kForward enable:[webView canGoForward]];

	NSString *path = [[[webView request] URL] path];
	
	if ([path rangeOfString:@"/train/TimeStation/"].length != 0 & [path rangeOfString:@".shtml"].length != 0) {
		[self toolbarButtonSetting:kMemo enable:YES];
		nowURL = [[webView request] URL];
	}
	else {
		[self toolbarButtonSetting:kMemo enable:NO];		
	}

/*	
	NSLog(@"host: %@",[[[webView request] URL] host]);
	NSLog(@"path: %@",[[[webView request] URL] path]);
	NSLog(@"relative: %@",[[[webView request] URL] relativePath]);
	NSLog(@"query: %@",[[[webView request] URL] query]);
	NSLog(@"parameterString: %@",[[[webView request] URL] parameterString]);
	NSLog(@"absoluteString: %@",[[[webView request] URL] absoluteString]);
*/
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

	[self connectionEnded];
	[self toolbarButtonSetting:kReload enable:YES];
	[self toolbarButtonSetting:kMemo enable:NO];

}

- (void)reload {
	
	[netView reload];
}

- (void)stop {
	
	[self connectionEnded];
	[self toolbarButtonSetting:kReload enable:YES];

}

- (void)pageBack {

	[netView goBack];
}

- (void)pageForward {
	
	[netView goForward];
}


- (void)saveCd {	

	[self toolbarButtonSetting:kMemo enable:NO];		

	ParseEkitan *ekitan2data;
	
	switch (whichSite) {
		case kSiteEkitan:
			ekitan2data = [[ParseEkitan alloc] init];
			ekitan2data.nowURL = self.nowURL;
			ekitan2data.managedObjectContext = self.managedObjectContext;
			ekitan2data.callparent = self;
			[ekitan2data saveData];
			[ekitan2data release];
			break;
		default:
			break;
	}
	
}



- (void)connectionStarted {
//	id pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//	[pool release];
}

- (void)connectionEnded {
//	id pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//	[pool release];
}



- (void)saveDataDone {
	NSString *message = [[NSString alloc] initWithString:NSLocalizedString(@"This Timetable was recorded.",nil)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Done",nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	
}


- (void)dealloc {
	[space release];
	[fix_space release];
	[done release];
	[back release];
	[reload release];
	[stop release];
	[forward release];
	[memo release];
	[netView release];
    [super dealloc];
}


@end
