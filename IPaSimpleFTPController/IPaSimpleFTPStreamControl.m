//
//  IPaSimpleFTPStreamControl.m

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPStreamControl.h"

@implementation IPaSimpleFTPStreamControl
{
    NSUInteger streamControlID;
}
+(NSMutableDictionary*)streamControlList
{
    static NSMutableDictionary *streamControlList = nil;
    if (streamControlList == nil) {
        streamControlList = [@{} mutableCopy];
    }
    return streamControlList;
}
-(id)init
{
    self = [super init];
    static NSUInteger streamIDCounter = 1;
    
    streamControlID = streamIDCounter++;
    NSMutableDictionary *streamControlList = [IPaSimpleFTPStreamControl streamControlList];
    streamControlList[@(streamControlID)] = self;
    return self;
}


-(id)initWithDelegate:(id <IPaSimpleFTPStreamControlDelegate>) delegate
{
    self = [self init];
 
    
    self.delegate = delegate;
    return self;
}
-(void)destroyStreamControl
{
    NSMutableDictionary *streamControlList = [IPaSimpleFTPStreamControl streamControlList];
    
    [streamControlList removeObjectForKey:@(streamControlID)];
}
-(void)stop
{
    
}
-(NSUInteger)streamControlID
{
    return streamControlID;
}
-(BOOL)isPassiveMode
{
    return [self.delegate isIPaSimpleFTPStreamPassiveMode:self];
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
            if ([self respondsToSelector:@selector(handleOpenCompleted:)]) {
                [self handleOpenCompleted:aStream];
            }

        }   
            break;
        case NSStreamEventHasBytesAvailable: {
            if ([self respondsToSelector:@selector(handleHasBytesAvailableWithStream:)]) {
                [self handleHasBytesAvailableWithStream:aStream];
            }
        }
            break;
        case NSStreamEventHasSpaceAvailable: {
            if ([self respondsToSelector:@selector(handleHasSpaceAvailableWithStream:)]) {
                [self handleHasSpaceAvailableWithStream:aStream];
            }
        }
            break;
        case NSStreamEventErrorOccurred: {
            if ([self respondsToSelector:@selector(handleErrorOccurred:)]) {
                [self handleErrorOccurred:aStream];
            }
        } break;
        case NSStreamEventEndEncountered: {
            if ([self respondsToSelector:@selector(handleEndEncountered:)]) {
                [self handleEndEncountered:aStream];
            }
            // ignore
        } break;
        default: {
            //should never be here
            assert(NO);
        } break;
    }
}

+(void)cancelStreanControlWithID:(NSUInteger)streamControlID
{
    NSMutableDictionary *streamControlList = [self streamControlList];
    IPaSimpleFTPStreamControl *streamCtrl = streamControlList[@(streamControlID)];
    [streamCtrl stop];
    [streamCtrl destroyStreamControl];
    
}
@end
