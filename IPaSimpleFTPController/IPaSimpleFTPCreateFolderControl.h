//
//  IPaSimpleFTPCreateFolderControl.h

//
//  Created by IPaPa on 12/6/9.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
typedef enum {
    IPaSimpleFTPCreateFolderControlResultCode_Fail = -1,
    IPaSimpleFTPCreateFolderControlResultCode_FolderExist = 0,
    IPaSimpleFTPCreateFolderControlResultCode_Complete = 1,
    
}IPaSimpleFTPCreateFolderControlResultCode;
@interface IPaSimpleFTPCreateFolderControl : IPaSimpleFTPStreamControl
-(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete;
@end
