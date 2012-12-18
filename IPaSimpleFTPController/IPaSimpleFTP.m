//
//  IPaSimpleFTP.m
//  IPaBrowser
//
//  Created by IPaPa on 12/12/7.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaSimpleFTP.h"
#import "IPaSimpleFTPListControl.h"
#import "IPaSimpleFTPDeleteControl.h"
#import "IPaSimpleFTPGetInfoControl.h"
#import "IPaSimpleFTPCreateFolderControl.h"
#import "IPaSimpleFTPDownloadControl.h"
#import "IPaSimpleFTPPutDataControl.h"

#define FTP_PROTOCOL @"ftp"
@interface IPaSimpleFTP () <IPaSimpleFTPStreamControlDelegate>

@property (nonatomic,readonly) NSURL* currentFTPURL;
@property (nonatomic,readonly) NSURL* currentFTPPathURL;
@end
@implementation IPaSimpleFTP
{
    //ip address
    NSString *ftpIpAddress;
    //port
    NSUInteger ftpPort;
    //account
    NSString* ftpAccount;
    //password
    NSString* ftpPassword;
    //
    BOOL ftpIsPassive;
    
    
    
    
    //main stream control
    IPaSimpleFTPStreamControl *mainStreamControl;
    //get info stream control list


}


-(id)initWithIP:(NSString*)ip withAccount:(NSString*)account withPassword:(NSString*)password withPort:(NSUInteger)port isPassive:(BOOL)isPassive
{
    self = [super init];
    ftpIpAddress = [ip copy];
    ftpPort = port;
    ftpAccount = [account copy];
    ftpPassword = [password copy];
    ftpIsPassive = isPassive;
    
    self.currentFTPPath = @"";

    return self;
}


-(NSURL*)currentFTPURL
{
    if (ftpAccount.length > 0 && ftpPassword.length > 0) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@@%@:%d/",FTP_PROTOCOL,ftpAccount,ftpPassword,ftpIpAddress,ftpPort]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d/",FTP_PROTOCOL,ftpIpAddress,ftpPort]];
}
-(NSURL*)currentFTPPathURL
{
    if (self.currentFTPPath.length == 0) {
        return self.currentFTPURL;
    }
    if (ftpAccount.length > 0 && ftpPassword.length > 0) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@@%@:%d/%@/",FTP_PROTOCOL,ftpAccount,ftpPassword,ftpIpAddress,ftpPort,self.currentFTPPath]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d/%@/",FTP_PROTOCOL,ftpIpAddress,ftpPort,self.currentFTPPath]];
}
-(void)loadListWithCallback:(void (^)(NSArray*))getEntries completes:(void (^)())completes
{
    if (mainStreamControl) {
        [mainStreamControl stop];
    }
    IPaSimpleFTPListControl *streamCtrl = [[IPaSimpleFTPListControl alloc] initWithDelegate:self];
    mainStreamControl = streamCtrl;
    NSLog(@"....%@",self.currentFTPPathURL);
    
    [streamCtrl LoadListForURL:self.currentFTPPathURL getEntries:getEntries completes:^(){
        completes();
        mainStreamControl = nil;
    }];

    
    
    
}

