//
//  IPaSimpleFTPPutDataControl.h

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
typedef enum {
    IPaSimpleFTPPutDataControlResultCode_ErrorOccurred = -2,
    IPaSimpleFTPPutDataControlResultCode_WriteByteError = -1,
    IPaSimpleFTPPutDataControlResultCode_Complete = 1,
}IPaSimpleFTPPutDataControlResultCode;

#define IPaSimpleFTPPutDataControl_Noti_Progress @"IPaSimpleFTPPutDataControl_Noti_Progress"
#define IPaSimpleFTPPutDataControl_NotiKey_URL @"IPaSimpleFTPPutDataControl_NotiKey_URL"
#define IPaSimpleFTPPutDataControl_NotiKey_ProgressValue @"IPaSimpleFTPPutDataControl_NotiKey_ProgressValue"
@interface IPaSimpleFTPPutDataControl : IPaSimpleFTPStreamControl
-(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete;

@end
