//
//  TTAppDelegate.m
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright con3 Office 2009. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TimeInputView.h"


@implementation TTAppDelegate

@synthesize window;
@synthesize tabController;
@synthesize btn_img;
//@synthesize rootView;
//@synthesize topView;
//@synthesize readView;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	btn_img = [[ButtonImages alloc] init];
	
	NSLocale *locale = [NSLocale currentLocale];
	[locale localeIdentifier];

	//デフォルト設定
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//各キー値に対するデフォルト値の設定

	NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInteger:0], @"tableNo", //不変（大きい数字が残る）
							 [NSNumber numberWithInteger:0], @"orderNo", //可変（最大値が減ることもある）
							 @"", @"station", //駅名
							 @"", @"direction", //方面
							 @"", @"vehicleType", //乗り物タイプ
							 @"", @"daytype", //曜日
							 @"", @"line", //路線
							 @"", @"topFirst_name",
							 @"", @"topSecond_name",
							 @"", @"secondFirst_name",
							 @"", @"secondSecond_name",
							 [NSNumber numberWithInteger:0], @"topFirst", //第一画面の第一選択
							 [NSNumber numberWithInteger:0], @"topSecond", //第一画面の第二選択
							 [NSNumber numberWithInteger:0], @"secondFirst", //第二画面の第一選択
							 [NSNumber numberWithInteger:0], @"secondSecond", //第二画面の第二選択
							 [NSNumber numberWithInteger:kRoot], @"lastDisp", //終了時の表示画面
							 nil];

	
	//デフォルト値のセット
	[defaults registerDefaults:setting];
	
	clockRunRoop = nil;
	timerClock = nil;

    
	//ウインドウとタブバー
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tabController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    
	
	//各タブビュー
	TopViewController *topView = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
	UIImage *tabbaricon = [UIImage imageNamed:@"tab_bar_combine2.png"];
	topView.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Set A",nil) image:tabbaricon tag:kTop];

	TopViewController *secondView = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
	tabbaricon = [UIImage imageNamed:@"tab_bar_combine2.png"];
	secondView.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Set B",nil) image:tabbaricon tag:kSecond];

	topView.selectedSide = NSLocalizedString(@"A",nil);
	secondView.selectedSide = NSLocalizedString(@"B",nil);

	RootViewController *rootView = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	tabbaricon = [UIImage imageNamed:@"tab_bar_tables.png"];
	rootView.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Timetables",nil) image:tabbaricon tag:kRoot];
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootView];

	SettingViewController *setView = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	tabbaricon = [UIImage imageNamed:@"tab_bar_setting.png"];
	setView.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings",nil) image:tabbaricon tag:kSet];

	UINavigationController *setNav = [[UINavigationController alloc] initWithRootViewController:setView];

	rootNav.navigationBar.topItem.title = NSLocalizedString(@"Timetable List",nil);
	rootNav.navigationBar.barStyle = UIBarStyleDefault;
	rootNav.navigationBar.tintColor = [UIColor grayColor];

	setNav.navigationBar.topItem.title = NSLocalizedString(@"Settings",nil);
		
	//各ビューへ値渡し（この時点でCoreData生成）
	rootView.managedObjectContext = self.managedObjectContext;
	topView.managedObjectContext = self.managedObjectContext;
	secondView.managedObjectContext = self.managedObjectContext;
	setView.managedObjectContext = self.managedObjectContext;

	tabController.viewControllers = [NSArray arrayWithObjects:topView, secondView, rootNav, setNav, nil];
	tabController.delegate = self;

	NSTimer *timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:topView selector:@selector(updateclock) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSRunLoopCommonModes];
	NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:secondView selector:@selector(updateclock) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
	
	[setNav release];
	[setView release];
	[rootNav release];
	[rootView release];
	[secondView release];
	[topView release];
	
	UIApplication *app = [UIApplication sharedApplication];
	[app setStatusBarStyle:UIStatusBarStyleBlackOpaque]; 
	app.delegate = self;
//	[app setStatusBarStyle:UIStatusBarStyleDefault]; 
//	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

	
	//タブ初期表示選択
	tabController.selectedIndex = [defaults integerForKey:@"lastDisp"];
	
	[window addSubview:[tabController view]];
    [window makeKeyAndVisible];
	
	[NSThread detachNewThreadSelector:@selector(timeButtonImageLoad) toTarget:self withObject:nil];
	
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}



- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {


	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	NSLog(@"Tab Selected!!!");

	if ([tabBarController selectedIndex]  == kTop) {
//		NSLog(@"TOP Tab Selected!!!");
		[defaults setInteger:kTop forKey:@"lastDisp"];
	}
	 
	if ([tabBarController selectedIndex]  == kSecond) {
//		NSLog(@"Second Tab Selected!!!");
		[defaults setInteger:kSecond forKey:@"lastDisp"];	 
	 }
	
	if ([tabBarController selectedIndex]  == kRoot) {
//		NSLog(@"Lists Tab Selected!!!");
		[defaults setInteger:kRoot forKey:@"lastDisp"];
	}
	
	if ([tabBarController selectedIndex]  == kSet) {
//		NSLog(@"Setting Tab Selected!!!");
		[defaults setInteger:kRoot forKey:@"lastDisp"];
	}

}



#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (void)timeButtonImageLoad {

	id pool = [[NSAutoreleasePool alloc] init];

	NSInteger min;
	NSString *img_name_n;
	NSString *img_name_h;
	UIImage *buttonImage_n;
	UIImage *buttonImage_h;
	ButtonImages *bi = [ButtonImages instance];
	bi.loadDone = NO;
	
	bi.weekday_icon = [UIImage imageNamed:@"weekday_icon.png"];
	bi.saturday_icon = [UIImage imageNamed:@"saturday_icon.png"];
	bi.holiday_icon = [UIImage imageNamed:@"holiday_icon.png"];
	bi.everyday_icon = [UIImage imageNamed:@"everyday_icon.png"];

	for (NSInteger j = 0; j < 6; j++) {
		
		for (NSInteger k = 0; k < 10; k++) {
			
			min = (j*10)+k;
			
			img_name_n = [[NSString alloc] initWithFormat:@"TB_n_%02d.png",min];
			img_name_h = [[NSString alloc] initWithFormat:@"TB_h_%02d.png",min];
			
			buttonImage_n = [UIImage imageNamed:img_name_n];
			buttonImage_h = [UIImage imageNamed:img_name_h];
			[bi.buttonImages_n addObject:buttonImage_n];
			[bi.buttonImages_h addObject:buttonImage_h];

			buttonImage_n = nil;
			buttonImage_h = nil;
			[img_name_n release];
			[img_name_h release];
			
		}
	}
	
	bi.arrow_left = [UIImage imageNamed:@"arrow_left.png"];
	bi.arrow_right = [UIImage imageNamed:@"arrow_right.png"];
	bi.copy_icon = [UIImage imageNamed:@"copy_icon.png"];
	bi.copy_icon_h = [UIImage imageNamed:@"copy_icon_h.png"];
		
	bi.loadDone = YES;
	
	[pool release];
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"TT.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

long	*pp;

- (void)freeMemory {
	size_t	i,size,len;

	size = 1024L*1024L*10L;
	if(pp==malloc(size))	// メモリ確保
	{
		len = size >> 2;
		for(i=0; i<len; i++)
			*(pp+i) = 1;	// データ書き込み
	}
	if(pp){
		free(pp);	// すぐに解放してしまう。
	}
}


- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[btn_img release];
	[tabController release];
	[window release];
	[super dealloc];
}


@end

