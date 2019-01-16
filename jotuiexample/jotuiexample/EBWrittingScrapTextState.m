//
//  EBWrittingScrapTextState.m
//  jotuiexample
//
//  Created by Maurice on 2019/1/16.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapTextState.h"

@implementation EBWrittingScrapTextState

- (void)transformableViewDidShowEditingHandles:(EBTransformableView *)view
{
    if ([self.delegate respondsToSelector:@selector(scrapDidBecomeActive:)]) {
        [self.delegate scrapDidBecomeActive:self];
    }
    
    UITextView *textView = (UITextView *)self.scrapView.contentView;
    [textView becomeFirstResponder];
}

- (void)transformableViewDidHideEditingHandles:(EBTransformableView *)view
{
    if ([self.delegate respondsToSelector:@selector(scrapDidResignActive:)]) {
        [self.delegate scrapDidResignActive:self];
    }
    
    UITextView *textView = (UITextView *)self.scrapView.contentView;
    [textView resignFirstResponder];
}

@end
