//
//  LJXCleanCachesHelper.m
//  clean
//
//  Created by 劳景醒 on 16/11/23.
//  Copyright © 2016年 laojingxing. All rights reserved.
//

#import "LJXCleanCachesHelper.h"
#define FileManager [NSFileManager defaultManager]

@implementation LJXCleanCachesHelper

+ (void)cleanCaches:(void (^)(BOOL))CompleteBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取cache文件目录
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // 获取该路径下的所有文件, 删除的时候，可以直接删除文件夹，计算的时候不能直接计算文件夹的大小
        BOOL isSuccess = NO;
        NSArray *allSubPathArray = [FileManager subpathsAtPath:path];
        for (NSString *subPath in allSubPathArray) {
            NSString *subPathStrigng = [path stringByAppendingPathComponent:subPath];
            if ([FileManager removeItemAtPath:subPathStrigng error:nil]) {
                NSLog(@"成功");
//                isSuccess = YES;
            } else {
                
                // Snapshots 本来就存在的文件夹删除不了,可以回去看一下没用SDWebImage之前的文件夹，caches文件夹里面本来就有Snapshots（快照）
//                NSLog(@"失败");
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getCachesSize:^(NSString *cacheSize) {
                if ([cacheSize floatValue] == 0) {
                    // 本来就没有缓存，那也算成功
                    CompleteBlock(YES);
                } else {
                    CompleteBlock(isSuccess);
                }
            }];
        });
        
    });
}

+ (void)getCachesSize:(void (^)(NSString *))CompleteBlck
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取cache文件目录
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // 获取该路径下的所有文件, 删除的时候，可以直接删除文件夹，计算的时候不能直接计算文件夹的大小, 所以用subpathsAtPath 方法。正好拿不到Snapshots。删除的时候也删除不了这里面的东西，所以刚好对上。
        NSArray *allSubPathArray = [FileManager subpathsAtPath:path];
        long long cachesSize = 0;
        for (NSString *subPath in allSubPathArray) {
            NSString *subPathString = [path stringByAppendingPathComponent:subPath];
            NSDictionary *subCachesDic = [FileManager attributesOfItemAtPath:subPathString error:nil];
            // 得出的结果是B 最后要转成K 再转成 M
            cachesSize += subCachesDic.fileSize;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 转成M， 保留两位小数。注意计算的时候进制是以1000计算，而不是1024。这也是为什么有些手机说是16G的内存，但实际容量只有14G左右。
            double doubleCaches = (double)cachesSize / pow(10, 6);
            // 传回去的是M，可以根据实际情况转换成K，或者G
            CompleteBlck([NSString stringWithFormat:@"%.2f", doubleCaches]);
        });
     
    });
    
}


+ (void)cleanCachesAtPath:(NSString *)path completeBlock:(void(^)(BOOL isSuccess))CompleteBlock
{
    if (![FileManager isExecutableFileAtPath:path]) {
        // 文件夹不存在
//        [[[UIAlertView alloc] initWithTitle:@"文件路径不存在" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        NSLog(@"文件夹不存在");
        CompleteBlock(NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSuccess = NO;
        // 获取指定文件夹下面的所有文件
        NSArray *allSubPathArray = [FileManager subpathsAtPath:path];
        for (NSString *subPath in allSubPathArray) {
            NSString *subPathStrigng = [path stringByAppendingPathComponent:subPath];
            if ([FileManager removeItemAtPath:subPathStrigng error:nil]) {
//                NSLog(@"成功");
                isSuccess = YES;
            } else {
//                NSLog(@"失败");
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getCachesSize:^(NSString *cacheSize) {
                if ([cacheSize floatValue] == 0) {
                    // 本来就没有缓存，那也算成功
                    CompleteBlock(YES);
                } else {
                    CompleteBlock(isSuccess);
                }
            }];
        });
        
    });
}

+ (BOOL)remindCleanCache:(long long)lessThanSize
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue] > lessThanSize ? NO : YES;
}



@end
