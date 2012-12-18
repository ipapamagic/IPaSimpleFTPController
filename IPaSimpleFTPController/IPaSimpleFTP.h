//
//  IPaSimpleFTP.h
//  IPaBrowser
//
//  Created by IPaPa on 12/12/7.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaSimpleFTPStreamControlDefine.h"
@interface IPaSimpleFTP : NSObject
//connect to server
-(id)initWithIP:(NSString*)ip withAccount:(NSString*)account withPassword:(NSString*)password withPort:(NSUInteger)port isPassive:(BOOL)isPassive;


//list command
//entries is list of dictionary
// with key:
//{
//    kCFFTPResourceGroup = 482;
//    kCFFTPResourceLink = "/Users/ftp/anonymous";
//    kCFFTPResourceModDate = "2012-12-07 09:58:00 +0000";
//    kCFFTPResourceMode = 493;
//    kCFFTPResourceName = anonymous;
//    kCFFTPResourceOwner = 0;
//    kCFFTPResourceSize = 20;
//    kCFFTPResourceType = 10;
//}

//respource type is as follow
//#define	DT_UNKNOWN	 0
//#define	DT_FIFO		 1
//#define	DT_CHR		 2
//#define	DT_DIR		 4
//#define	DT_BLK		 6
//#define	DT_REG		 8
//#define	DT_LNK		10
//#define	DT_SOCK		12
//#define	DT_WHT		14

-(void)loadListWithCallback:(void (^)(NSArray*))getEntries completes:(void (^)())completes;




//delete command
-(void)DeleteResourceForFileName:(NSString*)fileName
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail;
-(void)DeleteResourceRecursiveForFileNameArray:(NSArray*)removeList
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail;

//get file info

-(void)getInfoForFileName:(NSString*)fileName WithKeyList:(NSArray*)infoList
            completes:(void(^)(NSDictionary*))completes
                 fail:(void (^)())fail;
//create folder
-(void)createFolderWithName:(NSString*)folderName complete:(void (^)(IPaSimpleFTPCreateFolderControlResultCode))complete;

//upload data
//return value is stream control id
-(NSUInteger)putData:(NSData*)data withFileName:(NSString*)fileName complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;


//upload data
//return value is stream control id
-(NSUInteger)putData:(NSData*)data withPathName:(NSString*)pathName complete:(void (^)(IPaSimpleFTPPutDataControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;

//download data
//return value is stream control id
-(NSUInteger)downloadWithPathName:(NSString*)pathName toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;

//download data
//return value is stream control id
-(NSUInteger)downloadWithFileName:(NSString*)fileName toFilePath:(NSString*)filePath complete:(void (^)(IPaSimpleFTPDownloadControlResultCode))complete progressCallback:(void (^)(CGFloat))progressCallback;

//current path, default is @""
@property (nonatomic,copy) NSString *currentFTPPath;
+(void)cancelStreanControlWithID:(NSUInteger)streamControlID;

-(void)gotoDirectory:(NSString*)directoryName;
-(void)backToParentDirectory;
@end
