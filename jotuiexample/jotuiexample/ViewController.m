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

#import "TZImagePickerController.h"

#import "EBWriteBackgrounds.h"
#import "EBWrittingScrapImageView.h"
#import "EBWrittingScrapTextView.h"
#import "EBWrittingScrapImageState.h"
#import "EBWrittingScrapTextState.h"

typedef enum : NSUInteger {
    DrawingTypeDefault = 1,
    DrawingTypeWritingPad,
} DrawingType;

@interface ViewController () <JotViewStateProxyDelegate, UIScrollViewDelegate, TZImagePickerControllerDelegate, EBWrittingScrapStateDelegate>

@property (nonatomic, strong) MMPaperTemplateView *background;
@property (nonatomic, strong) NSArray *backgroundThemes;
@property (nonatomic, assign) NSInteger themeIndex;

@property (nonatomic, strong)  UIView *highlightView;
@property (nonatomic, strong)  UIView *line;
@property (nonatomic, strong)  UIScrollView *jotViewContainer;
@property (nonatomic, strong)  UIScrollView *displayViewContainer;

@property (nonatomic, assign) DrawingType drawingType;


@property (nonatomic, strong) NSMutableArray<EBWrittingScrapState *> *scrapStates;
@property (nonatomic, strong) EBWrittingScrapView *activatedScrapView;
@property (nonatomic, strong) UITapGestureRecognizer *scarpResignActiveTap;


@end


@implementation ViewController

- (NSMutableArray<EBWrittingScrapState *> *)scrapStates
{
    if (!_scrapStates) {
        _scrapStates = [NSMutableArray array];
    }
    return _scrapStates;
}

- (NSArray *)backgroundThemes
{
    if (!_backgroundThemes) {
        _backgroundThemes = @[[MMEmptyTemplateView class], [MMCmDotsTemplateView class], [MMCmGridTemplateView class]];
    }
    return _backgroundThemes;
}

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
    
     _themeIndex = 0;
}

static CGFloat topToolBarHeight = 76.f;

- (void)viewWillAppear:(BOOL)animated {

    _drawingType = DrawingTypeDefault;
    
    switch (_drawingType) {
        case DrawingTypeDefault:
            [self setupDefaultSubview];
            break;
            
        case DrawingTypeWritingPad:
            [self setupWritingPadSubview];
            break;
    }
    
    [self.view bringSubviewToFront:additionalOptionsView];
}

- (void)setupDefaultSubview
{
    if (!_displayViewContainer) {
        
        CGRect frame = CGRectMake(0, topToolBarHeight, self.view.mj_width, self.view.mj_height - topToolBarHeight);
        
        _displayViewContainer = [[UIScrollView alloc] initWithFrame:frame];
        _displayViewContainer.scrollEnabled = NO;
        [self.view addSubview:_displayViewContainer];
        
        displayView = [[JotView alloc] initWithFrame:_displayViewContainer.bounds];
        displayView.delegate = self;
        [_displayViewContainer addSubview:displayView];
        
        JotViewStateProxy* paperState = [[JotViewStateProxy alloc] initWithDelegate:self];
        paperState.delegate = self;
        [paperState loadJotStateAsynchronously:NO withSize:displayView.bounds.size andScale:[[UIScreen mainScreen] scale] andContext:displayView.context andBufferManager:[JotBufferManager sharedInstance]];
        [displayView loadState:paperState];
        
        _displayViewContainer.contentSize = displayView.mj_size;
        _displayViewContainer.contentOffset = CGPointZero;
        
        _background = [[self.backgroundThemes[_themeIndex] alloc] initWithFrame:_displayViewContainer.bounds
                                                                andOriginalSize:_displayViewContainer.bounds.size
                                                                  andProperties:@{}];
        [_displayViewContainer addSubview:_background];
        _themeIndex ++;
        [_displayViewContainer sendSubviewToBack:_background];
        
        
        UILongPressGestureRecognizer*longpress = [[UILongPressGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(displayViewLongPress:)];
        [displayView addGestureRecognizer:longpress];
    }
}

- (void)setupWritingPadSubview
{
    CGFloat jotViewH = 200.f;
    CGFloat highlightRatio = 1.f;
    
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
        displayView.delegate = self;
        //        displayView.writtingPad = writtingPad;
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
    
    [self exportVisiblePageToImage:^(NSURL *urlToImage) {
        NSLog(@"exportVisiblePageToImage %@", urlToImage);

        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlToImage]];

        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    }];
    
