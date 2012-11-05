//
//  IPaSimpleFTPController.m

//
//  Created by IPaPa on 12/6/4.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPController.h"
//#import "IPaNetworkState.h"
IPaSimpleFTPController *defaultIPaSimpleFTPController;
@interface IPaSimpleFTPController ()

+(IPaSimpleFTPController*)defaultController;
@end
@implementation IPaSimpleFTPController
{
//    IPaSimpleFTPStreamControl *streamControl;
    //working streams list
    NSMutableArray *queueStreams;
}
-(id)init
{
    self  = [super init];
    queueStreams = [NSMutableArray array];
    return self;
}
+(IPaSimpleFTPController*)defaultController
{
    if (defaultIPaSimpleFTPController == nil) {
        defaultIPaSimpleFTPController = [[IPaSimpleFTPController alloc] init];
    }
    return defaultIPaSimpleFTPController;
}

//+(void)stop
//{
//    [[IPaSimpleFTPController defaultController] stop];
//}
//-(void)stop
//{
//    if (streamControl) {
//        [streamControl stop];
//        streamControl = nil;
//    }
//}


+(void)checkFileExist:(NSURL*)fileURL callback:(void (^)(BOOL))callback
{
    [IPaSimpleFTPController getInfoForURL:fileURL withInfoKeyList:[NSArray arrayWithObject:(id)kCFStreamPropertyFTPResourceSize]
                                completes:^(NSDictionary *infoList){
                                    if ([infoList objectForKey:(id)kCFStreamPropertyFTPResourceSize] == 0) {
                                        //檔案不存在
                                        callback(NO);
                                    }
                                    else {
                                        callback(YES);
                                    }
                                }fail:nil];
}
#pragma mark - Put Data Control
-(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete
{
//    [self stop];
    IPaSimpleFTPPutDataControl *putControl = [[IPaSimpleFTPPutDataControl alloc] init];
    [queueStreams addObject:putControl];
    

    [putControl putData:data toURL:URL complete:^(IPaSimpleFTPPutDataControlResultCode resultCode){
        [queueStreams removeObject:putControl];
        complete(resultCode);
    }];
}
+(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete
{
    [[IPaSimpleFTPController defaultController] putData:data toURL:URL complete:complete];
}
#pragma mark - Create Folder control
-(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete
{
//    [self stop];
    IPaSimpleFTPCreateFolderControl *createFolderControl = [[IPaSimpleFTPCreateFolderControl alloc] init];
    [queueStreams addObject:createFolderControl];
//    streamControl = createFolderControl;
    [createFolderControl createFolderWithURL:URL complete:^(IPaSimpleFTPCreateFolderControlResultCode result){
        complete(result);
        [queueStreams removeObject:createFolderControl];
    }];
}
+(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete
{
    [[IPaSimpleFTPController defaultController] createFolderWithURL:URL complete:complete];
}
#pragma mark - getInfo control
-(void)getInfoForURL:(NSURL*)url withInfoKeyList:(NSArray*)infoKeyList
           completes:(void(^)(NSDictionary*))completes
                fail:(void (^)())fail
{

    IPaSimpleFTPGetInfoControl *getInfoControl = [[IPaSimpleFTPGetInfoControl alloc] init];
    [queueStreams addObject:getInfoControl];

    [getInfoControl getInfoFromURL:url WithKeyList:infoKeyList completes:^(NSDictionary* dict){
        completes(dict);
        [queueStreams removeObject:getInfoControl];
    } fail:^(){
        fail();
        [queueStreams removeObject:getInfoControl];        
    }];
    
}
+(void)getInfoForURL:(NSURL*)url withInfoKeyList:(NSArray*)infoKeyList
           completes:(void(^)(NSDictionary*))completes
                fail:(void (^)())fail
{
    [[IPaSimpleFTPController defaultController] getInfoForURL:url withInfoKeyList:infoKeyList completes:completes fail:fail];
}
#pragma mark - download control
-(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete
{
    IPaSimpleFTPDownloadControl *downloadControl = [[IPaSimpleFTPDownloadControl alloc] init];
    [queueStreams addObject:downloadControl];
    
    [downloadControl downloadURL:URL toFilePath:filePath complete:^(IPaSimpleFTPDownloadControlResultCode resultCode){
        [queueStreams removeObject:downloadControl];
        complete(resultCode);
    }];
}
+(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete
{
    [[IPaSimpleFTPController defaultController] downloadURL:URL toFilePath:filePath complete:complete];
}
#pragma mark - delete Control
-(void)DeleteResourceRecursiveForURLArray:(NSArray*)removeList
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail
{

    IPaSimpleFTPDeleteControl *deleteControl = [[IPaSimpleFTPDeleteControl alloc] init];
    [queueStreams addObject:deleteControl];

    [deleteControl DeleteResourceRecursiveForURLArray:removeList deleteQueueComplete:^(){
        deleteQueueComplete();
        [queueStreams removeObject:deleteControl];
    } deleteSucceed:deleteSucceed deleteFail:^(SInt32 code){
        deleteFail(code);
        [queueStreams removeObject:deleteControl];        
    }];
    
}

-(void)DeleteResourceForURL:(NSURL*)url
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail
{
    IPaSimpleFTPDeleteControl *deleteControl = [[IPaSimpleFTPDeleteControl alloc] init];
    [queueStreams addObject:deleteControl];

    [deleteControl DeleteResourceForURL:url deleteQueueComplete:^(){
        deleteQueueComplete();
        [queueStreams removeObject:deleteControl];
    } deleteSucceed:deleteSucceed deleteFail:^(SInt32 code){
        deleteFail(code);
        [queueStreams removeObject:deleteControl];
    }];
}

+(void)DeleteResourceRecursiveForURLArray:(NSArray*)removeList
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail

{
    [[IPaSimpleFTPController defaultController] DeleteResourceRecursiveForURLArray:removeList
                                                               deleteQueueComplete:deleteQueueComplete 
                                                                     deleteSucceed:deleteSucceed 
                                                                        deleteFail:deleteFail];
}
+(void)DeleteResourceForURL:(NSURL*)url
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail
{
    [[IPaSimpleFTPController defaultController] DeleteResourceForURL:url
                                                 deleteQueueComplete:deleteQueueComplete 
                                                       deleteSucceed:deleteSucceed 
                                                          deleteFail:deleteFail];  
}
+(void)DeleteResourceForURLString:(NSString*)urlString
              deleteQueueComplete:(void(^)())deleteQueueComplete
                    deleteSucceed:(void(^)(NSURL*))deleteSucceed
                       deleteFail:(void(^)(SInt32))deleteFail
{
    NSString* urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[IPaSimpleFTPController defaultController] DeleteResourceForURL:[NSURL URLWithString:urlStr]
                                                 deleteQueueComplete:deleteQueueComplete 
                                                       deleteSucceed:deleteSucceed 
                                                          deleteFail:deleteFail];  
}

#pragma mark - List Control
+(void)LoadListForURLString:(NSString*)urlString  getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes
{
    NSString* urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [IPaSimpleFTPController LoadListForURL:[NSURL URLWithString:urlStr] getEntries:getEntries completes:completes];
}

+(void)LoadListForURL:(NSURL*)url  getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes
{

    [[IPaSimpleFTPController defaultController] LoadListForURL:url getEntries:getEntries completes:completes];
     

}



-(void)LoadListForURL:(NSURL*)url  getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes
{

    IPaSimpleFTPListControl *listControl = [[IPaSimpleFTPListControl alloc] init];
    [queueStreams addObject:listControl];

    [listControl LoadListForURL:url getEntries:getEntries completes:^(NSURL*  url){
        completes(url);
        [queueStreams removeObject:listControl];
    }];

 
}






@end
