//
//  TTAppDelegate.h
//  TT
//
//  Created by Kotatsu RIN on 09/09/27.
//  Copyright con3 Office 2009. All rights reserved.
//

#import "TopViewController.h"
#import "RootViewController.h"
#import "ReadFileView.h"
#import "SettingViewController.h"
#import "ButtonImages.h"
#import "TT_Define.h"


#define kTop	0
#define kSecond	1
#define kRoot	2
#define kSet	3
#define kRead	4

#define kvehicleTypeOther	0
#define kvehicleTypeTrain	1
#define kvehicleTypeBus		2
#define kvehicleTypeBoat	3


@interface TTAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
	UITabBarController *tabController;
	
	ButtonImages *btn_img;
	
	NSRunLoop *clockRunRoop;
	NSTimer *timerClock;

	//時刻入力画面用分数ボタンのイメージ格納領域
	
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@property (nonatomic, retain) ButtonImages *btn_img;


- (NSString *)applicationDocumentsDirectory;
- (void)freeMemory;

//- (void)setTimer;
//- (void)fireTimer;

@end

