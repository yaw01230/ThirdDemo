//
//  LNBaseViewModel.m
//  LookNovel
//
//  Created by wangchengshan on 2019/5/10.
//  Copyright © 2019 wcs Co.,ltd. All rights reserved.
//

#import "LNBaseViewModel.h"
#import "LNReaderViewController.h"

static YYCache *localStorageCache_;

@implementation LNBaseViewModel

- (NSURL *)pathForGroupLocalStorage
{
    NSString *groupID = @"group.com.wcs.lookNovel";
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupID];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/recentBook"];
    return containerURL;
}

- (YYCache *)localStorageCache
{
    if (!localStorageCache_) {
        localStorageCache_ = [YYCache cacheWithPath:documentFilePathWithCompentPath(localStoragePath)];
    }
    return localStorageCache_;
}

- (NSArray<LNRecentBook *> *)getRecentBook
{
    YYCache *cache = [self localStorageCache];
    NSArray *array = (NSArray *)[cache objectForKey:recentBookKey];
    return array;
}

- (void)saveLastRecentBook:(LNRecentBook *)recentBook
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        YYCache *cache = [self localStorageCache];
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:[self getRecentBook]];
        LNRecentBook *oldBook = nil;
        for (LNRecentBook *book in arrayM) {
            if ([book._id isEqualToString:recentBook._id]) {
                oldBook = book;
                break;
            }
        }
        if (oldBook) {
            [arrayM removeObject:oldBook];
            [arrayM addObject:recentBook];
        }
        else{
            [arrayM addObject:recentBook];
        }
        
        [cache setObject:[arrayM copy] forKey:recentBookKey];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayM];
        BOOL res = [data writeToURL:[self pathForGroupLocalStorage] atomically:YES];
    });
}

- (LNRecentBook *)getLastRecentBook
{
    return [self getRecentBook].lastObject;
}

- (LNRecentBook *)getLastRecentBookFromGroup
{
    NSData *data = [NSData dataWithContentsOfURL:[self pathForGroupLocalStorage]];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return array.lastObject;
}

- (void)startToReadBook:(LNBook *)book
{
    //记录最近阅读
    NSArray *books = [self getRecentBook];
    LNRecentBook *oldBook = nil;
    for (LNRecentBook *rBook in books) {
        if ([book._id isEqualToString:rBook._id]) {
            oldBook = rBook;
            break;
        }
    }
    if (oldBook) {
        //已存在
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self saveLastRecentBook:oldBook];
        });
        LNReaderViewController *readerVc = [[LNReaderViewController alloc] init];
        readerVc.recentBook = oldBook;
        if (self.mainVc.navigationController) {
            [self.mainVc.navigationController pushViewController:readerVc animated:YES];
        }
        else{
            UINavigationController *navi = (UINavigationController *)((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController;
            [navi pushViewController:readerVc animated:YES];
        }
    }
    else{
        //不存在
        LNRecentBook *recentBook = [[LNRecentBook alloc] init];
        recentBook.title = book.title;
        recentBook._id = book._id;
        recentBook.cover = book.cover;
        recentBook.readRatio = 0;
        LNReaderViewController *readerVc = [[LNReaderViewController alloc] init];
        readerVc.recentBook = recentBook;
        if (self.mainVc.navigationController) {
            [self.mainVc.navigationController pushViewController:readerVc animated:YES];
        }
        else{
            UINavigationController *navi = (UINavigationController *)((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController;
            [navi pushViewController:readerVc animated:YES];
        }
        [self saveLastRecentBook:recentBook];
    }
}
@end
