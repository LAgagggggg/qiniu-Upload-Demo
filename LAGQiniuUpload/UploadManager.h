//
//  UploadManager.h
//  LAGQiniuUpload
//
//  Created by LAgagggggg on 2018/5/23.
//  Copyright © 2018 notme. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;


@interface UploadManager : NSObject
+(instancetype)sharedInstance;
-(void)uploadImage:(UIImage *)img WithName:(NSString *)name;
@end
