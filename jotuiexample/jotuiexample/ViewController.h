//
//  ViewController.h
//  jotuiexample
//
//  Created by Adam Wulf on 12/8/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JotUI/JotUI.h>
#import "Pen.h"
#import "Marker.h"
#import "Eraser.h"
#import "Highlighter.h"


@interface ViewController : UIViewController <JotViewDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    JotView* displayView;
    JotView* writtingPad; 
    
    Pen* pen;
    Marker* marker;
    Eraser* eraser;
    Highlighter* highlighter;
    
    UIPopoverController* popoverController;
    
    IBOutlet UISegmentedControl* penVsMarkerControl;
    
    IBOutlet UILabel* minAlpha;
    IBOutlet UILabel* maxAlpha;
    IBOutlet UILabel* minWidth;
    IBOutlet UILabel* maxWidth;
    
    IBOutlet UISegmentedControl* minAlphaDelta;
    IBOutlet UISegmentedControl* maxAlphaDelta;
    IBOutlet UISegmentedControl* minWidthDelta;
    IBOutlet UISegmentedControl* maxWidthDelta;
    
    
    IBOutlet UIButton* blueButton;
    IBOutlet UIButton* redButton;
    IBOutlet UIButton* greenButton;
    IBOutlet UIButton* blackButton;
    
    IBOutlet UIView* additionalOptionsView;
    IBOutlet UIButton* palmRejectionButton;
    
    IBOutlet UIButton* settingsButton;
}

@end
