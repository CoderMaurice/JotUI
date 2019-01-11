//
//  NSFileManager+DirectoryOptimizations.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSFileManager+DirectoryOptimizations.h"



@implementation NSFileManager (DirectoryOptimizations)


static NSMutableSet* pathCacheDictionary;

+ (void)makePathCacheDictionary {
    if (!pathCacheDictionary) {
        pathCacheDictionary = [[NSMutableSet alloc] init];
    }
}

// checks if we've tried to create this path before,
// if so then returns immediatley.
// otherwise checks existence and creates if needed
+ (void)ensureDirectoryExistsAtPath:(NSString*)path {
    if (!path)
        return;
    [NSFileManager makePathCacheDictionary];

    BOOL contains = NO;
    if (path) {
        @synchronized(pathCacheDictionary) {
            contains = [pathCacheDictionary containsObject:path];
            if (!contains) {
                [pathCacheDictionary addObject:path];
            }
        }
    }
    if (!contains) {
        NSFileManager* fm = [[NSFileManager alloc] init];
        if (![fm fileExistsAtPath:path]) {
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

static NSArray* userDocumentsPaths;
static NSArray* userCachesPaths;

+ (NSString*)cachesPath {
    if (!userCachesPaths) {
        userCachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    }
    return [userCachesPaths objectAtIndex:0];
}

+ (NSString*)documentsPath {
    if (!userDocumentsPaths) {
        userDocumentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    }
    return [userDocumentsPaths objectAtIndex:0];
}

- (void)enumerateDirectory:(NSString*)directory withBlock:(void (^)(NSURL* item, NSUInteger totalItemCount))perItemBlock andErrorHandler:(BOOL (^)(NSURL* url, NSError* error))handler {
    if (directory) {
        NSArray* directoryContents = [[self enumeratorAtURL:[NSURL fileURLWithPath:directory] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants errorHandler:handler] allObjects];
        for (NSURL* subpath in directoryContents) {
            perItemBlock(subpath, [directoryContents count]);
        }
    }
}

- (BOOL)isDirectory:(NSString*)path {
    BOOL isDirectory = NO;
    BOOL exists = path && [self fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory && exists;
}


@end
