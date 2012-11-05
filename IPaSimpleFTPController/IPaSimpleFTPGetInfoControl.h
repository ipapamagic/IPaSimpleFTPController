//
//  IPaSimpleFTPGetInfoControl.h

//
//  Created by IPaPa on 12/6/8.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"

@interface IPaSimpleFTPGetInfoControl : IPaSimpleFTPStreamControl
-(void)getInfoFromURL:(NSURL*)url WithKeyList:(NSArray*)infoList 
            completes:(void(^)(NSDictionary*))completes
                 fail:(void (^)())fail;
@end
