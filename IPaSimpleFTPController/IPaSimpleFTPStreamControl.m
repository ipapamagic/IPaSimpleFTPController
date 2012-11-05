//
//  IPaSimpleFTPStreamControl.m

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"

@implementation IPaSimpleFTPStreamControl
-(void)stop
{
    
}
-(void)handleOpenCompleted:(NSStream *)aStream
{
    
}
-(void)handleHasBytesAvailableWithStream:(NSStream *)aStream
{
    
}

-(void)handleHasSpaceAvailableWithStream:(NSStream *)aStream
{
    
}
-(void)handleErrorOccurred:(NSStream *)aStream
{
    
}
-(void)handleEndEncountered:(NSStream *)aStream
{
    
}
-(void)dealloc
{
    [self stop];
}
#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{

    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self handleOpenCompleted:aStream];
        }   
            break;
        case NSStreamEventHasBytesAvailable: {
            
            [self handleHasBytesAvailableWithStream:aStream];
        }
            break;
        case NSStreamEventHasSpaceAvailable: {
            [self handleHasSpaceAvailableWithStream:aStream];
        } 
            break;
        case NSStreamEventErrorOccurred: {
            
            [self handleErrorOccurred:aStream];
            [self stop];
        } break;
        case NSStreamEventEndEncountered: {
            NSLog(@"EndEncountered!");
            [self handleEndEncountered:aStream];
            // ignore
        } break;
        default: {
            //should never be here
            assert(NO);
        } break;
    }
}
@end
