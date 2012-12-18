//
//  IPaSimpleFTPPutDataControl.h

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
#import "IPaSimpleFTPStreamControlDefine.h"


@interface IPaSimpleFTPPutDataControl : IPaSimpleFTPStreamControl
//-(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete;


-(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;
@end
