//
//  IPaSimpleFTPDownloadControl.h

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
typedef enum {
    IPaSimpleFTPDownloadControlResultCode_WriteFail = -3,
    IPaSimpleFTPDownloadControlResultCode_ReadFail = -2,
    IPaSimpleFTPDownloadControlResultCode_Fail = -1,
    IPaSimpleFTPDownloadControlResultCode_Complete = 1,
}IPaSimpleFTPDownloadControlResultCode;
@interface IPaSimpleFTPDownloadControl : IPaSimpleFTPStreamControl
-(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete;
@end
