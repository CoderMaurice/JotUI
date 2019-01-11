//
//  UIDevice+Additions.m
//  yitianyishu
//
//  Created by Maurice on 2017/12/26.
//  Copyright © 2017年 Qihui. All rights reserved.
//

#import "UIDevice+Additions.h"
//#import "NSString+Additions.h"
#import "sys/utsname.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
//#import "MKeychainDeviceID.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat _DEVICEPPI;
static NSString * _DEVICENAME;
static NSDictionary *_DEVICEINFO;
static NSString *_DEVICEINFOStr;

@implementation UIDevice (Additions)

+ (NSString *)deviceInfoStr
{
    if (!_DEVICEINFOStr) {

        NSDictionary *deviceInfo = [UIDevice deviceInfo];
        
        NSMutableString *infoStr = [[NSMutableString alloc] init];
        
        [infoStr appendString:@"{"];
        for (NSString *infoKeys in [deviceInfo allKeys]) {
            NSString *value = [deviceInfo valueForKey:infoKeys];
            [infoStr appendString:infoKeys];
            [infoStr appendString:@":"];
            [infoStr appendString:value];
            [infoStr appendString:@","];
        }
        [infoStr deleteCharactersInRange:NSMakeRange([infoStr length] - 1, 1)];
        [infoStr appendString:@"}"];
        
        _DEVICEINFOStr = infoStr;
    }
    return _DEVICEINFOStr;
}

//static NSString * DeviceID;

//+ (NSDictionary *)deviceInfo
//{
//    if (!_DEVICEINFO) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        NSString *deviceMobile = [self deviceName];
//        NSString *deviceName = [self currentDevice].name;
//        NSString *appVersion = [self appVersion];
//        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
//        if (![deviceMobile isStringEmpty]) dic[@"deviceMobile"] = deviceMobile;
//        if (![deviceName isStringEmpty]) dic[@"deviceName"] = deviceName;
//        if (![appVersion isStringEmpty]) dic[@"appVersion"] = appVersion;
//        if (![systemVersion isStringEmpty]) dic[@"systemVersion"] = systemVersion;
//        dic[@"device"] = @"iOS";
//        dic[@"device_token"] = [self deviceID];
//        _DEVICEINFO = [NSDictionary dictionaryWithDictionary:dic];
//    }
//    return _DEVICEINFO;
//}
//
//+ (NSString *)deviceID
//{
//    if (!DeviceID.length) {
//        DeviceID = [MKeychainDeviceID getDeviceID];
//    }
//    return DeviceID;
//}

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

