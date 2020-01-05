//
//  HKIORegPropertyTool.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/5.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "HKIORegPropertyTool.h"

bool getIORegProperties(NSString *path, NSMutableDictionary **propertyDictionary)
{
    *propertyDictionary = nil;
    io_registry_entry_t device = IORegistryEntryFromPath(kIOMasterPortDefault, [path UTF8String]);
    
    if (device == MACH_PORT_NULL)
        return false;
    
    CFMutableDictionaryRef propertyDictionaryRef = 0;
    
    kern_return_t kr = IORegistryEntryCreateCFProperties(device, &propertyDictionaryRef, kCFAllocatorDefault, kNilOptions);
    
    if (kr == KERN_SUCCESS)
        *propertyDictionary = (__bridge NSMutableDictionary *)propertyDictionaryRef;
    
    IOObjectRelease(device);
    
    return (*propertyDictionary != nil);
}
bool getIORegProperty(NSString *path, NSString *propertyName, CFTypeRef *property)
{
    *property = nil;
    io_registry_entry_t device = IORegistryEntryFromPath(kIOMasterPortDefault, [path UTF8String]);
    
    if (device == MACH_PORT_NULL)
        return false;
    
    *property = IORegistryEntryCreateCFProperty(device, (__bridge CFStringRef)propertyName, kCFAllocatorDefault, kNilOptions);
    
    IOObjectRelease(device);
    
    return (*property != nil);
}
NSString *properyToString(id value)
{
    if (value == nil)
        return @"???";
    
    if ([value isKindOfClass:[NSString class]])
        return value;
    else if ([value isKindOfClass:[NSData class]])
    {
        NSData *data = (NSData *)value;
        return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding] ;
    }
    
    return @"???";
}
NSString *getByteString(uint32_t uint32Value)
{
    return [NSString stringWithFormat:@"0x%02X, 0x%02X, 0x%02X, 0x%02X", uint32Value & 0xFF, (uint32Value >> 8) & 0xFF, (uint32Value >> 16) & 0xFF, (uint32Value >> 24) & 0xFF];
}

