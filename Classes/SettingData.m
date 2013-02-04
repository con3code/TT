//
//  SettingData.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/28.
//  Copyright 2009. All rights reserved.
//

#import "SettingData.h"


@implementation SettingData

@synthesize settings;

+ (id)instance {
	static SettingData *_instance = nil;
	@synchronized(self) {
		if (!_instance) {
			_instance = [[self alloc] init];
		}
	}
	return _instance;
}

- (void)save {
	NSString *path = [[NSString alloc] initWithFormat:@"%@/Library/Preferences/tt_setting.plist", NSHomeDirectory()];
	[self.settings writeToFile:path atomically:YES];
	[path release];
}

- (void)load {
	NSString *path = [[NSString alloc] initWithFormat:@"%@/Library/Preferences/tt_setting.plist", NSHomeDirectory()];

	if (!self.settings){
		self.settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	}
	else {
//		[settings setDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	}
	
	[path release];
}

@end
