//
//  HKDragView.h
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/3.
//  Copyright © 2020 haoke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HKDragViewDelegate <NSObject>

- (void) dragviewDidGetFileWithURL:(NSURL *) url withType:(NSInteger) type;

@end

@interface HKDragView : NSImageView
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,weak)   id<HKDragViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
