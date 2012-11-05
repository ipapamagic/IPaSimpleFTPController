//
//  IPaSimpleFTPController.h
//
//  Created by IPaPa on 12/6/4.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaSimpleFTPListControl.h"
#import "IPaSimpleFTPDeleteControl.h"
#import "IPaSimpleFTPGetInfoControl.h"
#import "IPaSimpleFTPCreateFolderControl.h"
#import "IPaSimpleFTPDownloadControl.h"
#import "IPaSimpleFTPPutDataControl.h"

@interface IPaSimpleFTPController : NSObject

//ftp list command,url method should be ftp
+(void)LoadListForURL:(NSURL*)url  getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes;
+(void)LoadListForURLString:(NSString*)urlString  getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes;

//ftp delete command ,url method shoud be ftp
+(void)DeleteResourceForURL:(NSURL*)url
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail;
+(void)DeleteResourceForURLString:(NSString*)urlString
              deleteQueueComplete:(void(^)())deleteQueueComplete
                    deleteSucceed:(void(^)(NSURL*))deleteSucceed
                       deleteFail:(void(^)(SInt32))deleteFail;

//batch delete command
+(void)DeleteResourceRecursiveForURLArray:(NSArray*)removeList
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail;

//get file info
+(void)getInfoForURL:(NSURL*)url withInfoKeyList:(NSArray*)infoKeyList
           completes:(void(^)(NSDictionary*))completes
                fail:(void (^)())fail;

//create folder,complete callback的參數1:成功,0:目錄已存在,-1:失敗
+(void)createFolderWithURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete;
//upload file
+(void)putData:(NSData*)data toURL:(NSURL*)URL complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete;
//download file
+(void)downloadURL:(NSURL*)URL toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete;
//
+(void)checkFileExist:(NSURL*)fileURL callback:(void (^)(BOOL))callback;
@end
