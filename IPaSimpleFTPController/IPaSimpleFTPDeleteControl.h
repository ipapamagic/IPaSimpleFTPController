//
//  IPaSimpleFTPDeleteControl.h

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "IPaSimpleFTPListControl.h"


@interface IPaSimpleFTPDeleteControl : IPaSimpleFTPStreamControl

-(void)DeleteResourceForURL:(NSURL*)url 
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail;
-(void)DeleteResourceRecursiveForURLArray:(NSArray*)removeList 
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail;
@end

