//
// EBStickerView.m
//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EBTransformableView.h"
#import "SPGripViewBorderView.h"

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kEBStickerViewControlSize 36.0



@interface EBTransformableView ()

@property (nonatomic, strong) SPGripViewBorderView *borderView;

@property (strong, nonatomic) UIImageView *rotateControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (strong, nonatomic) UIImageView *resizeControl;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UIRotationGestureRecognizer *dragRecognizer;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) CGFloat deltaAngle;
@property (nonatomic) CGFloat lastAngle;
@property (nonatomic, assign) BOOL ignoreRotate;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end



@implementation EBTransformableView

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

- (void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidLongPressed:)])
        {
            [self.transformableViewDelegate transformableViewDidLongPressed:self];
        }
    }
}


- (void)singleTap:(UIPanGestureRecognizer *)recognizer
{
//    if (![self isEditingHandlesHidden]) {
//        [UIView transitionWithView:self duration:0.2
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^(void){
//                            [self hideEditingHandles];
//                        } completion:nil];
//    }
}

- (void)deleteTap:(UIPanGestureRecognizer *)recognizer
{
    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidClose:)])
    {
        [self.transformableViewDelegate transformableViewDidClose:self];
    }
}


- (void)pinchTranslate:(UIPinchGestureRecognizer *)recognizer {
    static CGRect boundsBeforeScaling;
    static CGAffineTransform transformBeforeScaling;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        boundsBeforeScaling = recognizer.view.bounds;
        transformBeforeScaling = recognizer.view.transform;
    }
    
    CGPoint center = recognizer.view.center;
    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity,
                                                     recognizer.scale,
                                                     recognizer.scale);
    CGRect frame = CGRectApplyAffineTransform(boundsBeforeScaling, scale);
    
    frame.origin = CGPointMake(center.x - frame.size.width / 2,
                               center.y - frame.size.height / 2);

    recognizer.view.transform = CGAffineTransformIdentity;
    recognizer.view.frame = frame;
    recognizer.view.transform = transformBeforeScaling;
}

- (void)rotateTranslate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (void)dragTranslate:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self enableTransluceny:YES];
        
        CGPoint location = [recognizer locationInView:self];
        
        if (location.y < 0 || location.y > self.bounds.size.height) {
            return;
        }
        CGPoint translation = [recognizer translationInView:self];
        
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        [self enableTransluceny:NO];
    }
}

- (void)rotateTranslate1:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
//        [self enableTransluceny:YES];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidBeginEditing:)]) {
            [self.transformableViewDelegate transformableViewDidBeginEditing:self];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
//        [self enableTransluceny:YES];
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);

        float angleDiff = self.deltaAngle - ang;

        CGFloat adsorbTop = M_PI * 0.05;
        
        if (_ignoreRotate) {
            if (angleDiff > adsorbTop || angleDiff < - adsorbTop) {
                _ignoreRotate = NO;
            } else {
                 return;
            }
        }

        
        if ( angleDiff < adsorbTop && angleDiff > 0 && ang > _lastAngle) {
            angleDiff = 0;
            _ignoreRotate = YES;
        }
        
        if ( angleDiff > - adsorbTop && angleDiff < 0 && ang < _lastAngle) {
            angleDiff = 0;
            _ignoreRotate = YES;
        }
        
//        if (angleDiff > adsorbBottom && angleDiff > 0 && ang > _lastAngle) {
//            angleDiff = M_PI;
//            _ignoreRotate = YES;
//        }
        
//        if (_lastAngleDiff > -0.15 || _lastAngleDiff < 0.15) {
//
//            if (angleComparison > 0) {
//
//            }else {
//
//            }
//            NSLog(@"angleComparison %f", angleComparison);
//        }
        
        NSLog(@"deltaAngle %f ang %f  diff %f lastAngle %f",self.deltaAngle, ang, angleDiff, _lastAngle);
        
        if (NO == self.preventsResizing)
        {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
            _lastAngle = ang;
        }
        
        self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [self.borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
//        [self enableTransluceny:NO];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidEndEditing:)]) {
            [self.transformableViewDelegate transformableViewDidEndEditing:self];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateCancelled)
    {
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidCancelEditing:)]) {
            [self.transformableViewDelegate transformableViewDidCancelEditing:self];
        }
    }
}

