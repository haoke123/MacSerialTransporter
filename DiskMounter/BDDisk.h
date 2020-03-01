//
//  BDDisk.h
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>

extern NSString * const BDDiskErrorDomain;

typedef void(^BDDiskDidMountBlock)(NSURL *mountURL, NSError *error);
typedef void(^BDDiskDidUnmountBlock)(NSError *error);
typedef void(^BDDiskDidEjectBlock)(NSError *error);

@interface BDDisk : NSObject
{
	NSDictionary *info;
	DADiskRef diskRef;
	NSImage *icon;
}

@property (weak, readonly) NSImage *icon;
@property (readonly) BOOL isCurrentSystem;
@property (readonly) BOOL isRemovable;
@property (readonly) BOOL isDiskImage;
@property (weak, readonly) NSString *mediaName;
@property (weak, readonly) NSString *realDevicePath;
@property (readonly) BOOL isWholeDisk;
@property (readonly) BOOL isMountable;
@property (readonly) BOOL isMounted;
@property (readonly) BOOL isNetwork;

@property (weak, readonly) NSDictionary *diskDescription;
@property (weak, readonly) NSString *BSDName;
@property (weak, readonly) NSString *devicePath;
@property (weak, readonly) NSString *volumeName;
@property (weak, readonly) NSURL *volumeURL;
@property (weak, readonly) NSString *volumePath;
@property (weak, readonly) NSString *filesystem;
@property (weak, readonly) NSString *volumeUUIDString;
@property (readonly) NSInteger mediaSize;

/**
 * Creates a new disk given a DADiskRef
 * @see BDDiskArbitrationSession for ways to create a disk from path or device
 */
+ (BDDisk *)diskWithRef:(DADiskRef)disk;
- (id)initWithDiskRef:(DADiskRef)disk;

/**
 * Mounts the volume, or all volumes if it's a whole disk
 * Does nothing if an mount is already underway
 */
- (void)mountWithCompletionHandler:(BDDiskDidMountBlock)handler;

/**
 * Unmounts the volume or all volumes associated with the disk if it's a whole disk
 * Does nothing if an unmount is already underway
 */
- (void)unmountWithCompletionHandler:(BDDiskDidUnmountBlock)handler;
- (void)unmountWithCompletionHandler:(BDDiskDidUnmountBlock)handler force:(BOOL)force;

/**
 * Ejects volume or disk
 * Returns NO if volume can't be ejected (like internal disk)
 */
- (BOOL)ejectWithCompletionHandler:(BDDiskDidEjectBlock)handler;

@end