//    [writtingPad exportImageTo:[self jotViewStateInkPath] andThumbnailTo:[self jotViewStateThumbPath] andStateTo:[self jotViewStatePlistPath] withThumbnailScale:[[UIScreen mainScreen] scale] onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state) {
//        UIImageWriteToSavedPhotosAlbum(thumb, nil, nil, nil);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Saved" message:@"The JotView's state has been saved to disk, and a full resolution image has been saved to the photo album." preferredStyle:UIAlertControllerStyleAlert];
//            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
//            [self presentViewController:alert animated:YES completion:nil];
//        });
//    }];
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

- (IBAction)themeChange:(id)sender
{
    if (_themeIndex > self.backgroundThemes.count - 1) {
        _themeIndex = 0;
    }
    
    CGRect frame = _background.frame;
    [_background removeFromSuperview];
    _background = nil;
    
    _background = [[self.backgroundThemes[_themeIndex] alloc] initWithFrame:frame
                                                            andOriginalSize:frame.size
                                                              andProperties:@{}];
    [_displayViewContainer addSubview:_background];
    [_displayViewContainer sendSubviewToBack:_background];
    
    _themeIndex++;
}
- (IBAction)addImage:(id)sender
{
    additionalOptionsView.hidden = YES;
    
    [self selectImage];
}

- (IBAction)addText:(id)sender
{
    additionalOptionsView.hidden = YES;
    
    EBWrittingScrapTextView *textScrap = [[EBWrittingScrapTextView alloc] init];
    [_displayViewContainer addSubview:textScrap];
    textScrap.center = CGPointMake(_displayViewContainer.mj_width / 2, _displayViewContainer.mj_height / 2);
    [self letScrap:textScrap bcomeActivate:YES];
    
    EBWrittingScrapTextState *state = [[EBWrittingScrapTextState alloc] initWithScrap:textScrap];
    state.delegate = self;
    [self.scrapStates addObject:state];
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
    
    if (_drawingType == DrawingTypeWritingPad) {
        // Project the stroke on the displayView by ratio
        CGFloat scaleX = _highlightView.bounds.size.width / _jotViewContainer.bounds.size.width;
        CGFloat scaleY = _highlightView.bounds.size.height / _jotViewContainer.bounds.size.height;
        JotElementsRatio ratio = {CGSizeZero, CGPointMake(scaleX, scaleY)};
        [displayView addElements:elements withTexture:[self activePen].textureForStroke ratio:ratio];
    }
    
    return [[self activePen] willAddElements:elements toStroke:stroke fromPreviousElement:previousElement inJotView:writtingPad];
}

- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willBeginStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
    return YES;
}

- (void)willMoveStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willMoveStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)shortStrokeEnding inJotView:(JotView*)writtingPad
{
    // noop
    
}

- (void)didEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad
{
     if (_drawingType == DrawingTypeWritingPad) {
         [displayView.state finishCurrentStroke];
     }
}

- (void)willCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] willCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (void)didCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] didCancelStroke:stroke withCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] setShouldUseVelocity: YES];
    return [[self activePen] colorForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    [[self activePen] setShouldUseVelocity: YES];
    return [[self activePen] widthForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (CGFloat)smoothnessForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)writtingPad {
    return [[self activePen] smoothnessForCoalescedTouch:coalescedTouch fromTouch:touch inJotView:writtingPad];
}

- (void)jotView:(JotView *)jotView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    additionalOptionsView.hidden = YES;
}

- (void)jotView:(JotView *)jotView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self letScrap:_activatedScrapView bcomeActivate:NO];
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


#pragma mark - Export to PDF

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
    
    __block CGContextRef context;
    __block CFDataRef boxData;
    
    [self exportVisiblePage:completionBlock
       startingContextBlock:^CGContextRef(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation) {
        CGRect exportedPageSize = CGRectFromSize(finalExportBounds.size);
        context = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:tmpPagePath]), &exportedPageSize, NULL);
        UIGraphicsPushContext(context);
        
        boxData = CFDataCreate(NULL, (const UInt8*)&exportedPageSize, sizeof(CGRect));
        
        CGPDFContextBeginPage(context, (CFDictionaryRef) @{ @"Rotate": @(defaultRotation),
                                                            (NSString*)kCGPDFContextMediaBox: (__bridge NSData*)boxData });
        
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -finalExportBounds.size.height);
        
        return context;
    } endingContextBlock:^NSURL *(){
        CGPDFContextEndPage(context);
        CGPDFContextClose(context);
        UIGraphicsPopContext();
        CFRelease(context);
        CFRelease(boxData);
        
        return [NSURL fileURLWithPath:tmpPagePath];
    }];
}

