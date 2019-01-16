//
//  EBWrittingScrapState.m
//  jotuiexample
//
//  Created by Maurice on 2019/1/16.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapState.h"

@interface EBWrittingScrapState () <EBTransformableViewDelegate>

@end

@implementation EBWrittingScrapState

- (instancetype)initWithScrap:(EBWrittingScrapView *)scrap
{
    self = [super init];
    if (self) {
        _scrapView = scrap;
        scrap.transformableViewDelegate = self;
    }
    return self;
}

#pragma mark - EBTransformableViewDelegate

//- (void)transformableViewDidBeginEditing:(EBTransformableView *)sticker;
//- (void)transformableViewDidEndEditing:(EBTransformableView *)sticker;
//- (void)transformableViewDidCancelEditing:(EBTransformableView *)sticker;

- (void)transformableViewDidShowEditingHandles:(EBTransformableView *)view
{
    if ([self.delegate respondsToSelector:@selector(scrapDidBecomeActive:)]) {
        [self.delegate scrapDidBecomeActive:self];
    }
}

- (void)transformableViewDidHideEditingHandles:(EBTransformableView *)view
{
    if ([self.delegate respondsToSelector:@selector(scrapDidResignActive:)]) {
        [self.delegate scrapDidResignActive:self];
    }
}

- (void)transformableViewDidClose:(EBTransformableView *)sticker
{
    if ([self.delegate respondsToSelector:@selector(scrapPerformClose:)]) {
        [self.delegate scrapPerformClose:self];
    }
}

- (void)transformableViewDidLongPressed:(EBTransformableView *)sticker
{
    
}

- (void)transformableViewDidCustomButtonTap:(EBTransformableView *)sticker
{
    
}

@end
