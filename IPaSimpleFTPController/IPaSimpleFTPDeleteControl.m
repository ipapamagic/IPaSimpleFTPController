//
//  IPaSimpleFTPDeleteControl.m

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPDeleteControl.h"
@interface IPaSimpleFTPDeleteControl ()
-(void)DeleteFolderResourceForURL:(NSURL*)url
              deleteQueueComplete:(void(^)())deleteQueueComplete
                    deleteSucceed:(void(^)(NSURL*))deleteSucceed
                       deleteFail:(void(^)(SInt32))deleteFail;
-(void)handleRemovingQueue;
-(BOOL)DeleteURL:(NSURL*)url errorCode:(SInt32*)errorCode;
@property (nonatomic,readonly) NSURL* deletingFolderURL;
@end
@implementation IPaSimpleFTPDeleteControl
{
    IPaSimpleFTPListControl *ListControl;
    IPaSimpleFTPDeleteControl *subFolderDeleteControl;
    NSMutableArray *RemovingQueue;
    
    
    void (^deleteSucceedCB)(NSURL*);
    void (^deleteQueueSucceedCB)();
    void (^deleteFailCB)(SInt32);

}
@synthesize deletingFolderURL = _deletingFolderURL;

-(void)stop
{
    if (ListControl) {
        [ListControl stop];
        ListControl = nil;
    }
    if (subFolderDeleteControl) {
        [subFolderDeleteControl stop];
        subFolderDeleteControl = nil;
    }
    if (RemovingQueue) {
        [RemovingQueue removeAllObjects];
        RemovingQueue = nil;
    }
    deleteQueueSucceedCB = nil;
    deleteSucceedCB = nil;
    deleteFailCB = nil;
    _deletingFolderURL = nil;
}
-(BOOL)DeleteURL:(NSURL*)url errorCode:(SInt32*)errorCode
{

    BOOL ret = CFURLDestroyResource((__bridge CFURLRef)url, errorCode);
    if (ret) {
        if (deleteSucceedCB) {
            deleteSucceedCB(url);
        }
    }
    else {
        if (deleteFailCB) {
            deleteFailCB(*errorCode);
        }

    }
    return ret;
}
-(void)DeleteResourceRecursiveForURLArray:(NSArray*)removeList 
                      deleteQueueComplete:(void(^)())deleteQueueComplete
                            deleteSucceed:(void(^)(NSURL*))deleteSucceed
                               deleteFail:(void(^)(SInt32))deleteFail
{
    if (deleteQueueComplete) {
        deleteQueueSucceedCB = [deleteQueueComplete copy];
    }
    if (deleteSucceed) {
        deleteSucceedCB = [deleteSucceed copy];
    }
    if (deleteFail) {
        deleteFailCB = [deleteFail copy];
    }    
    RemovingQueue = [NSMutableArray array];
    for (NSURL *url in removeList) {
        NSString *urlString = url.absoluteString;
        
        if ([urlString hasSuffix:@"/"]) {
            
            [RemovingQueue insertObject:url atIndex:0];
        }
        else {
            SInt32 errorCode;
            if (![self DeleteURL:url errorCode:&errorCode]) {
                return;
            }
        }
    }

    if (RemovingQueue.count > 0) {
        //有folder需要刪除
        NSURL *url = [RemovingQueue lastObject];
        [RemovingQueue removeLastObject];
        if (subFolderDeleteControl == nil) {
            subFolderDeleteControl = [[IPaSimpleFTPDeleteControl alloc] init];
        }
        [subFolderDeleteControl DeleteFolderResourceForURL:url
                                       deleteQueueComplete:^(NSURL *URL){
                                           [self handleRemovingQueue];
                                       }deleteSucceed:^(NSURL* URL){
                                           deleteSucceedCB(URL);
                                       }deleteFail:^(SInt32 errorCode){
                                           deleteFailCB(errorCode);
                                       }];
    }
}
-(void)DeleteFolderResourceForURL:(NSURL*)url
              deleteQueueComplete:(void(^)())deleteQueueComplete
                    deleteSucceed:(void(^)(NSURL*))deleteSucceed
                       deleteFail:(void(^)(SInt32))deleteFail
{
    [self stop];
    if (deleteQueueComplete) {
        deleteQueueSucceedCB = [deleteQueueComplete copy];
    }
    if (deleteSucceed) {
        deleteSucceedCB = [deleteSucceed copy];
    }
    if (deleteFail) {
        deleteFailCB = [deleteFail copy];
    }   
    if (ListControl == nil) {
        ListControl = [[IPaSimpleFTPListControl alloc] init];

    }
    RemovingQueue = [NSMutableArray array];
    _deletingFolderURL = [url copy];
    [ListControl LoadListForURL:url getEntries:^(NSArray* newEntries,NSURL* URL){
        for (NSDictionary *entry in newEntries) {
            NSNumber *resourceType = [entry objectForKey:(__bridge NSString*)kCFFTPResourceType];
            NSString *urlString = [URL.absoluteString stringByAppendingString:[entry objectForKey:(__bridge NSString*)kCFFTPResourceName]];
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([resourceType integerValue]== 4) {
                urlString = [urlString stringByAppendingString:@"/"];
                
            }
            [RemovingQueue insertObject:[NSURL URLWithString:urlString] atIndex:0];
        }
    }completes:^(NSURL* URL){
        [self handleRemovingQueue];
    }];
}
-(void)DeleteResourceForURL:(NSURL*)url 
        deleteQueueComplete:(void(^)())deleteQueueComplete
              deleteSucceed:(void(^)(NSURL*))deleteSucceed
                 deleteFail:(void(^)(SInt32))deleteFail