- (void)exportVisiblePageToImage:(void (^)(NSURL* urlToImage))completionBlock {
    [self exportVisiblePage:completionBlock
       startingContextBlock:^CGContextRef(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation) {
           
           UIGraphicsBeginImageContextWithOptions(finalExportBounds.size, NO, scale);
           CGContextRef context = UIGraphicsGetCurrentContext();
           
           return context;
       } endingContextBlock:^NSURL *{
           NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];
           
           UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
           [UIImagePNGRepresentation(outputImage) writeToFile:tmpPagePath atomically:YES];
           
           UIGraphicsEndImageContext();
           
           return [NSURL fileURLWithPath:tmpPagePath];
       }];
}

// NOTE: this method will export the image in the same
// orientation as its original background. if there is
// no background, then it will be exported portrait
- (void)exportVisiblePage:(void (^)(NSURL* urlToImage))completionBlock
     startingContextBlock:(CGContextRef (^)(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation))startContextBlock
       endingContextBlock:(NSURL* (^)(void))endContextBlock{
    
//    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_bg" ofType:@"jpg"]];
    UIImage* backgroundImage = nil;
    
    // default the page size to the screen dimensions in PDF ppi.
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    __block CGRect finalExportBounds = CGRectFromSize(screenSize);
//    CGSize backgroundSize = CGSizeZero;
    CGFloat defaultRotation = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    // determine how many times we need to rotate the page content
    // for it to be in the target rotation
    // negative == rotate right
    // positive == rotate left
    NSInteger fullRotation = 0;

    
    // now we know our target rotation, so let's export:
    
    if ([[displayView state] isStateLoaded]) {
        
//        MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
        
        
        [displayView exportToImageOnComplete:^(UIImage* image) {
       
            
            ////////////////////////////////////////////////////////
            //
            // Rotation Step #1
            // calculate the proper export bounds for the page
            // given the input preference for landscape left, landscape
            // right, or portrait
            //
            CGRect preRotationExportBounds = finalExportBounds;
            CGRect postRotationExportBounds = finalExportBounds;
//            while(targetRotation != 0){
//                postRotationExportBounds = CGRectSwap(postRotationExportBounds);
//
//                // move 1 closer to 0
//                targetRotation -= SIGN(fullRotation);
//            }
            //
            ////////////////////////////////////////////////////////
            
            CGContextRef context = startContextBlock(postRotationExportBounds, scale, defaultRotation);
            CGContextSaveThenRestoreForBlock(context, ^{
                // flip
                CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
                
                ////////////////////////////////////////////////////////
                //
                // Rotation Step #2
                // Handle rotating the canvas to adjust for user specified
                // landscape left, landscape right, or portrait rotation
                //
                NSInteger targetRotation = fullRotation;
                
                CGContextTranslateCTM(context, postRotationExportBounds.size.width / 2, postRotationExportBounds.size.height / 2);
                
                while(targetRotation != 0){
                    CGFloat theta = 90.0 * M_PI / 180.0 * -1 * SIGN(fullRotation);
                    CGContextRotateCTM(context, theta);
                    
                    // move 1 closer to 0
                    targetRotation -= SIGN(fullRotation);
                }
                
                CGContextTranslateCTM(context, -preRotationExportBounds.size.width / 2, -preRotationExportBounds.size.height / 2);
                //
                ////////////////////////////////////////////////////////
                
                // guarantee at least a white background
                [[UIColor whiteColor] setFill];
                [[UIBezierPath bezierPathWithRect:finalExportBounds] fill];

                
                
                if (backgroundImage) {
                    // image background
                    CGContextSaveThenRestoreForBlock(context, ^{
                        CGRect rectForImage = CGRectMake(0, 0, finalExportBounds.size.width, finalExportBounds.size.height);
                        [backgroundImage drawInRect:rectForImage];
                    });
                } else if(self.background){
                    [self.background drawInContext:context forSize:finalExportBounds.size];
                }
                
                CGContextSaveThenRestoreForBlock(context, ^{
                    // Scraps
                    // adjust so that (0,0) is the origin of the content rect in the PDF page,
                    // since the PDF may be much taller/wider than our screen
                    CGContextTranslateCTM(context, -finalExportBounds.origin.x, -finalExportBounds.origin.y);
                    
                    //                    for (MMScrapView* scrap in immutableScrapState.scraps) {
                    //                        [self drawScrap:scrap intoContext:context withSize:screenSize];
                    //                    }
                    CGContextSaveThenRestoreForBlock(context, ^{
                        for (EBWrittingScrapState *state in self.scrapStates) {
                            if ([state.scrapView isKindOfClass:[EBWrittingScrapImageView class]]) {
                                EBWrittingScrapImageView *imageScrap = (EBWrittingScrapImageView *)state.scrapView;
                                [imageScrap.image drawInRect:imageScrap.frame];
                            }
                            
                        }
                    });
                });
                
                CGContextSaveThenRestoreForBlock(context, ^{
                    // flip context
                    CGContextTranslateCTM(context, 0, finalExportBounds.size.height);
                    CGContextScaleCTM(context, 1, -1);
                    
                    // adjust to origin
                    CGContextTranslateCTM(context, -finalExportBounds.origin.x, -finalExportBounds.origin.y);
                    
                    // Draw Ink
                    CGContextDrawImage(context, CGRectFromSize(screenSize), [image CGImage]);
                });
                
            });
            
            NSURL* fullyRenderedPDFURL = endContextBlock();
            
//            [pdf closePDF];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock)
                    completionBlock(fullyRenderedPDFURL);
            });
            
        } withScale:[UIScreen mainScreen].scale];
        return;
    }
    
    if (completionBlock)
        completionBlock(nil);
}

