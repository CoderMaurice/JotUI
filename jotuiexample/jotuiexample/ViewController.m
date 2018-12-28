//
//  ViewController.m
//  jotuiexample
//
//  Created by Adam Wulf on 12/8/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import "Pen.h"
#import <JotUI/JotUI.h>
#import <JotUI/SegmentSmoother.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>

@interface ViewController () <JotViewStateProxyDelegate, UIScrollViewDelegate>

@property (nonatomic, strong)  UIView *highlightView;
@property (nonatomic, strong)  UIView *line;
@property (nonatomic, strong)  UIScrollView *jotViewContainer;
@property (nonatomic, strong)  UIScrollView *displayViewContainer;

@end


@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pen = [[Pen alloc] init];
    marker = [[Marker alloc] init];
    eraser = [[Eraser alloc] init];
    marker.color = [redButton backgroundColor];
    pen.color = [blackButton backgroundColor];
    highlighter = [[Highlighter alloc] init];
    highlighter.color = [redButton backgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {

    CGFloat topToolBarHeight = 76.f;
    CGFloat jotViewH = 200.f;
    CGFloat highlightRatio = 2.f;
    
//    JotView *view = [[JotView alloc] initWithFrame:CGRectMake(0, 0, 3000, 1000)];
//    view.frame = CGRectMake(0, 0, 3000, 1000);
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - jotViewH - 1,  self.view.mj_width, 1)];
        _line.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_line];
    }
    
    CGSize displaySize = CGSizeMake(self.view.mj_width, _line.mj_y - topToolBarHeight);
    
    if (!_jotViewContainer) {
        _jotViewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - jotViewH, self.view.mj_width, jotViewH)];
        _jotViewContainer.showsHorizontalScrollIndicator = NO;
        _jotViewContainer.showsVerticalScrollIndicator = NO;
        _jotViewContainer.scrollEnabled = NO;
        _jotViewContainer.delegate = self;
        _jotViewContainer.bounces = NO;
        [self.view addSubview:_jotViewContainer];
        
        writtingPad = [[JotView alloc] initWithFrame:(CGRect){CGPointZero,CGSizeMake(displaySize.width * highlightRatio, displaySize.height *highlightRatio)}];
        writtingPad.delegate = self;
        [_jotViewContainer addSubview:writtingPad];
        
        JotViewStateProxy* paperState = [[JotViewStateProxy alloc] initWithDelegate:self];
        paperState.delegate = self;
        [paperState loadJotStateAsynchronously:NO withSize:writtingPad.bounds.size andScale:[[UIScreen mainScreen] scale] andContext:writtingPad.context andBufferManager:[JotBufferManager sharedInstance]];
        [writtingPad loadState:paperState];
        
        [self changePenType:nil];
        
        [self tappedColorButton:blackButton];
        
        _jotViewContainer.contentSize = writtingPad.mj_size;
        _jotViewContainer.contentOffset = CGPointZero;
    }
    
    if (!_displayViewContainer) {
        _displayViewContainer = [[UIScrollView alloc] initWithFrame:(CGRect){CGPointMake(0, topToolBarHeight), displaySize}];
        _displayViewContainer.scrollEnabled = NO;
        [self.view addSubview:_displayViewContainer];
        
        displayView = [[JotView alloc] initWithFrame:_displayViewContainer.bounds];
        [_displayViewContainer addSubview:displayView];
        
        JotViewStateProxy* paperState = [[JotViewStateProxy alloc] initWithDelegate:self];
        paperState.delegate = self;
        [paperState loadJotStateAsynchronously:NO withSize:displayView.bounds.size andScale:[[UIScreen mainScreen] scale] andContext:displayView.context andBufferManager:[JotBufferManager sharedInstance]];
        [displayView loadState:paperState];
        
         _displayViewContainer.contentSize = displayView.mj_size;
        _displayViewContainer.contentOffset = CGPointZero;
        
        _highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _jotViewContainer.mj_width / highlightRatio, _jotViewContainer.mj_height / highlightRatio)];
        _highlightView.layer.borderColor = [UIColor blackColor].CGColor;
        _highlightView.layer.borderWidth = 1.0;
        [_displayViewContainer addSubview:_highlightView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(highlightViewPan:)];
        [_highlightView addGestureRecognizer:pan];
    }
    
    [self.view bringSubviewToFront:additionalOptionsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers

- (Pen*)activePen {
    if (penVsMarkerControl.selectedSegmentIndex == 0) {
        return pen;
    } else if (penVsMarkerControl.selectedSegmentIndex == 1) {
        return marker;
    } else if (penVsMarkerControl.selectedSegmentIndex == 2) {
        return eraser;
    } else {
        return highlighter;
    }
}

- (void)updatePenTickers {
    minAlpha.text = [NSString stringWithFormat:@"%.2f", [self activePen].minAlpha];
    maxAlpha.text = [NSString stringWithFormat:@"%.2f", [self activePen].maxAlpha];
    minWidth.text = [NSString stringWithFormat:@"%d", (int)[self activePen].minSize];
    maxWidth.text = [NSString stringWithFormat:@"%d", (int)[self activePen].maxSize];
}


#pragma mark - IBAction


- (IBAction)changePenType:(id)sender {
    if ([[self activePen].color isEqual:blackButton.backgroundColor])
        [self tappedColorButton:blackButton];
    if ([[self activePen].color isEqual:redButton.backgroundColor])
        [self tappedColorButton:redButton];
    if ([[self activePen].color isEqual:greenButton.backgroundColor])
        [self tappedColorButton:greenButton];
    if ([[self activePen].color isEqual:blueButton.backgroundColor])
        [self tappedColorButton:blueButton];
    
    [self updatePenTickers];
}

- (IBAction)toggleOptionsPane:(id)sender {
    additionalOptionsView.hidden = !additionalOptionsView.hidden;
}

- (IBAction)tappedColorButton:(UIButton*)sender {
    for (UIButton *button in [NSArray arrayWithObjects:blueButton, redButton, greenButton, blackButton, nil]) {
        if (sender == button) {
            [button setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            button.selected = YES;
        } else {
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            button.selected = NO;
        }
    }
    
    [self activePen].color = [sender backgroundColor];
}

- (IBAction)changeWidthOrSize:(UISegmentedControl*)sender {
    if (sender == minAlphaDelta) {
        if (sender.selectedSegmentIndex == 0) {
            [self activePen].minAlpha -= .1;
        } else if (sender.selectedSegmentIndex == 1) {
            [self activePen].minAlpha -= .01;
        } else if (sender.selectedSegmentIndex == 2) {
            [self activePen].minAlpha += .01;
        } else if (sender.selectedSegmentIndex == 3) {
            [self activePen].minAlpha += .1;
        }
    }
    if (sender == maxAlphaDelta) {
        if (sender.selectedSegmentIndex == 0) {
            [self activePen].maxAlpha -= .1;
        } else if (sender.selectedSegmentIndex == 1) {
            [self activePen].maxAlpha -= .01;
        } else if (sender.selectedSegmentIndex == 2) {
            [self activePen].maxAlpha += .01;
        } else if (sender.selectedSegmentIndex == 3) {
            [self activePen].maxAlpha += .1;
        }
    }
    if (sender == minWidthDelta) {
        if (sender.selectedSegmentIndex == 0) {
            [self activePen].minSize -= 5;
        } else if (sender.selectedSegmentIndex == 1) {
            [self activePen].minSize -= 1;
        } else if (sender.selectedSegmentIndex == 2) {
            [self activePen].minSize += 1;
        } else if (sender.selectedSegmentIndex == 3) {
            [self activePen].minSize += 5;
        }
    }
    if (sender == maxWidthDelta) {
        if (sender.selectedSegmentIndex == 0) {
            [self activePen].maxSize -= 5;
        } else if (sender.selectedSegmentIndex == 1) {
            [self activePen].maxSize -= 1;
        } else if (sender.selectedSegmentIndex == 2) {
            [self activePen].maxSize += 1;
        } else if (sender.selectedSegmentIndex == 3) {
            [self activePen].maxSize += 5;
        }
    }
    
    
    if ([self activePen].minAlpha < 0)
        [self activePen].minAlpha = 0;
    if ([self activePen].minAlpha > 1)
        [self activePen].minAlpha = 1;
    
    if ([self activePen].maxAlpha < 0)
        [self activePen].maxAlpha = 0;
    if ([self activePen].maxAlpha > 1)
        [self activePen].maxAlpha = 1;
    
    if ([self activePen].minSize < 0)
        [self activePen].minSize = 0;
    if ([self activePen].maxSize < 0)
        [self activePen].maxSize = 0;
    
    [self updatePenTickers];
}


- (IBAction)saveImage {
    [writtingPad exportImageTo:[self jotViewStateInkPath] andThumbnailTo:[self jotViewStateThumbPath] andStateTo:[self jotViewStatePlistPath] withThumbnailScale:[[UIScreen mainScreen] scale] onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state) {
        UIImageWriteToSavedPhotosAlbum(thumb, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Saved" message:@"The JotView's state has been saved to disk, and a full resolution image has been saved to the photo album." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }];
}

- (IBAction)loadImageFromLibary:(UIButton*)sender {
    [[writtingPad state] setIsForgetful:YES];
    JotViewStateProxy* state = [[JotViewStateProxy alloc] initWithDelegate:self];
    [state loadJotStateAsynchronously:NO withSize:writtingPad.bounds.size andScale:[[UIScreen mainScreen] scale] andContext:writtingPad.context andBufferManager:[JotBufferManager sharedInstance]];
    [writtingPad loadState:state];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Loaded" message:@"The JotView's state been loaded from disk." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)highlightViewPan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint transP = [recognizer translationInView:self.highlightView];
        
        CGFloat newOrginX = MAX(MIN(displayView.bounds.size.width - _highlightView.bounds.size.width, _highlightView.frame.origin.x + transP.x), 0);
        CGFloat newOrginY = MAX(MIN(CGRectGetMaxY(displayView.frame) - _highlightView.bounds.size.height, _highlightView.frame.origin.y + transP.y), 0);
        
        _highlightView.frame = (CGRect){CGPointMake(newOrginX, newOrginY), _highlightView.frame.size};

        _jotViewContainer.contentOffset = CGPointMake(_highlightView.mj_origin.x * 2, _highlightView.mj_origin.y * 2);
        
        [recognizer setTranslation:CGPointZero inView:self.highlightView];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
    }
}

#pragma mark - Jot Stylus Button Callbacks

- (void)nextColor {
    // double the blue button, so that if the black is selected,
    // we'll cycle back to the beginning
    NSArray* buttons = [NSArray arrayWithObjects:blackButton, redButton, greenButton, blueButton, blackButton, nil];
    for (UIButton* button in buttons) {
        if (button.selected) {
            [self tappedColorButton:[buttons objectAtIndex:[buttons indexOfObject:button inRange:NSMakeRange(0, [buttons count] - 1)] + 1]];
            break;
        }
    }
}
- (void)previousColor {
    NSArray* buttons = [NSArray arrayWithObjects:blueButton, greenButton, redButton, blackButton, blueButton, nil];
    for (UIButton* button in buttons) {
        if (button.selected) {
            [self tappedColorButton:[buttons objectAtIndex:[buttons indexOfObject:button inRange:NSMakeRange(0, [buttons count] - 1)] + 1]];
            break;
        }
    }
}

- (void)increaseStrokeWidth {
    [self activePen].minSize += 1;
    [self activePen].maxSize += 1.5;
    [self updatePenTickers];
}
- (void)decreaseStrokeWidth {
    [self activePen].minSize -= 1;
    [self activePen].maxSize -= 1.5;
    [self updatePenTickers];
}

- (IBAction)undo {
    [writtingPad undo];
    [displayView undo];
}

- (IBAction)redo {
    [writtingPad redo];
    [displayView redo];
}

- (IBAction)clearScreen:(id)sender {
    [displayView clear:YES];
    [writtingPad clear:YES];
}


#pragma mark - JotViewDelegate

- (JotBrushTexture*)textureForStroke {
    return [[self activePen] textureForStroke];
}

- (CGFloat)stepWidthForStroke {
    return [[self activePen] stepWidthForStroke];
}

- (BOOL)supportsRotation {
    return [[self activePen] supportsRotation];
}

- (NSArray*)willAddElements:(NSArray*)elements toStroke:(JotStroke*)stroke fromPreviousElement:(AbstractBezierPathElement*)previousElement inJotView:(JotView*)writtingPad {
    
    // Project the stroke on the displayView by ratio
    CGFloat scaleX = _highlightView.bounds.size.width / _jotViewContainer.bounds.size.width;
    CGFloat scaleY = _highlightView.bounds.size.height / _jotViewContainer.bounds.size.height;
//    JotElementsRatio ratio = {CGSizeMake(- _highlightView.frame.origin.x, (displayView.bounds.size.height - (writtingPad.bounds.size.height * scaleY)) - _highlightView.frame.origin.y), CGPointMake(scaleX, scaleY)};
    JotElementsRatio ratio = {CGSizeZero, CGPointMake(scaleX, scaleY)};
    [displayView addElements:elements withTexture:[self activePen].texture ratio:ratio];
    
    return [[self activePen] willAddElements:elements toStroke:stroke fromPreviousElement:previousElement inJotView:writtingPad];
}

- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willBeginStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
    return YES;
}

- (void)willMoveStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willMoveStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)shortStrokeEnding inJotView:(JotView*)writtingPad {
    // noop
}

- (void)didEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    
    [displayView.state finishCurrentStroke];
//    [writtingPad undo];
//    _jotViewContainer.image = [self displayViewSnapshotImage];
}

