//
//  IPaSimpleFTPGetInfoControl.m

//
//  Created by IPaPa on 12/6/8.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPGetInfoControl.h"

@implementation IPaSimpleFTPGetInfoControl
{
    NSInputStream *inputStream;
    NSArray* InfoKeyList;
    NSURL* currentURL;
    void (^completeCB)(NSDictionary*);
    void (^failCB)();
}

-(void)getInfoFromURL:(NSURL*)url WithKeyList:(NSArray*)infoList 
            completes:(void(^)(NSDictionary*))completes
                 fail:(void (^)())fail
{
    [self stop];
    if (completes) {
        completeCB = [completes copy];
    }
    if (fail) {
        failCB = [fail copy];
    }
    

    CFReadStreamRef     ftpStream;
    currentURL = [url copy];
    ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue); // Added: To get file info
    inputStream = (__bridge_transfer NSInputStream*)ftpStream;
    inputStream.delegate = self;
    
    InfoKeyList = [NSArray arrayWithArray:infoList];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
}
-(void)stop
{
    if (inputStream) {
        [inputStream close];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        inputStream = nil;

    }
    InfoKeyList = nil;
    currentURL = nil;
}
-(void)handleOpenCompleted:(NSStream *)aStream
{
    NSMutableDictionary *infoList = [NSMutableDictionary dictionaryWithCapacity:[InfoKeyList count]];
    
    for (NSString* key in InfoKeyList) {
        id result = [inputStream propertyForKey:key];
        if (result != nil) {
            [infoList setObject:result forKey:key];
        }
    }

    if (completeCB) {
        void (^complete)(NSDictionary*) = [completeCB copy];
        [self stop];
        complete(infoList);
    }
    else {
        [self stop];
    }

}
-(void)handleEndEncountered:(NSStream *)aStream
{
    NSLog(@"end encounter");
}
-(void)handleErrorOccurred:(NSStream *)aStream
{
    
    CFStreamError   err;
    
    // -streamError does not return a useful error domain value, so we 
    // get the old school CFStreamError and check it.
    
    err = CFReadStreamGetError((__bridge CFReadStreamRef) inputStream );
    if (err.domain == kCFStreamErrorDomainFTP) {
        NSLog(@"%@",[NSString stringWithFormat:@"FTP error %d", (int) err.error]);
    } else {
        NSLog(@"Stream open error!");
    }

    
    if (failCB) {
        void (^fail)() = [failCB copy];
        [self stop];
        fail();
    }
    else {
        [self stop];
    }
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
    //一定得是這邊來的，不然就是有問題
    assert(aStream == inputStream);
    [super stream:aStream handleEvent:eventCode];
}
@end
