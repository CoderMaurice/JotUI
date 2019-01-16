//
//  EBWrittingScrapImageView.h
//  jotuiexample
//
//  Created by Maurice on 2019/1/15.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EBWrittingScrapImageView : EBWrittingScrapView

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, strong, readonly) UIImage *image;

@end

NS_ASSUME_NONNULL_END
