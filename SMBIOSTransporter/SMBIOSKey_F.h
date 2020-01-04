//
//  SMBIOSKey_F.h
//  SMBiosTrancer
//
//  Created by 豪客 on 2020/1/2.
//  Copyright © 2020 豪客. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NSString *SMBIOSKey  NS_STRING_ENUM;

FOUNDATION_EXPORT SMBIOSKey const kRtVariables;
FOUNDATION_EXPORT SMBIOSKey const kROM;//ROM

FOUNDATION_EXPORT SMBIOSKey const kSMBIOS;
FOUNDATION_EXPORT SMBIOSKey const kBoardSerialNumber;//BoardSerialNumber
FOUNDATION_EXPORT SMBIOSKey const kSerialNumber;//SerialNumber

FOUNDATION_EXPORT SMBIOSKey const kSystemParameters;
FOUNDATION_EXPORT SMBIOSKey const kCustomUUID;

FOUNDATION_EXPORT SMBIOSKey const kPlatformInfo;// PlatformInfo
FOUNDATION_EXPORT SMBIOSKey const kGeneric;// Generic
FOUNDATION_EXPORT SMBIOSKey const kMLB;//
FOUNDATION_EXPORT SMBIOSKey const kSystemSerialNumber;//
FOUNDATION_EXPORT SMBIOSKey const kSystemUUID;//

NS_ASSUME_NONNULL_END