- (void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
//        [self enableTransluceny:YES];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidBeginEditing:)]) {
            [self.transformableViewDelegate transformableViewDidBeginEditing:self];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
//        [self enableTransluceny:YES];
        
        // preventing from the picture being shrinked too far by resizing
        if (self.bounds.size.width < self.minWidth || self.bounds.size.height < self.minHeight)
        {
           
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     self.minWidth+1,
                                     self.minHeight+1);
            self.rotateControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                                   self.bounds.size.height-kEBStickerViewControlSize,
                                                   kEBStickerViewControlSize,
                                                   kEBStickerViewControlSize);
            self.deleteControl.frame = CGRectMake(0, 0,
                                                  kEBStickerViewControlSize, kEBStickerViewControlSize);
            self.resizeControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                                 0,
                                                 kEBStickerViewControlSize,
                                                 kEBStickerViewControlSize);
            self.prevPoint = [recognizer locationInView:self];
        }
        // Resizing
        else
        {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - self.prevPoint.x);
            float wRatioChange = (wChange/(float)self.bounds.size.width);
            
            hChange = wRatioChange * self.bounds.size.height;
            
            if (ABS(wChange) > 50.0f || ABS(hChange) > 50.0f)
            {
                self.prevPoint = [recognizer locationOfTouch:0 inView:self];
                return;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            self.rotateControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                                   self.bounds.size.height-kEBStickerViewControlSize,
                                                   kEBStickerViewControlSize, kEBStickerViewControlSize);
            self.deleteControl.frame = CGRectMake(0, 0,
                                                  kEBStickerViewControlSize, kEBStickerViewControlSize);
            self.resizeControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                                 0,
                                                 kEBStickerViewControlSize,
                                                 kEBStickerViewControlSize);
            
            self.prevPoint = [recognizer locationOfTouch:0 inView:self];
        }
        
        self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [self.borderView setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
//        [self enableTransluceny:NO];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidEndEditing:)]) {
            [self.transformableViewDelegate transformableViewDidEndEditing:self];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateCancelled)
    {
        // Inform delegate.
        if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidCancelEditing:)]) {
            [self.transformableViewDelegate transformableViewDidCancelEditing:self];
        }
    }
}



- (void)setupDefaultAttributes
{
    self.borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    self.borderView.borderColor = self.borderColor;
    self.borderView.borderWidth = self.borderWidth;
    [self.borderView setHidden:YES];
    [self addSubview:self.borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5)
    {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    }
    else
    {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }

    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = NO;
    self.translucencySticker = YES;
    self.allowDragging = YES;

    UILongPressGestureRecognizer*longpress = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self
                                                      action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(singleTap:)];
    [self addGestureRecognizer:singleTap];
    

    self.deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                      kEBStickerViewControlSize, kEBStickerViewControlSize)];
    self.deleteControl.backgroundColor = [UIColor clearColor];
    self.deleteControl.image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZDBtn3" ofType:@"png"]];
    self.deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                                 action:@selector(deleteTap:)];
    [self.deleteControl addGestureRecognizer:deleteTap];
    [self addSubview:self.deleteControl];

    self.rotateControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kEBStickerViewControlSize,
                                                                        self.frame.size.height-kEBStickerViewControlSize,
                                                                        kEBStickerViewControlSize, kEBStickerViewControlSize)];
    self.rotateControl.backgroundColor = [UIColor clearColor];
    self.rotateControl.userInteractionEnabled = YES;
    self.rotateControl.image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZDBtn4" ofType:@"png"]];
    UIPanGestureRecognizer*panResizeGesture = [[UIPanGestureRecognizer alloc]
                                               initWithTarget:self
                                                       action:@selector(rotateTranslate1:)];
    [self.rotateControl addGestureRecognizer:panResizeGesture];
    [self addSubview:self.rotateControl];

    self.resizeControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kEBStickerViewControlSize,
                                                                      0,
                                                                      kEBStickerViewControlSize, kEBStickerViewControlSize)];
    self.resizeControl.backgroundColor = [UIColor clearColor];
    self.resizeControl.userInteractionEnabled = YES;
    self.resizeControl.image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZDBtn2" ofType:@"png"]];
    [self addSubview:self.resizeControl];
    
    UIPanGestureRecognizer*panResizeGesture1 = [[UIPanGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(resizeTranslate:)];
    [self.resizeControl addGestureRecognizer:panResizeGesture1];
    
//    UITapGestureRecognizer*resizeControlTap = [[UITapGestureRecognizer alloc]
//                                                initWithTarget:nil
//                                                action:nil];
//    [self.resizeControl addGestureRecognizer:resizeControlTap];

    // Add pinch gesture recognizer.
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(pinchTranslate:)];
    [self addGestureRecognizer:self.pinchRecognizer];
    
    // Add rotation recognizer.
    self.rotationRecognizer = [[UIRotationGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(rotateTranslate:)];
    [self addGestureRecognizer:self.rotationRecognizer];
    
    self.dragRecognizer = [[UIPanGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(dragTranslate:)];
    [self addGestureRecognizer:self.dragRecognizer];

    self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                            self.frame.origin.x+self.frame.size.width - self.center.x);
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}



- (void)setContentView:(UIView *)newContentView
{
    [self.contentView removeFromSuperview];
    _contentView = newContentView;

    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:self.contentView];

    for (UIView *subview in [self.contentView subviews])
    {
        [subview setFrame:CGRectMake(0, 0,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height)];

        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    [self bringSubviewToFront:self.borderView];
    [self bringSubviewToFront:self.rotateControl];
    [self bringSubviewToFront:self.deleteControl];
    [self bringSubviewToFront:self.resizeControl];
}



- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    for (UIView *subview in [self.contentView subviews])
    {
        [subview setFrame:CGRectMake(0, 0,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height)];

        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    self.borderView.frame = CGRectInset(self.bounds,
                                        kSPUserResizableViewGlobalInset,
                                        kSPUserResizableViewGlobalInset);
    
    self.rotateControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                           self.bounds.size.height-kEBStickerViewControlSize,
                                           kEBStickerViewControlSize,
                                           kEBStickerViewControlSize);

    self.deleteControl.frame = CGRectMake(0, 0,
                                          kEBStickerViewControlSize, kEBStickerViewControlSize);

    self.resizeControl.frame =CGRectMake(self.bounds.size.width-kEBStickerViewControlSize,
                                         0,
                                         kEBStickerViewControlSize,
                                         kEBStickerViewControlSize);
    
    [self.borderView setNeedsDisplay];
}



//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (!self.allowDragging)
//    {
//        return;
//    }
//
////    [self enableTransluceny:YES];
//
//    UITouch *touch = [touches anyObject];
//    self.touchStart = [touch locationInView:self.superview];
//    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidBeginEditing:)])
//    {
//        [self.transformableViewDelegate transformableViewDidBeginEditing:self];
//    }
//}
//
//
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self enableTransluceny:NO];
//
//    // Notify the delegate we've ended our editing session.
//    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidEndEditing:)])
//    {
//        [self.transformableViewDelegate transformableViewDidEndEditing:self];
//    }
//
//}
//
//
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self enableTransluceny:NO];
//
//    // Notify the delegate we've ended our editing session.
//    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidCancelEditing:)])
//    {
//        [self.transformableViewDelegate transformableViewDidCancelEditing:self];
//    }
//}



- (void)translateUsingTouchLocation:(CGPoint)touchPoint
{
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,
                                    self.center.y + touchPoint.y - self.touchStart.y);

    if (self.preventsPositionOutsideSuperview)
    {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX)
        {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }

        if (newCenter.x < midPointX)
        {
            newCenter.x = midPointX;
        }

        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY)
        {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }

        if (newCenter.y < midPointY)
        {
            newCenter.y = midPointY;
        }
    }

    self.center = newCenter;
}



//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (!self.allowDragging)
//    {
//        return;
//    }
//
//    [self enableTransluceny:YES];
//
//    CGPoint touchLocation = [[touches anyObject] locationInView:self];
//    if (CGRectContainsPoint(self.rotateControl.frame, touchLocation))
//    {
//        return;
//    }
//
//    CGPoint touch = [[touches anyObject] locationInView:self.superview];
//    [self translateUsingTouchLocation:touch];
//    self.touchStart = touch;
//}

#pragma mark - Property setter and getter

- (void)hideDelHandle
{
    self.deleteControl.hidden = YES;
}



- (void)showDelHandle
{
    self.deleteControl.hidden = NO;
}



- (void)hideEditingHandles
{
    self.rotateControl.hidden = YES;
    self.deleteControl.hidden = YES;
    self.resizeControl.hidden = YES;
    [self.borderView setHidden:YES];
    
    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidHideEditingHandles:)]) {
        [self.transformableViewDelegate transformableViewDidHideEditingHandles:self];
    }
}



- (void)showEditingHandles
{
    if (NO == self.preventsCustomButton)
    {
        self.resizeControl.hidden = NO;
    }
    else
    {
        self.resizeControl.hidden = YES;
    }

    if (NO == self.preventsDeleting)
    {
        self.deleteControl.hidden = NO;
    }
    else
    {
        self.deleteControl.hidden = YES;
    }

    if (NO == self.preventsResizing)
    {
        self.rotateControl.hidden = NO;
    }
    else
    {
        self.rotateControl.hidden = YES;
    }

    [self.borderView setHidden:NO];
    
    if ([self.transformableViewDelegate respondsToSelector:@selector(transformableViewDidShowEditingHandles:)]) {
        [self.transformableViewDelegate transformableViewDidShowEditingHandles:self];
    }
}



- (void)showCustomHandle
{
    self.resizeControl.hidden = NO;
}



- (void)hideCustomHandle
{
    self.resizeControl.hidden = YES;
}

- (BOOL)isEditingHandlesHidden
{
    return self.borderView.hidden;
}

- (void)enableTransluceny:(BOOL)state
{
    if (self.translucencySticker == YES)
    {
        if (state == YES)
        {
            self.alpha = 0.65;
        }
        else
        {
            self.alpha = 1.0;
        }
    }
}

- (UIColor *)borderColor {
    return self.borderView.borderColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.borderView.borderColor = borderColor;
}

- (CGFloat)borderWidth {
    return self.borderView.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.borderView.borderWidth = borderWidth;
}

- (BOOL)allowPinchToZoom {
    return self.pinchRecognizer.isEnabled;
}

- (void)setAllowPinchToZoom:(BOOL)allowPinchToZoom {
    self.pinchRecognizer.enabled = allowPinchToZoom;
}

- (BOOL)allowRotationGesture {
    return self.rotationRecognizer.isEnabled;
}

-(void)setAllowRotationGesture:(BOOL)allowRotationGesture {
    self.rotationRecognizer.enabled = allowRotationGesture;
}


@end
