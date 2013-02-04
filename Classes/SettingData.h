//
//  SettingData.h
//  TT
//
//  Created by Kotatsu RIN on 09/10/28.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TT_Define.h"


@interface SettingData : NSObject {

	NSMutableDictionary *settings;
}

@property (nonatomic, retain) NSMutableDictionary *settings;

+ (id)instance;

@end
