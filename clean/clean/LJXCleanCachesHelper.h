//
//  LJXCleanCachesHelper.h
//  clean
//
//  Created by 劳景醒 on 16/11/23.
//  Copyright © 2016年 laojingxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJXCleanCachesHelper : NSObject


/**
    清空缓存
 */
+ (void)cleanCaches:(void(^)(BOOL isSuccess))CompleteBlock;


/**
    计算缓存
 */
+ (void)getCachesSize:(void(^)(NSString *cacheSize))CompleteBlck;


/**
 删除指定文件夹下面的文件
 @param path 指定文件夹
 @param CompleteBlock 完成操作后回调
 */
+ (void)cleanCachesAtPath:(NSString *)path completeBlock:(void(^)(BOOL isSuccess))CompleteBlock;


/**
 
 */

/**
 可用空间少于传进来的值的时候，提醒清除缓存

 @param lessThanSize 可用空间少于这个传
 @return YES提示了，NO不提示
 */
+ (BOOL)remindCleanCache:(long long)lessThanSize;

@end
