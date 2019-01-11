//
//  NSFileManager+DirectoryOptimizations.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (DirectoryOptimizations)

+ (NSString*)cachesPath;

+ (NSString*)documentsPath;

+ (void)ensureDirectoryExistsAtPath:(NSString*)path;

- (void)enumerateDirectory:(NSString*)directory withBlock:(void (^)(NSURL* item, NSUInteger totalItemCount))perItemBlock andErrorHandler:(BOOL (^)(NSURL* url, NSError* error))handler;

- (BOOL)isDirectory:(NSString*)path;


@end
