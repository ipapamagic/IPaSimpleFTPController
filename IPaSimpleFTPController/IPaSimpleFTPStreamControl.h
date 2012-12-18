//
//  IPaSimpleFTPStreamControl.h

//
//  Created by IPaPa on 12/6/7.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IPaSimpleFTPStreamControlDelegate;
@protocol IPaSimpleFTPStreamControlProtocol <NSObject>
@optional
-(void)handleOpenCompleted:(NSStream *)aStream;
-(void)handleHasBytesAvailableWithStream:(NSStream *)aStream;
-(void)handleHasSpaceAvailableWithStream:(NSStream *)aStream;
-(void)handleErrorOccurred:(NSStream *)aStream;
-(void)handleEndEncountered:(NSStream *)aStream;
@end


@interface IPaSimpleFTPStreamControl : NSObject <NSStreamDelegate,IPaSimpleFTPStreamControlProtocol>

-(id)initWithDelegate:(id <IPaSimpleFTPStreamControlDelegate>) delegate;
-(void)stop;

//we need to call destroyStreamControl to destroy,or it will retain in stream control list
-(void)destroyStreamControl;
@property (nonatomic,readonly) NSUInteger streamControlID;
@property (nonatomic,readonly) BOOL isPassiveMode;
@property (nonatomic,weak) id<IPaSimpleFTPStreamControlDelegate> delegate;
+(void)cancelStreanControlWithID:(NSUInteger)streamControlID;
@end


@protocol IPaSimpleFTPStreamControlDelegate <NSObject>

-(BOOL)isIPaSimpleFTPStreamPassiveMode:(IPaSimpleFTPStreamControl*)streamControl;

@end