//- (UIImage *)displayViewSnapshotImage
//{
//    CGSize size = displayView.bounds.size;
//    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//
//    CGRect rect = displayView.bounds;
//    [displayView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
//    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    CGRect clipRect = CGRectMake(_highlightView.frame.origin.x, _highlightView.frame.origin.y - displayView.frame.origin.y, _highlightView.frame.size.width * [UIScreen mainScreen].scale, _highlightView.frame.size.height * [UIScreen mainScreen].scale);
//    return [self imageFromImage:snapshotImage inRect:clipRect];
//}
//
//- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect
//{
//    CGImageRef sourceImageRef = [image CGImage];
//
//    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
//
//    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
//
//    CGImageRelease(newImageRef);
//
//    return newImage;
//}

- (void)willCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (void)didCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] didCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] setShouldUseVelocity:!pressureVsVelocityControl || pressureVsVelocityControl.selectedSegmentIndex];
    return [[self activePen] colorForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] setShouldUseVelocity:!pressureVsVelocityControl || pressureVsVelocityControl.selectedSegmentIndex];
    return [[self activePen] widthForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (CGFloat)smoothnessForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    return [[self activePen] smoothnessForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)_popoverController {
    popoverController = nil;
}

#pragma mark - JotViewStateProxyDelegate

- (NSString*)documentsDir {
    NSArray<NSString*>* userDocumentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [userDocumentsPaths objectAtIndex:0];
}

- (NSString*)jotViewStateInkPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"ink.png"];
}

- (NSString*)jotViewStateThumbPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"thumb.png"];
}

- (NSString*)jotViewStatePlistPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"state.plist"];
}

- (void)didLoadState:(JotViewStateProxy*)state {
}

- (void)didUnloadState:(JotViewStateProxy*)state {
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"Scroll To %@",NSStringFromCGPoint(scrollView.contentOffset));
}

@end
