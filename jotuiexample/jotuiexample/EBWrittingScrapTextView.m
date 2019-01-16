//
//  EBWrittingScrapTextView.m
//  jotuiexample
//
//  Created by Maurice on 2019/1/16.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "EBWrittingScrapTextView.h"
#import "RichTextEditor.h"

#define kDefaultSize CGSizeMake(400, 150)

@interface EBWrittingScrapTextView ()<UITextViewDelegate, RichTextEditorDataSource>

@end

@implementation EBWrittingScrapTextView

- (instancetype)init
{
    self = [super initWithFrame:(CGRect){CGPointZero, kDefaultSize}];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
//    UITextView *textView = [[UITextView alloc] init];
//    textView.font = [UIFont systemFontOfSize:20];
//    textView.text = @"你还好吗";
    
    RichTextEditor *editor = [[RichTextEditor alloc] init];
    editor.dataSource = self;
    editor.delegate = self;
    
    self.contentView = editor;
    self.preventsPositionOutsideSuperview = NO;
    self.translucencySticker = NO;
    self.borderColor = MCOLOR(225, 73, 59, 1);
    self.borderWidth = 2.f;
    
    [editor becomeFirstResponder];
}

- (RichTextEditorFeature)featuresEnabledForRichTextEditor:(RichTextEditor *)richTextEditor
{
    return RichTextEditorFeatureFontSize | RichTextEditorFeatureFont | RichTextEditorFeatureAll;
}

@end
