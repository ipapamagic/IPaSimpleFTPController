//
//  IPaSimpleFTPStreamControl.h

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaSimpleFTPStreamControl : NSObject <NSStreamDelegate>
-(void)stop;

//以上是callback，請不要呼叫
-(void)handleOpenCompleted:(NSStream *)aStream;
-(void)handleHasBytesAvailableWithStream:(NSStream *)aStream;
-(void)handleHasSpaceAvailableWithStream:(NSStream *)aStream;
-(void)handleErrorOccurred:(NSStream *)aStream;
-(void)handleEndEncountered:(NSStream *)aStream;
@end
