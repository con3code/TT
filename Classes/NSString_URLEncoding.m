//
//  NSString_category.m
//  TT
//
//  Created by Kotatsu RIN on 09/10/19.
//  Copyright 2009 con3 Office. All rights reserved.
//

#import "NSString_URLEncoding.h"


@implementation NSString (URLEncoding)

-(NSString *)stringByURLEncoding:(NSStringEncoding)encoding
{
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@";" ,@"/" ,@"?" ,@":"
							,@"@" ,@"&" ,@"=" ,@"+"
							,@"$" ,@"," ,@"[" ,@"]"
							,@"#" ,@"!" ,@"'" ,@"("
							,@")" ,@"*"
							,nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"%3B" ,@"%2F" ,@"%3F"
							 ,@"%3A" ,@"%40" ,@"%26"
							 ,@"%3D" ,@"%2B" ,@"%24"
							 ,@"%2C" ,@"%5B" ,@"%5D"
							 ,@"%23" ,@"%21" ,@"%27"
							 ,@"%28" ,@"%29" ,@"%2A"
							 ,nil];
	
	NSMutableString *encodedString = [[[self stringByAddingPercentEscapesUsingEncoding:encoding] mutableCopy] autorelease];
	
	for(int i=0; i<[escapeChars count]; i++) {
		[encodedString replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
									   withString:[replaceChars objectAtIndex:i]
										  options:NSLiteralSearch
											range:NSMakeRange(0, [encodedString length])];
	}
	
	return [NSString stringWithString: encodedString];
}

@end