{
    [self stop];
 
    NSString *urlString = url.absoluteString;
    
    if ([urlString hasSuffix:@"/"]) {
        //is Folder
        [self DeleteFolderResourceForURL:url 
                     deleteQueueComplete:deleteQueueComplete
                           deleteSucceed:deleteSucceed 
                              deleteFail:deleteFail];
    }
    else {
        if (deleteQueueComplete) {
            deleteQueueSucceedCB = [deleteQueueComplete copy];
        }
        if (deleteSucceed) {
            deleteSucceedCB = [deleteSucceed copy];
        }
        if (deleteFail) {
            deleteFailCB = [deleteFail copy];
        }   
        SInt32 errorCode;    
        [self DeleteURL:url errorCode:&errorCode];

    }
}
-(void)handleRemovingQueue
{
    while (RemovingQueue.count > 0) {
        //有folder需要刪除
        NSURL *url = [RemovingQueue lastObject];
        [RemovingQueue removeLastObject];
        
        if ([url.absoluteString hasSuffix:@"/"]) {
            
            if (subFolderDeleteControl == nil) {
                subFolderDeleteControl = [[IPaSimpleFTPDeleteControl alloc] init];
            }
            [subFolderDeleteControl DeleteFolderResourceForURL:url
                                           deleteQueueComplete:^(NSURL* URL){
                                               [self handleRemovingQueue];
                                           }deleteSucceed:^(NSURL *URL){
                                               if (deleteSucceedCB) {
                                                   deleteSucceedCB(URL);
                                               }
                                           }deleteFail:^(SInt32 errorCode){
                                               if (deleteFailCB) {
                                                   deleteFailCB(errorCode);
                                               }
                                           }];
            //中斷，等folder刪除完成在繼續
            break;
        }
        else {
            SInt32 errorCode;
            if (![self DeleteURL:url errorCode:&errorCode]) {
                [self stop];
                return;                
            }

        }
    }
    if (self.deletingFolderURL) {
        SInt32 errorCode;
        if (![self DeleteURL:self.deletingFolderURL errorCode:&errorCode])
        {
            [self stop];
            return;
        }
         
        
    }
    
    
    if (deleteQueueSucceedCB) {
        void (^succeedCB)() = [deleteQueueSucceedCB copy];
        [self stop];
        succeedCB();
    }
    else {
        [self stop];
    }
    
    
}


@end
