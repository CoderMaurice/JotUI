//
//  EBWrittingScrapState.h
//  jotuiexample
//
//  Created by Maurice on 2019/1/16.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBWrittingScrapView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EBWrittingScrapStateDelegate;

@interface EBWrittingScrapState : NSObject

- (instancetype)initWithScrap:(EBWrittingScrapView *)scrap;

@property (weak, nonatomic) id<EBWrittingScrapStateDelegate> delegate;

@property (nonatomic, copy) EBWrittingScrapView *scrapView;

@property (nonatomic, assign) NSInteger index;

@end

@protocol EBWrittingScrapStateDelegate <NSObject>
@required
@optional

- (void)scrapDidBecomeActive:(EBWrittingScrapState *)state;
- (void)scrapDidResignActive:(EBWrittingScrapState *)state;
- (void)scrapPerformClose:(EBWrittingScrapState *)state;

@end

NS_ASSUME_NONNULL_END
