//
//  IPaSimpleFTPStreamControlDefine.h
//  IPaBrowser
//
//  Created by IPaPa on 12/12/8.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#ifndef IPaBrowser_IPaSimpleFTPStreamControlDefine_h
#define IPaBrowser_IPaSimpleFTPStreamControlDefine_h


typedef enum {
    IPaSimpleFTPCreateFolderControlResultCode_Fail = -1,
    IPaSimpleFTPCreateFolderControlResultCode_FolderExist = 0,
    IPaSimpleFTPCreateFolderControlResultCode_Complete = 1,
    
}IPaSimpleFTPCreateFolderControlResultCode;

typedef enum {
    IPaSimpleFTPPutDataControlResultCode_ErrorOccurred = -2,
    IPaSimpleFTPPutDataControlResultCode_WriteByteError = -1,
    IPaSimpleFTPPutDataControlResultCode_Complete = 1,
}IPaSimpleFTPPutDataControlResultCode;

typedef enum {
    IPaSimpleFTPDownloadControlResultCode_WriteFail = -3,
    IPaSimpleFTPDownloadControlResultCode_ReadFail = -2,
    IPaSimpleFTPDownloadControlResultCode_Fail = -1,
    IPaSimpleFTPDownloadControlResultCode_Complete = 1,
}IPaSimpleFTPDownloadControlResultCode;
#endif
