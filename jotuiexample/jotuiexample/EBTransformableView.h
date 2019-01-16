//
// EBtransformableView.h
//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EBTransformableViewDelegate;


@interface EBTransformableView : UIView

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) BOOL preventsPositionOutsideSuperview;    // default = YES
@property (nonatomic) BOOL preventsResizing;                    // default = NO
@property (nonatomic) BOOL preventsDeleting;                    // default = NO
@property (nonatomic) BOOL preventsCustomButton;                // default = YES
@property (nonatomic) BOOL translucencySticker;                 // default = YES
@property (nonatomic) BOOL allowPinchToZoom;
@property (nonatomic) BOOL allowRotationGesture;
@property (nonatomic) BOOL allowDragging;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

@property (weak, nonatomic) id <EBTransformableViewDelegate> transformableViewDelegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustomHandle;
- (void)hideCustomHandle;
- (BOOL)isEditingHandlesHidden;
@end


@protocol EBTransformableViewDelegate <NSObject>
@required
@optional

- (void)transformableViewDidBeginEditing:(EBTransformableView *)sticker;
- (void)transformableViewDidEndEditing:(EBTransformableView *)sticker;
- (void)transformableViewDidCancelEditing:(EBTransformableView *)sticker;

- (void)transformableViewDidShowEditingHandles:(EBTransformableView *)sticker;
- (void)transformableViewDidHideEditingHandles:(EBTransformableView *)sticker;

- (void)transformableViewDidClose:(EBTransformableView *)sticker;
- (void)transformableViewDidLongPressed:(EBTransformableView *)sticker;
- (void)transformableViewDidCustomButtonTap:(EBTransformableView *)sticker;

@end
