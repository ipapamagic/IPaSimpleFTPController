//
//  IPaSimpleFTPCreateFolderControl.h

//
//  Created by IPaPa on 12/6/9.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"
#import "IPaSimpleFTPStreamControlDefine.h"
@interface IPaSimpleFTPCreateFolderControl : IPaSimpleFTPStreamControl
-(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete;
@end
