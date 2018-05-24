//
//  UploadManager.m
//  LAGQiniuUpload
//
//  Created by LAgagggggg on 2018/5/23.
//  Copyright © 2018 notme. All rights reserved.
//

#import "UploadManager.h"
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation UploadManager

+(instancetype)sharedInstance{
    
    static UploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UploadManager alloc]init];
    });
    return manager;
}

-(void)uploadImage:(UIImage *)img WithName:(NSString *)name{
    NSString * uploadToken=[self uploadTokenWithBucket:@"MYBUCKET"
                      AccessKey:@"MYACCESSKEY"
                      SecretKey:@"MYSECRETKEY"];
    NSData * imgData=UIImageJPEGRepresentation(img, 1);
    NSString * url=@"http://upload-z2.qiniu.com";
    NSString * key=name;
    NSDictionary * header=@{
                            @"Authorization":[NSString stringWithFormat:@"UpToken %@",uploadToken],
                            @"Content-Type": @"application/json",
                            @"Host": url,
                            };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:header constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
        [formData appendPartWithFormData:[uploadToken dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
        [formData appendPartWithFormData:imgData name:@"file"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success~~~~~~~~~\n%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed--------\n%@",error);
    }];
}

- (NSString *)imageToBase64:(UIImage *)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return image64;
}

-(NSString *)uploadTokenWithBucket:(NSString *)bucket AccessKey:(NSString *)ak SecretKey:(NSString *)sk{
    NSMutableDictionary *uploadPolicy = [NSMutableDictionary dictionary];
    [uploadPolicy setObject:bucket forKey:@"scope"];
    [uploadPolicy setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]+3600] forKey:@"deadline"];
    //将上传策略序列化成为json格式:
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:uploadPolicy options:NSJSONWritingPrettyPrinted error:nil];//
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    //对json序列化后的上传策略进行URL安全的Base64编码
    NSString * base64Srting=[self safeUrlBase64Encode:jsonData];
    //SecretKey对编码后的上传策略进行HMAC-SHA1加密
    NSData * hmacData=[self HMACSHA1:base64Srting key:sk];//
    NSString * finalSign=[self safeUrlBase64Encode:hmacData];
    //拼接
    NSString * uploadToken=[NSString stringWithFormat:@"%@:%@:%@",ak,finalSign,base64Srting];
    NSLog(@"%@",uploadToken);
    return uploadToken;
}

-(NSString*)safeUrlBase64Encode:(NSData*)data
{
    NSString * base64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSMutableString * safeBase64Str = [[NSMutableString alloc]initWithString:base64Str];
    safeBase64Str = (NSMutableString * )[safeBase64Str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    safeBase64Str = (NSMutableString * )[safeBase64Str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return safeBase64Str;
}

- (NSData *)HMACSHA1:(NSString *)data key:(NSString *)key {
    NSData *datas = [data dataUsingEncoding:NSUTF8StringEncoding];
    size_t dataLength = datas.length;
    NSData *keys = [key dataUsingEncoding:NSUTF8StringEncoding];
    size_t keyLength = keys.length;
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [keys bytes], keyLength, [datas bytes], dataLength, result);
    NSData *hmac = [[NSData alloc] initWithBytes:result length:sizeof(result)];
    return hmac;
}

@end