// 获取设备型号然后手动转化为对应名称
+ (NSString *)deviceName
{
    if (!_DEVICENAME.length) {
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        if ([deviceString isEqualToString:@"i386"])         _DEVICENAME = @"Simulator";
        if ([deviceString isEqualToString:@"x86_64"])       _DEVICENAME = @"Simulator";
        
        if ([deviceString isEqualToString:@"iPhone3,1"])    _DEVICENAME = @"iPhone4";
        if ([deviceString isEqualToString:@"iPhone3,2"])    _DEVICENAME = @"iPhone4";
        if ([deviceString isEqualToString:@"iPhone3,3"])    _DEVICENAME = @"iPhone4";
        if ([deviceString isEqualToString:@"iPhone4,1"])    _DEVICENAME = @"iPhone4S";
        if ([deviceString isEqualToString:@"iPhone5,1"])    _DEVICENAME = @"iPhone5";
        if ([deviceString isEqualToString:@"iPhone5,2"])    _DEVICENAME = @"iPhone5"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone5,3"])    _DEVICENAME = @"iPhone5c"; // (GSM)
        if ([deviceString isEqualToString:@"iPhone5,4"])    _DEVICENAME = @"iPhone5c"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone6,1"])    _DEVICENAME = @"iPhone5s"; // (GSM)
        if ([deviceString isEqualToString:@"iPhone6,2"])    _DEVICENAME = @"iPhone5s"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone7,1"])    _DEVICENAME = @"iPhone6Plus";
        if ([deviceString isEqualToString:@"iPhone7,2"])    _DEVICENAME = @"iPhone6";
        if ([deviceString isEqualToString:@"iPhone8,1"])    _DEVICENAME = @"iPhone6s";
        if ([deviceString isEqualToString:@"iPhone8,2"])    _DEVICENAME = @"iPhone6sPlus";
        if ([deviceString isEqualToString:@"iPhone8,4"])    _DEVICENAME = @"iPhoneSE";
        // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
        if ([deviceString isEqualToString:@"iPhone9,1"])    _DEVICENAME = @"iPhone7"; // 国行、日版、港行
        if ([deviceString isEqualToString:@"iPhone9,2"])    _DEVICENAME = @"iPhone7Plus"; // 港行、国行
        if ([deviceString isEqualToString:@"iPhone9,3"])    _DEVICENAME = @"iPhone7";// 美版、台版
        if ([deviceString isEqualToString:@"iPhone9,4"])    _DEVICENAME = @"iPhone7Plus"; // 美版、台版
        if ([deviceString isEqualToString:@"iPhone10,1"])   _DEVICENAME = @"iPhone8"; // 国行(A1863)、日行(A1906)
        if ([deviceString isEqualToString:@"iPhone10,4"])   _DEVICENAME = @"iPhone8"; // 美版(Global/A1905)
        if ([deviceString isEqualToString:@"iPhone10,2"])   _DEVICENAME = @"iPhone8Plus"; // 国行(A1864)、日行(A1898)
        if ([deviceString isEqualToString:@"iPhone10,5"])   _DEVICENAME = @"iPhone8Plus"; // 美版(Global/A1897)
        if ([deviceString isEqualToString:@"iPhone10,3"])   _DEVICENAME = @"iPhoneX"; // 国行(A1865)、日行(A1902)
        if ([deviceString isEqualToString:@"iPhone10,6"])   _DEVICENAME = @"iPhoneX"; // 美版(Global/A1901)
        if ([deviceString isEqualToString:@"iPhone11,4"])   _DEVICENAME = @"iPhoneXsMax";
        if ([deviceString isEqualToString:@"iPhone11,6"])   _DEVICENAME = @"iPhoneXsMax";
        if ([deviceString isEqualToString:@"iPhone11,2"])   _DEVICENAME = @"iPhoneXs";
        if ([deviceString isEqualToString:@"iPhone11,8"])   _DEVICENAME = @"iPhoneXr";
        
        
        if ([deviceString isEqualToString:@"iPod1,1"])      _DEVICENAME = @"iPodTouch1G";
        if ([deviceString isEqualToString:@"iPod2,1"])      _DEVICENAME = @"iPodTouch2G";
        if ([deviceString isEqualToString:@"iPod3,1"])      _DEVICENAME = @"iPodTouch3G";
        if ([deviceString isEqualToString:@"iPod4,1"])      _DEVICENAME = @"iPodTouch4G";
        if ([deviceString isEqualToString:@"iPod5,1"])      _DEVICENAME = @"iPodTouch"; // (5 Gen)
        
        if ([deviceString isEqualToString:@"iPad1,1"])      _DEVICENAME = @"iPad";
        if ([deviceString isEqualToString:@"iPad1,2"])      _DEVICENAME = @"iPad3G";
        if ([deviceString isEqualToString:@"iPad2,1"])      _DEVICENAME = @"iPad2"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad2,2"])      _DEVICENAME = @"iPad2";
        if ([deviceString isEqualToString:@"iPad2,3"])      _DEVICENAME = @"iPad2"; // (CDMA)
        if ([deviceString isEqualToString:@"iPad2,4"])      _DEVICENAME = @"iPad2";
        if ([deviceString isEqualToString:@"iPad2,5"])      _DEVICENAME = @"iPadMini"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad2,6"])      _DEVICENAME = @"iPadMini";
        if ([deviceString isEqualToString:@"iPad2,7"])      _DEVICENAME = @"iPadMini"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad3,1"])      _DEVICENAME = @"iPad3"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad3,2"])      _DEVICENAME = @"iPad3"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad3,3"])      _DEVICENAME = @"iPad3";
        if ([deviceString isEqualToString:@"iPad3,4"])      _DEVICENAME = @"iPad4"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad3,5"])      _DEVICENAME = @"iPad4";
        if ([deviceString isEqualToString:@"iPad3,6"])      _DEVICENAME = @"iPad4"; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad4,1"])      _DEVICENAME = @"iPadAir"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad4,2"])      _DEVICENAME = @"iPadAir"; // (Cellular)
        if ([deviceString isEqualToString:@"iPad4,4"])      _DEVICENAME = @"iPadMini2"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad4,5"])      _DEVICENAME = @"iPadMini2"; // (Cellular)
        if ([deviceString isEqualToString:@"iPad4,6"])      _DEVICENAME = @"iPadMini2";
        if ([deviceString isEqualToString:@"iPad4,7"])      _DEVICENAME = @"iPadMini3";
        if ([deviceString isEqualToString:@"iPad4,8"])      _DEVICENAME = @"iPadMini3";
        if ([deviceString isEqualToString:@"iPad4,9"])      _DEVICENAME = @"iPadMini3";
        if ([deviceString isEqualToString:@"iPad5,1"])      _DEVICENAME = @"iPadMini4"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad5,2"])      _DEVICENAME = @"iPadMini4 "; // (LTE)
        if ([deviceString isEqualToString:@"iPad5,3"])      _DEVICENAME = @"iPadAir2";
        if ([deviceString isEqualToString:@"iPad5,4"])      _DEVICENAME = @"iPadAir2";
        if ([deviceString isEqualToString:@"iPad6,3"])      _DEVICENAME = @"iPadPro9Inch";
        if ([deviceString isEqualToString:@"iPad6,4"])      _DEVICENAME = @"iPadPro9Inch";
        if ([deviceString isEqualToString:@"iPad6,7"])      _DEVICENAME = @"iPadPro12Inch";
        if ([deviceString isEqualToString:@"iPad6,8"])      _DEVICENAME = @"iPadPro12Inch";
        if ([deviceString isEqualToString:@"iPad6,11"])    _DEVICENAME = @"iPad5"; // (WiFi)
        if ([deviceString isEqualToString:@"iPad6,12"])    _DEVICENAME = @"iPad5"; // (Cellular)
        if ([deviceString isEqualToString:@"iPad7,1"])     _DEVICENAME = @"iPadPro12Inch2"; // inch 2nd gen (WiFi)
        if ([deviceString isEqualToString:@"iPad7,2"])     _DEVICENAME = @"iPadPro12Inch2"; // inch 2nd gen (Cellular)
        if ([deviceString isEqualToString:@"iPad7,3"])     _DEVICENAME = @"iPadPro10Inch"; // inch (WiFi)
        if ([deviceString isEqualToString:@"iPad7,4"])     _DEVICENAME = @"iPadPro10Inch"; // inch (Cellular)
        if ([deviceString isEqualToString:@"iPad7.5"])     _DEVICENAME = @"iPad6";
        if ([deviceString isEqualToString:@"iPad7.6"])     _DEVICENAME = @"iPad6";
        if ([deviceString isEqualToString:@"iPad8.1"])     _DEVICENAME = @"iPadPro11Inch";
        if ([deviceString isEqualToString:@"iPad8.2"])     _DEVICENAME = @"iPadPro11Inch";
        if ([deviceString isEqualToString:@"iPad8.3"])     _DEVICENAME = @"iPadPro11Inch";
        if ([deviceString isEqualToString:@"iPad8.4"])     _DEVICENAME = @"iPadPro11Inch";
        if ([deviceString isEqualToString:@"iPad8.5"])     _DEVICENAME = @"iPadPro12Inch3";
        if ([deviceString isEqualToString:@"iPad8.6"])     _DEVICENAME = @"iPadPro12Inch3";
        if ([deviceString isEqualToString:@"iPad8.7"])     _DEVICENAME = @"iPadPro12Inch3";
        if ([deviceString isEqualToString:@"iPad8.8"])     _DEVICENAME = @"iPadPro12Inch3";
        
        if ([deviceString isEqualToString:@"AppleTV2,1"])    _DEVICENAME = @"AppleTV2";
        if ([deviceString isEqualToString:@"AppleTV3,1"])    _DEVICENAME = @"AppleTV3";
        if ([deviceString isEqualToString:@"AppleTV3,2"])    _DEVICENAME = @"AppleTV3";
        if ([deviceString isEqualToString:@"AppleTV5,3"])    _DEVICENAME = @"AppleTV4";
        
        if (!_DEVICENAME.length) _DEVICENAME = deviceString;
        
    }
    
    return _DEVICENAME;
}

