//
//  IPaSimpleFTPPutDataControl.m

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPPutDataControl.h"


enum {
    kSendBufferSize = 32768
};

@implementation IPaSimpleFTPPutDataControl
{
    NSOutputStream *            outputStream;
    void (^completeCB)(IPaSimpleFTPPutDataControlResultCode);
    void (^progressCB)(CGFloat);
    //回傳上傳百分比的callback

    size_t            bufferOffset;
//    size_t            bufferLimit;
//    uint8_t *         buffer;
    
    NSData *currentData;
    NSURL *currentURL;
}
-(void)stop
{
    if (outputStream != nil) {
        
        if (outputStream != nil) {
            [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            outputStream.delegate = nil;
            [outputStream close];        
            outputStream = nil;
        }
    }
    currentData = nil;
    completeCB = nil;
    progressCB = nil;
    currentURL = nil;
}

-(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    [self stop];
    if (complete != nil) {
        completeCB = [complete copy];
    }
    if (progressCallback != nil) {
        progressCB = [progressCallback copy];
    }
    currentURL = [URL copy];
 
    
    // Open a CFFTPStream for the URL.
    
    CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) URL);
    assert(ftpStream != NULL);
    CFWriteStreamSetProperty(ftpStream, kCFStreamPropertyFTPUsePassiveMode, (self.isPassiveMode)?kCFBooleanTrue:kCFBooleanFalse);
    outputStream = (__bridge_transfer NSOutputStream *) ftpStream;
    
    bufferOffset = 0;
    currentData = [data copy];
    
    outputStream.delegate = self;
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
    
    // Have to release ftpStream to balance out the create.  self.networkStream 
    // has retained this for our persistent use.
    

    
}


#pragma mark - Stream Event

-(void)handleHasSpaceAvailableWithStream:(NSStream *)aStream
{
    // If we don't have any data buffered, go read the next chunk of data.
    
    if (bufferOffset == currentData.length) {
        
        //完成
        void (^complete)(IPaSimpleFTPPutDataControlResultCode) = [completeCB copy];
        [self stop];
        complete(IPaSimpleFTPPutDataControlResultCode_Complete);
        
        [self destroyStreamControl];
        return;
    }
    else  {
        NSInteger   bytesWritten;
        bytesWritten = [outputStream write:&[currentData bytes][bufferOffset] maxLength:currentData.length - bufferOffset];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            void (^complete)(IPaSimpleFTPPutDataControlResultCode) = [completeCB copy];
            [self stop];
            complete(IPaSimpleFTPPutDataControlResultCode_WriteByteError);
            
            [self destroyStreamControl];
        } else {
            bufferOffset += bytesWritten;
            
            
            if (progressCB) {
                progressCB((CGFloat)(bufferOffset / (CGFloat)currentData.length));
            }
        }
    }
}

-(void)handleErrorOccurred:(NSStream *)aStream
{
    
    void (^complete)(IPaSimpleFTPPutDataControlResultCode) = [completeCB copy];
    [self stop];
    complete(IPaSimpleFTPPutDataControlResultCode_ErrorOccurred);
    [self destroyStreamControl];
}
#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
    //一定得是這邊來的，不然就是有問題
    assert(aStream == outputStream);
    [super stream:aStream handleEvent:eventCode];
}
@end