- (void)selectImage
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowPickingOriginalPhoto = YES;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    if (photos.count) {
        UIImage *returnImage = [photos firstObject];
     
        EBWrittingScrapImageView *imageScrap = [[EBWrittingScrapImageView alloc] initWithImage:returnImage];
        [_displayViewContainer addSubview:imageScrap];
        imageScrap.center = CGPointMake(_displayViewContainer.mj_width / 2, _displayViewContainer.mj_height / 2);
        [self letScrap:imageScrap bcomeActivate:YES];
        
        EBWrittingScrapImageState *state = [[EBWrittingScrapImageState alloc] initWithScrap:imageScrap];
        state.delegate = self;
        state.index = self.scrapStates.count;
        [self.scrapStates addObject:state];
    }
}

#pragma mark - EBWrittingScrapStateDelegate

- (void)scrapDidBecomeActive:(EBWrittingScrapState *)state
{
    [_displayViewContainer bringSubviewToFront:state.scrapView];
}

- (void)scrapDidResignActive:(EBWrittingScrapState *)state
{
    
    [_displayViewContainer insertSubview:state.scrapView atIndex:[self.scrapStates indexOfObject:state] + 1];
}

- (void)scrapPerformClose:(EBWrittingScrapState *)state
{
    
}


- (void)displayViewLongPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longPress");
        if (_activatedScrapView) {
            [self letScrap:_activatedScrapView bcomeActivate:NO];
        }
        
        CGPoint location = [recognizer locationInView:recognizer.view];
        NSArray* reversedArray = [[self.scrapStates reverseObjectEnumerator] allObjects];
        for (EBWrittingScrapImageState *state in reversedArray) {
            BOOL intersect = CGRectIntersectsRect((CGRect){location, CGSizeMake(0.1, 0.1)}, state.scrapView.frame);
            if (intersect) {
                [self letScrap:state.scrapView bcomeActivate:YES];
                return;
            }
        }
    }
}

- (void)displayViewTap:(UITapGestureRecognizer *)recognizer
{
    [self letScrap:_activatedScrapView bcomeActivate:NO];
}

- (void)letScrap:(EBWrittingScrapView *)scarp bcomeActivate:(BOOL)active
{
    if (active == scarp.active) return;
    if (active) {
        _activatedScrapView = scarp;
        [scarp becomeActivate:YES];
        if (!_scarpResignActiveTap) {
            _scarpResignActiveTap = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(displayViewTap:)];
        }
        [displayView addGestureRecognizer:_scarpResignActiveTap];
    }else {
        _activatedScrapView = nil;
        [scarp becomeActivate:NO];
        [displayView removeGestureRecognizer:_scarpResignActiveTap];
    }
}

@end
