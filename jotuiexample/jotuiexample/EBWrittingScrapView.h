//
//  EBWrittingScrapView.h
//  jotuiexample
//
//  Created by Maurice on 2019/1/15.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBTransformableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EBWrittingScrapView : EBTransformableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

// 唯一标识符
@property (nonatomic, copy) NSString *ID;

@property (nonatomic, assign) BOOL active;

- (void)becomeActivate:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
