//
//  IPaSimpleFTPDownloadControl.h

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
#import "IPaSimpleFTPStreamControlDefine.h"
@interface IPaSimpleFTPDownloadControl : IPaSimpleFTPStreamControl
//-(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete;

-(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;
@end
