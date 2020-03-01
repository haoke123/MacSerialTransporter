//
//  BDDiskArbitrationSession.h
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>

@class BDDisk;

@protocol BDDiskArbitrationSessionDelegate;

@interface BDDiskArbitrationSession : NSObject
@property (weak) id<BDDiskArbitrationSessionDelegate> delegate;

- (id)initWithDelegate:(id<BDDiskArbitrationSessionDelegate>)delegate;

/**
 * Returns a disk object for a given device path
 */
- (BDDisk *)diskForBSDName:(NSString *)bsdName;
@end

@protocol BDDiskArbitrationSessionDelegate <NSObject>
@optional
- (void)diskDidAppear:(BDDisk *)disk;
- (void)diskDidDisappear:(BDDisk *)disk;
- (void)diskDiskUpdate;
- (BDDisk *)diskForBSDName:(NSString *)bsdName;
@end