+ (CGFloat)ppc {
    return [UIDevice ppi] / 2.54;
}

+ (CGFloat)ppi
{
    if (!_DEVICEPPI) {
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        if ([deviceString isEqualToString:@"iPhone3,1"])    _DEVICEPPI = 330.f;
        if ([deviceString isEqualToString:@"iPhone3,2"])    _DEVICEPPI = 330.f;
        if ([deviceString isEqualToString:@"iPhone3,3"])    _DEVICEPPI = 330.f;
        if ([deviceString isEqualToString:@"iPhone4,1"])    _DEVICEPPI = 330.f;
        if ([deviceString isEqualToString:@"iPhone5,1"])    _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPhone5,2"])    _DEVICEPPI = 326.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone5,3"])    _DEVICEPPI = 326.f;// (GSM)
        if ([deviceString isEqualToString:@"iPhone5,4"])    _DEVICEPPI = 326.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone6,1"])    _DEVICEPPI = 326.f; // (GSM)
        if ([deviceString isEqualToString:@"iPhone6,2"])    _DEVICEPPI = 326.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPhone7,1"])    _DEVICEPPI = 401.f;
        if ([deviceString isEqualToString:@"iPhone7,2"])    _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPhone8,1"])    _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPhone8,2"])    _DEVICEPPI = 401.f;
        if ([deviceString isEqualToString:@"iPhone8,4"])    _DEVICEPPI = 326.f;
        // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
        if ([deviceString isEqualToString:@"iPhone9,1"])    _DEVICEPPI = 326.f;; // 国行、日版、港行
        if ([deviceString isEqualToString:@"iPhone9,2"])    _DEVICEPPI = 401.f;; // 港行、国行
        if ([deviceString isEqualToString:@"iPhone9,3"])    _DEVICEPPI = 326.f;;// 美版、台版
        if ([deviceString isEqualToString:@"iPhone9,4"])    _DEVICEPPI = 401.f; // 美版、台版
        if ([deviceString isEqualToString:@"iPhone10,1"])   _DEVICEPPI = 326.f;; // 国行(A1863)、日行(A1906)
        if ([deviceString isEqualToString:@"iPhone10,4"])   _DEVICEPPI = 326.f;; // 美版(Global/A1905)
        if ([deviceString isEqualToString:@"iPhone10,2"])   _DEVICEPPI = 401.f; // 国行(A1864)、日行(A1898)
        if ([deviceString isEqualToString:@"iPhone10,5"])   _DEVICEPPI = 401.f; // 美版(Global/A1897)
        if ([deviceString isEqualToString:@"iPhone10,3"])   _DEVICEPPI = 463.f; // 国行(A1865)、日行(A1902)
        if ([deviceString isEqualToString:@"iPhone10,6"])   _DEVICEPPI = 463.f;; // 美版(Global/A1901)
        if ([deviceString isEqualToString:@"iPhone11,4"])   _DEVICEPPI = 456.f;
        if ([deviceString isEqualToString:@"iPhone11,6"])   _DEVICEPPI = 456.f;;
        if ([deviceString isEqualToString:@"iPhone11,2"])   _DEVICEPPI = 463.f;
        if ([deviceString isEqualToString:@"iPhone11,8"])   _DEVICEPPI = 324.f;
        
        if ([deviceString isEqualToString:@"iPad1,1"])      _DEVICEPPI = 132.f;
        if ([deviceString isEqualToString:@"iPad1,2"])      _DEVICEPPI = 132.f;
        if ([deviceString isEqualToString:@"iPad2,1"])      _DEVICEPPI = 132.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad2,2"])      _DEVICEPPI = 132.f;
        if ([deviceString isEqualToString:@"iPad2,3"])      _DEVICEPPI = 132.f; // (CDMA)
        if ([deviceString isEqualToString:@"iPad2,4"])      _DEVICEPPI = 132.f;
        if ([deviceString isEqualToString:@"iPad2,5"])      _DEVICEPPI = 162.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad2,6"])      _DEVICEPPI = 162.f;
        if ([deviceString isEqualToString:@"iPad2,7"])      _DEVICEPPI = 162.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad3,1"])      _DEVICEPPI = 264.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad3,2"])      _DEVICEPPI = 264.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad3,3"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad3,4"])      _DEVICEPPI = 264.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad3,5"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad3,6"])      _DEVICEPPI = 264.f; // (GSM+CDMA)
        if ([deviceString isEqualToString:@"iPad4,1"])      _DEVICEPPI = 264.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad4,2"])      _DEVICEPPI = 264.f; // (Cellular)
        if ([deviceString isEqualToString:@"iPad4,4"])      _DEVICEPPI = 326.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad4,5"])      _DEVICEPPI = 326.f; // (Cellular)
        if ([deviceString isEqualToString:@"iPad4,6"])      _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPad4,7"])      _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPad4,8"])      _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPad4,9"])      _DEVICEPPI = 326.f;
        if ([deviceString isEqualToString:@"iPad5,1"])      _DEVICEPPI = 326.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad5,2"])      _DEVICEPPI = 326.f; // (LTE)
        if ([deviceString isEqualToString:@"iPad5,3"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad5,4"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad6,3"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad6,4"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad6,7"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad6,8"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad6,11"])     _DEVICEPPI = 264.f; // (WiFi)
        if ([deviceString isEqualToString:@"iPad6,12"])     _DEVICEPPI = 264.f; // (Cellular)
        if ([deviceString isEqualToString:@"iPad7,1"])      _DEVICEPPI = 264.f; // inch 2nd gen (WiFi)
        if ([deviceString isEqualToString:@"iPad7,2"])      _DEVICEPPI = 264.f; // inch 2nd gen (Cellular)
        if ([deviceString isEqualToString:@"iPad7,3"])      _DEVICEPPI = 264.f; // inch (WiFi)
        if ([deviceString isEqualToString:@"iPad7,4"])      _DEVICEPPI = 264.f; // inch (Cellular)
        if ([deviceString isEqualToString:@"iPad7.5"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad7.6"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.1"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.2"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.3"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.4"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.5"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.6"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.7"])      _DEVICEPPI = 264.f;
        if ([deviceString isEqualToString:@"iPad8.8"])      _DEVICEPPI = 264.f;
        
        if (!_DEVICEPPI) _DEVICEPPI = 264;

    }
    
    return _DEVICEPPI;
}




@end
