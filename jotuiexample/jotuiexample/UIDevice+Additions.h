//
//  UIDevice+Additions.h
//  yitianyishu
//
//  Created by Maurice on 2017/12/26.
//  Copyright © 2017年 Qihui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Additions)

+ (NSDictionary *)deviceInfo;

+ (NSString *)deviceInfoStr;

+ (NSString *)deviceName;

+ (NSString *)appVersion;
    
+ (NSString *)deviceID;

+ (CGFloat)ppi;
+ (CGFloat)ppc;


@end
