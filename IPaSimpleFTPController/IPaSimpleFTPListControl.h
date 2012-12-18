//
//  IPaSimpleFTPListControl.h

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaSimpleFTPStreamControl.h"
@interface IPaSimpleFTPListControl : IPaSimpleFTPStreamControl 


-(void)LoadListForURL:(NSURL*)url getEntries:(void (^)(NSArray*))getEntries completes:(void (^)())completes;

@end
