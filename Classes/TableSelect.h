//
//  TableSelect.h
//  TT
//
//  Created by Kotatsu RIN on 09/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TT_Define.h"

#define kCustomCellHeight	40

#define kvehicleTypeOther	0
#define kvehicleTypeTrain	1
#define kvehicleTypeBus		2
#define kvehicleTypeBoat	3

@interface NoView : UIView {	
	CGContextRef context;
}
@end

@interface TableSelect : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	NSInteger dochi;	//混合する時刻表をセットする枠（1 or 2）
	id parent;	//呼びだし元
	
	CGContextRef context;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) NSInteger dochi;
@property (nonatomic, retain) id parent;

- (void)cancel:(id)sender;

@end
