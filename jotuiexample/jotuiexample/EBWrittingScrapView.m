//
//  EBWrittingScrapView.m
//  jotuiexample
//
//  Created by Maurice on 2019/1/15.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapView.h"

@implementation EBWrittingScrapView

- (void)becomeActivate:(BOOL)active
{
    if (active == _active) return;
    _active = active;
    if (active) {
        [self showEditingHandles];
    }else {
        [self hideEditingHandles];
    }
}

@end