-(void)DeleteResourceForFileName:(NSString*)filename
         deleteQueueComplete:(void(^)())deleteQueueComplete
               deleteSucceed:(void(^)(NSURL*))deleteSucceed
                  deleteFail:(void(^)(SInt32))deleteFail
{
    if (mainStreamControl) {
        [mainStreamControl stop];
    }
    IPaSimpleFTPDeleteControl *streamCtrl = [[IPaSimpleFTPDeleteControl alloc] initWithDelegate:self];
    mainStreamControl = streamCtrl;
    
    NSURL *fileURL = [self.currentFTPURL URLByAppendingPathComponent:filename];
    
    [streamCtrl DeleteResourceForURL:fileURL deleteQueueComplete:^(){
        mainStreamControl = nil;
        deleteQueueComplete();
    }deleteSucceed:deleteSucceed deleteFail:^(SInt32 errorCode){
        mainStreamControl = nil;
        deleteFail(errorCode);
    }];
    

}
-(void)DeleteResourceRecursiveForFileNameArray:(NSArray*)removeList
                       deleteQueueComplete:(void(^)())deleteQueueComplete
                             deleteSucceed:(void(^)(NSURL*))deleteSucceed
                                deleteFail:(void(^)(SInt32))deleteFail
{
    if (mainStreamControl) {
        [mainStreamControl stop];
    }
    IPaSimpleFTPDeleteControl *streamCtrl = [[IPaSimpleFTPDeleteControl alloc] initWithDelegate:self];
    mainStreamControl = streamCtrl;
    
    NSMutableArray *urlList = [@[] mutableCopy];
    NSURL* currentPath = self.currentFTPURL;
    for (NSString *name in removeList) {
        NSURL *fileURL = [currentPath URLByAppendingPathComponent:name];
        
        [urlList addObject:fileURL];
    }
    
    [streamCtrl DeleteResourceRecursiveForURLArray:urlList deleteQueueComplete:^(){
        mainStreamControl = nil;
        deleteQueueComplete();
    }deleteSucceed:deleteSucceed deleteFail:^(SInt32 errorCode){
        mainStreamControl = nil;
        deleteFail(errorCode);
    }];
}
//get info command
-(void)getInfoForFileName:(NSString*)fileName WithKeyList:(NSArray*)infoList
                completes:(void(^)(NSDictionary*))completes
                     fail:(void (^)())fail
{
    IPaSimpleFTPGetInfoControl *streamCtrl = [[IPaSimpleFTPGetInfoControl alloc] initWithDelegate:self];
    NSURL *fileURL = [self.currentFTPURL URLByAppendingPathComponent:fileName];
    
    
    [streamCtrl getInfoFromURL:fileURL WithKeyList:infoList completes:completes fail:fail];
    
}
//create folder command
-(void)createFolderWithName:(NSString*)folderName complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete
{
    if (mainStreamControl) {
        [mainStreamControl stop];
    }
    IPaSimpleFTPCreateFolderControl *streamCtrl = [[IPaSimpleFTPCreateFolderControl alloc] initWithDelegate:self];
    mainStreamControl = streamCtrl;
    
}

//upload data
-(NSUInteger)putData:(NSData*)data withFileName:(NSString*)fileName complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    NSURL *currentURL = self.currentFTPPathURL;
    currentURL = [currentURL URLByAppendingPathComponent:fileName];
    return [self putData:data withFileURL:currentURL complete:complete progressCallback:progressCallback];
}


//upload data
-(NSUInteger)putData:(NSData*)data withPathName:(NSString*)pathName complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    NSURL *currentURL = self.currentFTPURL;
    currentURL = [currentURL URLByAppendingPathComponent:pathName];
    return [self putData:data withFileURL:currentURL complete:complete progressCallback:progressCallback];
}

-(NSUInteger)putData:(NSData*)data withFileURL:(NSURL*)fileURL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    IPaSimpleFTPPutDataControl *streamCtrl = [[IPaSimpleFTPPutDataControl alloc] initWithDelegate:self];
    
    
    [streamCtrl putData:data toURL:fileURL complete:complete progressCallback:progressCallback];
    return streamCtrl.streamControlID;
}

//download data
-(NSUInteger)downloadWithPathName:(NSString*)pathName toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    NSURL *fileURL = [self.currentFTPURL URLByAppendingPathComponent:pathName];
    
    return [self downloadWithURL:fileURL toFilePath:filePath complete:complete progressCallback:progressCallback];
}
//download data
-(NSUInteger)downloadWithFileName:(NSString*)fileName toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback {
    NSURL *fileURL = [self.currentFTPPathURL URLByAppendingPathComponent:fileName];
    
    return [self downloadWithURL:fileURL toFilePath:filePath complete:complete progressCallback:progressCallback];
}
-(NSUInteger)downloadWithURL:(NSURL*)fileURL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback
{
    IPaSimpleFTPDownloadControl *streamCtrl = [[IPaSimpleFTPDownloadControl alloc] initWithDelegate:self];
    
    [streamCtrl downloadURL:fileURL toFilePath:filePath complete:complete progressCallback:progressCallback];
    return streamCtrl.streamControlID;
}

+(void)cancelStreanControlWithID:(NSUInteger)streamControlID
{
    [IPaSimpleFTPStreamControl cancelStreanControlWithID:streamControlID];
}

-(void)gotoDirectory:(NSString*)directoryName
{
    self.currentFTPPath = [self.currentFTPPath stringByAppendingPathComponent:directoryName];
}
-(void)backToParentDirectory;
{
    self.currentFTPPath = [self.currentFTPPath stringByDeletingLastPathComponent];
}

#pragma mark - IPaSimpleFTPStreamControlDelegate
-(BOOL)isIPaSimpleFTPStreamPassiveMode:(IPaSimpleFTPStreamControl*)streamControl
{
    return ftpIsPassive;
}
@end
