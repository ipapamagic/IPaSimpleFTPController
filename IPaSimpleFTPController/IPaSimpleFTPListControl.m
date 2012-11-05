//
//  IPaSimpleFTPListControl.m

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSimpleFTPListControl.h"

@implementation IPaSimpleFTPListControl
{
    NSInputStream * inputStream;
    NSMutableData *receiveData;
    void (^getEntriesCB)(NSArray*,NSURL*);
    void (^completesCB)(NSURL*);
}
@synthesize currentURL;
-(void)stop
{
    if (inputStream) {
        [inputStream close];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        inputStream = nil;
        getEntriesCB = nil;
        completesCB = nil;

    }
}
-(void)LoadListForURL:(NSURL*)url getEntries:(void (^)(NSArray*,NSURL*))getEntries completes:(void (^)(NSURL*))completes
{
    [self stop];
    if (getEntries) {
        getEntriesCB = [getEntries copy];
    }
    if (completes) {
        completesCB = [completes copy];
    }

    
    CFReadStreamRef     ftpStream;
    currentURL = [url copy];
    ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    inputStream = (__bridge_transfer NSInputStream*)ftpStream;
    inputStream.delegate = self;
    
    receiveData = [NSMutableData data];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];


}
-(void)handleHasBytesAvailableWithStream:(NSStream *)aStream
{
    NSInteger       bytesRead;
    uint8_t         buffer[32768];
    // Pull some data off the network.
    bytesRead = [inputStream read:buffer maxLength:sizeof(buffer)];
    if (bytesRead == -1) {
        NSLog(@"Network read error");
    } else if (bytesRead == 0) {
        //傳輸完成

        if (completesCB) {
            void (^complete)(NSURL*) = [completesCB copy];
            [self stop];
            complete(currentURL);
        }
        else {
            [self stop];
        }


    } else {
        assert(receiveData != nil);
        
        // Append the data to our listing buffer.
        
        [receiveData appendBytes:buffer length:bytesRead];
        
        // Check the listing buffer for any complete entries and update 
        // the UI if we find any.
        
        NSArray *newEntries = [self parseListData];
        
        if (newEntries.count != 0) {
            if (getEntriesCB) {
                getEntriesCB(newEntries,currentURL);
            }

        }
        
    }
}

-(void)handleHasSpaceAvailableWithStream:(NSStream *)aStream
{
    
    //不應該到這裡
    assert(NO);
}
-(void)handleOpenCompleted:(NSStream *)aStream
{

}
-(void)handleErrorOccurred:(NSStream *)aStream
{
    [self stop];
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
#pragma mark - List Parser
- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
// CFFTPCreateParsedResourceListing always interprets the file name as MacRoman, 
// which is clearly bogus <rdar://problem/7420589>.  This code attempts to fix 
// that by converting the Unicode name back to MacRoman (to get the original bytes; 
// this works because there's a lossless round trip between MacRoman and Unicode) 
// and then reconverting those bytes to Unicode using the encoding provided. 
{
    NSDictionary *  result;
    NSString *      name;
    NSData *        nameData;
    NSString *      newName;
    
    newName = nil;
    
    // Try to get the name, convert it back to MacRoman, and then reconvert it 
    // with the preferred encoding.
    
    name = [entry objectForKey:(id) kCFFTPResourceName];
    if (name != nil) {
        assert([name isKindOfClass:[NSString class]]);
        
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
        }
    }
    
    // If the above failed, just return the entry unmodified.  If it succeeded, 
    // make a copy of the entry and replace the name with the new name that we 
    // calculated.
    
    if (newName == nil) {
        assert(NO);                 // in the debug builds, if this fails, we should investigate why
        result = (NSDictionary *) entry;
    } else {
        NSMutableDictionary *   newEntry;
        
        newEntry = [entry mutableCopy];
        assert(newEntry != nil);
        
        [newEntry setObject:newName forKey:(id) kCFFTPResourceName];
        
        result = newEntry;
    }
    
    return result;
}
-(NSArray*)parseListData
{
    NSMutableArray *    newEntries;
    NSUInteger          offset;
    
    // We accumulate the new entries into an array to avoid a) adding items to the 
    // table one-by-one, and b) repeatedly shuffling the listData buffer around.
    
    newEntries = [NSMutableArray array];
    assert(newEntries != nil);
    
    offset = 0;
    do {
        CFIndex         bytesConsumed;
        CFDictionaryRef thisEntry;
        
        thisEntry = NULL;
        
        assert(offset <= receiveData.length);
        bytesConsumed = CFFTPCreateParsedResourceListing(NULL, &((const uint8_t *) receiveData.bytes)[offset], receiveData.length - offset, &thisEntry);
        if (bytesConsumed > 0) {
            
            // It is possible for CFFTPCreateParsedResourceListing to return a 
            // positive number but not create a parse dictionary.  For example, 
            // if the end of the listing text contains stuff that can't be parsed, 
            // CFFTPCreateParsedResourceListing returns a positive number (to tell 
            // the caller that it has consumed the data), but doesn't create a parse 
            // dictionary (because it couldn't make sense of the data).  So, it's 
            // important that we check for NULL.
            
            if (thisEntry != NULL) {
                NSDictionary *  entryToAdd;
                
                // Try to interpret the name as UTF-8, which makes things work properly 
                // with many UNIX-like systems, including the Mac OS X built-in FTP 
                // server.  If you have some idea what type of text your target system 
                // is going to return, you could tweak this encoding.  For example, 
                // if you know that the target system is running Windows, then 
                // NSWindowsCP1252StringEncoding would be a good choice here.
                // 
                // Alternatively you could let the user choose the encoding up 
                // front, or reencode the listing after they've seen it and decided 
                // it's wrong.
                //
                // Ain't FTP a wonderful protocol!
                
                entryToAdd = [self entryByReencodingNameInEntry:(__bridge NSDictionary *) thisEntry encoding:NSUTF8StringEncoding];
                /*
                 entry format
                 {
                 kCFFTPResourceGroup = 482;
                 kCFFTPResourceLink = "";
                 kCFFTPResourceModDate = "2012-06-01 08:13:00 +0000";
                 kCFFTPResourceMode = 493;
                 kCFFTPResourceName = aaa;
                 kCFFTPResourceOwner = 501;
                 kCFFTPResourceSize = 68;
                 kCFFTPResourceType = 4;
                 }
                 */
                [newEntries addObject:entryToAdd];
            }
            
            // We consume the bytes regardless of whether we get an entry.
            
            offset += bytesConsumed;
        }
        
        if (thisEntry != NULL) {
            CFRelease(thisEntry);
        }
        
        if (bytesConsumed == 0) {
            // We haven't yet got enough data to parse an entry.  Wait for more data 
            // to arrive.
            break;
        } else if (bytesConsumed < 0) {
            // We totally failed to parse the listing.  Fail.
            NSLog(@"We totally failed to parse the listing.  Fail.");
            break;
        }
    } while (YES);
    if (offset != 0) {
        [receiveData replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
    }
    return newEntries;
}
@end
