//
//  EBWrittingScrapImageView.m
//  jotuiexample
//
//  Created by Maurice on 2019/1/15.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapImageView.h"
#import "EBTransformableView.h"

@interface EBWrittingScrapImageView ()<EBTransformableViewDelegate>

@property (nonatomic, strong) UIImage *image;


@end

@implementation EBWrittingScrapImageView

- (instancetype)initWithImage:(UIImage *)image
{
    CGSize fitSize = [self fitSizeWithImage:image];
    self = [super initWithFrame:(CGRect){CGPointZero , fitSize}];
    if (self) {
        _image = image;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    
    self.contentView = imageView;
    self.preventsPositionOutsideSuperview = NO;
    self.translucencySticker = YES;
    self.borderColor = MCOLOR(225, 73, 59, 1);
    self.borderWidth = 2.f;
}

- (CGSize)fitSizeWithImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGFloat imageW = imageSize.width;
    CGFloat imageH = imageSize.height;
    CGFloat maxImageW = SCREEN_WIDTH / 2.0;
    CGFloat maxImageH = SCREEN_HEIGHT / 2.0;

    if (imageW > maxImageW) {
        imageW = maxImageW;
        imageH = imageSize.height / imageSize.width  * maxImageW;
    }
    
    if (imageH > maxImageH) {
        imageH = maxImageH;
        imageW = imageSize.width / imageSize.height * imageH;
    }
    
    return CGSizeMake(imageW, imageH);
}


@end
