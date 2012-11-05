//
//  IPaSimpleFTPListControl.h

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaSimpleFTPStreamControl.h"
@interface IPaSimpleFTPListControl : IPaSimpleFTPStreamControl 

@property (nonatomic,readonly) NSURL* currentURL;
-(void)LoadListForURL:(NSURL*)url getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes;

@end
