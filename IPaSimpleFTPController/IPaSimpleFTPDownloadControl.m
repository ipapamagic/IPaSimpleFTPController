//
//  IPaSimpleFTPDownloadControl.m

//
//  Created by IPaPa on 12/6/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPDownloadControl.h"

@implementation IPaSimpleFTPDownloadControl
{
    NSInputStream *             inputStream;
    NSOutputStream *            outputStream;
    size_t downloadDataSize;
    size_t currentBufferWritten;
    NSURL *currentURL;
    void (^completeCB)(IPaSimpleFTPDownloadControlResultCode);
    void (^progressCB)(CGFloat);
}

-(void)stop
{
    if (inputStream != nil || outputStream != nil) {
        if (inputStream != nil) {
            [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            inputStream.delegate = nil;
            [inputStream close];
            inputStream = nil;
        }
        if (outputStream != nil) {
            [outputStream close];
            outputStream = nil;
        }

    }
    completeCB = nil;
    progressCB = nil;
    currentURL = nil;

}
-(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    [self stop];
    if (complete != nil) {
        completeCB = [complete copy];
    }
    if (progressCallback != nil) {
        progressCB = [progressCallback copy];
    }
    // Open a stream for the file we're going to receive into.
    
    currentURL = [URL copy];    
    
    outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    assert(outputStream != nil);
    
    [outputStream open];
    
    // Open a CFFTPStream for the URL.
    
    CFReadStreamRef ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) URL);
    assert(ftpStream != NULL);
    CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue); // Added: To get file info
    CFReadStreamSetProperty(ftpStream, kCFStreamPropertyFTPUsePassiveMode, (self.isPassiveMode)?kCFBooleanTrue:kCFBooleanFalse);
    
    
    inputStream = (__bridge_transfer NSInputStream *) ftpStream;
    
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
}

-(void)handleOpenCompleted:(NSStream *)aStream
{
    NSNumber *dataSize = [inputStream propertyForKey:(id)kCFStreamPropertyFTPResourceSize];
    
    downloadDataSize = [dataSize longLongValue];
    currentBufferWritten = 0;
    
}
-(void)handleHasBytesAvailableWithStream:(NSStream *)aStream
{
    NSInteger       bytesRead;
    uint8_t         buffer[32768];
        
    // Pull some data off the network.
    
    bytesRead = [inputStream read:buffer maxLength:sizeof(buffer)];
    if (bytesRead == -1) {
        void (^complete)(IPaSimpleFTPDownloadControlResultCode) = completeCB;
        [self stop];
        complete(IPaSimpleFTPDownloadControlResultCode_ReadFail);
        [self destroyStreamControl];
    } else if (bytesRead == 0) {
        void (^complete)(IPaSimpleFTPDownloadControlResultCode) = completeCB;
        [self stop];
        complete(IPaSimpleFTPDownloadControlResultCode_Complete);
        [self destroyStreamControl];
    } else {
        NSInteger   bytesWritten;
        NSInteger   bytesWrittenSoFar;
        
        // Write to the file.
        
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [outputStream write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                void (^complete)(IPaSimpleFTPDownloadControlResultCode) = completeCB;
                [self stop];
                complete(IPaSimpleFTPDownloadControlResultCode_WriteFail);
                [self destroyStreamControl];
                break;
            } else {
                bytesWrittenSoFar += bytesWritten;
                
            }
        } while (bytesWrittenSoFar != bytesRead);
        currentBufferWritten += bytesWrittenSoFar;
        
        
        if (progressCB) {
            progressCB((CGFloat)(currentBufferWritten / (CGFloat)downloadDataSize));
        }
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
