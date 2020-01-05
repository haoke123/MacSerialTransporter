//
//  HKConfigUtility.h
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/4.
//  Copyright © 2020 haoke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,ConfigType) {
    ConfigTypeClover   = 0,
    ConfigTypeOpenCore = 1,
    ConfigTypeLocal    = 2,
    ConfigTypeOther    = 3,
    ConfigTypeError    = -1,
};
@interface NSData (StringValue)
- (NSString *) stringValue;
@end

@interface HKConfigUtility : NSObject
@property (nonatomic,readonly,assign) ConfigType type;
@property (nonatomic,readonly,copy)   NSString * MLB;
@property (nonatomic,readonly,strong) NSData   * ROM;
@property (nonatomic,readonly,copy)   NSString * ROMValue;
@property (nonatomic,readonly,copy)   NSString * SerialNumber;
@property (nonatomic,readonly,copy)   NSString * CustomUUID;
@property (nonatomic,readonly,strong) NSURL    * URL;
@property (nonatomic,readonly,strong) NSDictionary * data;
@property (nonatomic,readonly,copy)   NSString     * desString;
- (instancetype) initWithURL:(nullable NSURL * ) URL;
- (void)changeSMBIOSCodeWithConfig:(HKConfigUtility *) config withCompleteHandler:(void (^)(BOOL isSuccess)) handler;

@end

NS_ASSUME_NONNULL_END
