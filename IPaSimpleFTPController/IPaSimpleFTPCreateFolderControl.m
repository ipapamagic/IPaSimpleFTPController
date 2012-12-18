//
//  IPaSimpleFTPCreateFolderControl.m

//
//  Created by IPaPa on 12/6/9.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPCreateFolderControl.h"
#import "IPaSimpleFTPGetInfoControl.h"

@implementation IPaSimpleFTPCreateFolderControl
{
    void (^completeCB)(IPaSimpleFTPCreateFolderControlResultCode);
    IPaSimpleFTPGetInfoControl *getInfoControl;
    NSOutputStream *outputStream;
}
-(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete
{

    [self stop];
    
    //先檢查folder是否存在
    getInfoControl = [[IPaSimpleFTPGetInfoControl alloc] init];

    
    [getInfoControl getInfoFromURL:URL WithKeyList:@[(id)kCFStreamPropertyFTPResourceSize] 
                         completes:^(NSDictionary *infoList){
                             //有存在Folder
                             //回傳0代表目錄已存在 
                             [self stop];
                             if (complete) {
                                 complete(IPaSimpleFTPCreateFolderControlResultCode_FolderExist);
                             }
                             
                             [self destroyStreamControl];
                             
                         }fail:^(){
                             //其他錯誤
                             

                             
                            //不存在Folder
                                 //建立folder
                             CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) URL);
                             CFWriteStreamSetProperty(ftpStream, kCFStreamPropertyFTPUsePassiveMode, (self.isPassiveMode)?kCFBooleanTrue:kCFBooleanFalse);
                             assert(ftpStream != NULL);
                             outputStream = (__bridge NSOutputStream*)ftpStream;
                             outputStream.delegate = self;
                             [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                             [outputStream open];
                             
                             
                         }];
    
}
-(void) stop
{

    if (outputStream || getInfoControl) {
        getInfoControl = nil;  
        if (outputStream) {

            [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            outputStream.delegate = nil;
            [outputStream close];            
            outputStream = nil;

        }

    }

    
}



-(void)handleOpenCompleted:(NSStream *)aStream
{
    NSLog(@"HandleOpenComplete!");
  //  [self stop];
    //建立完成，回傳1
   // completeCB(1);
}
-(void)handleErrorOccurred:(NSStream *)aStream
{
    CFStreamError   err;
    
    // -streamError does not return a useful error domain value, so we 
    // get the old school CFStreamError and check it.
    
    err = CFWriteStreamGetError( (__bridge CFWriteStreamRef) outputStream );
    if (err.domain == kCFStreamErrorDomainFTP) {
        NSLog(@"%@",[NSString stringWithFormat:@"FTP error %d", (int) err.error]);
    } else {
        NSLog(@"Stream open error!");
    }
   //建立失敗，回傳-1 
    if (completeCB) {
        void (^complete)(NSInteger) = [completeCB copy];
        [self stop];
        complete(IPaSimpleFTPCreateFolderControlResultCode_Fail);
    }
    else {
        [self stop];        
    }


    [self destroyStreamControl];
}
-(void)handleEndEncountered:(NSStream *)aStream
{
    if (completeCB) {
        void (^complete)(NSInteger) = [completeCB copy];
        [self stop];
        complete(IPaSimpleFTPCreateFolderControlResultCode_Complete);
    }
    else {
        [self stop];        
    }
    //建立完成，回傳1
    
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
