//
//  HKIORegPropertyTool.h
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/5.
//  Copyright © 2020 haoke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
bool getIORegProperties(NSString *path, NSMutableDictionary *_Nullable* _Nullable propertyDictionary);
bool getIORegProperty(NSString *path, NSString *propertyName, CFTypeRef _Nullable * _Nullable property);
bool getIORegString(NSString *service, NSString *name, NSString *_Nullable* _Nonnull value);
NSString *properyToString(id value);
NSString *getByteString(uint32_t uint32Value);
NS_ASSUME_NONNULL_END
