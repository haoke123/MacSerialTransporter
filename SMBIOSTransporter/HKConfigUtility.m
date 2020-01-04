//
//  HKConfigUtility.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/4.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "HKConfigUtility.h"
#import "SMBIOSKey_F.h"
@implementation HKConfigUtility
- (instancetype)initWithURL:(NSURL *) URL{
    self = [super init];
    if(self){
        _URL = URL;
        _type = [self checkConfigType:URL];
        _data = [NSDictionary dictionaryWithContentsOfURL:URL];
        [self setupSMBIOSCode];
        
    }
    return self;
}
- (NSString *)getFileNameWithURL:(NSURL *) URL{
    NSString * urlString = URL.absoluteString;
    NSArray * arr = [urlString componentsSeparatedByString:@"/"];
    return arr.lastObject;
}
- (ConfigType)checkConfigType:(NSURL *) configURL{
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfURL:configURL];
    if(dict == nil){
        return ConfigTypeError;
    }else if (dict.allKeys.count <3){
        return ConfigTypeOther;
    }else if (![dict isKindOfClass:[NSDictionary class]]){
        return ConfigTypeOther;
    }else if ([dict objectForKey:kPlatformInfo]){
        _desString = [NSString stringWithFormat:@"OpenCore/%@",[self getFileNameWithURL:_URL]];
        return ConfigTypeOpenCore;
    }else if ([dict objectForKey:kSystemParameters]){
        _desString = [NSString stringWithFormat:@"Clover/%@",[self getFileNameWithURL:_URL]];
        return ConfigTypeClover;
    }else{
        return ConfigTypeOther;
    }
}
- (BOOL)setupSMBIOSCode{
    
    if(_type == ConfigTypeClover){
       
        _MLB = [_data[kSMBIOS] objectForKey:kBoardSerialNumber];
        _ROM = [_data[kRtVariables] objectForKey:kROM];
        _ROMValue = [self HexStringWithData:_ROM];
        _SerialNumber = [_data[kSMBIOS] objectForKey:kSerialNumber];
        _CustomUUID = [_data[kSystemParameters] objectForKey:kCustomUUID];
        return YES;
    }else if (_type == ConfigTypeOpenCore){
        NSDictionary * cData = [NSDictionary dictionaryWithContentsOfURL:_URL];
        NSDictionary * platform = [cData objectForKey:kPlatformInfo];
        NSDictionary * Generic  = [platform objectForKey:kGeneric];
        _MLB = [Generic objectForKey:kMLB];
        _ROM = [Generic objectForKey:kROM];
        _ROMValue = [self HexStringWithData:_ROM];
        _SerialNumber = [Generic objectForKey:kSystemSerialNumber];;
        _CustomUUID   = [Generic objectForKey:kSystemUUID];
        return YES;
    }else{
        return NO;
    }
}
- (void)changeSMBIOSCodeWithConfig:(HKConfigUtility *) config withCompleteHandler:(void (^)(BOOL isSuccess)) handler{
    if(_type == ConfigTypeClover){
        NSMutableDictionary * oData = [_data mutableCopy];
        NSMutableDictionary * RtVariablesDict = [oData objectForKey:kRtVariables];
        [RtVariablesDict setObject:config.ROM forKey:kROM];
        NSMutableDictionary * SMBIOSDict = [oData objectForKey:kSMBIOS];
        [SMBIOSDict setObject:config.SerialNumber forKey:kSystemSerialNumber];
        [SMBIOSDict setObject:config.MLB forKey:kBoardSerialNumber];
        NSMutableDictionary * SystemParameters = [oData objectForKey:kSystemParameters];
        [SystemParameters setObject:config.CustomUUID forKey:kCustomUUID];
        [oData setObject:RtVariablesDict forKey:kRtVariables];
        [oData setObject:SMBIOSDict forKey:kSMBIOS];
        [oData setObject:SystemParameters forKey:kSystemParameters];
        [oData writeToURL:self.URL error:nil];
        handler(YES);
    }else if (_type == ConfigTypeOpenCore){
        NSMutableDictionary * oData = [_data mutableCopy];
        NSMutableDictionary * oDataPiGemic = [NSMutableDictionary dictionaryWithDictionary:[_data[kPlatformInfo] objectForKey:kGeneric]];
        [oDataPiGemic setObject:config.MLB forKey:kMLB];
        [oDataPiGemic setObject:config.ROM forKey:kROM];
        [oDataPiGemic setObject:config.SerialNumber forKey:kSystemSerialNumber];
        [oDataPiGemic setObject:config.CustomUUID forKey:kSystemUUID];
        NSMutableDictionary * oDataPi = [NSMutableDictionary dictionaryWithDictionary:oData[kPlatformInfo]];
        [oDataPi setObject:oDataPiGemic forKey:kGeneric];
        [oData setObject:oDataPi forKey:kPlatformInfo];
        [oData writeToURL:self.URL error:nil];
        handler(YES);
    }else{
        
    }
}
- (NSString *)HexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    return hexStr;
}
@end
