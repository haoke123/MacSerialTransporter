//
//  HKDragView.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/3.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "HKDragView.h"
@interface HKDragView (){
    BOOL isReceivingDrag;  //是否正在拖拽操作
}
//@property (nonatomic, weak) NSImageView *iconView;
@end

@implementation HKDragView
- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if(self){
        [self setupUI];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
        
    [self setupUI];

}
- (void)setupUI{
  //  self.wantsLayer = YES;
    [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
}

#pragma mark - NSDraggingDestination

// 拖拽结束后调用（无论是否拖拽成功）
-(void)draggingEnded:(id<NSDraggingInfo>)sender{
    NSLog(@"-- draggingEnded");
    
    isReceivingDrag = NO;
    [self setNeedsDisplay:YES];
}


// 拖进来但没放下时调用
-(void)draggingExited:(id<NSDraggingInfo>)sender{
    NSLog(@"-- draggingExited");
    
}

/*
 拖动数据进入来时调用
 可以在这里判断数据是什么类型
*/
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    
    isReceivingDrag = YES;
    [self setNeedsDisplay:YES];
    
    NSPasteboard *pb = [sender draggingPasteboard];
    if ([[pb types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

/*
 松开鼠标时会触发，可以在这里处理接收到的数据
*/
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、获取拖动数据中的粘贴板
    NSPasteboard *pb = [sender draggingPasteboard];
    
    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
    NSString  *plist = [[pb propertyListForType:NSFilenamesPboardType] firstObject];
  //  NSString * pp = [pb stringForType:NSFilenamesPboardType];
    NSURL * fileURL = [NSURL fileURLWithPath:plist];
    if(self.delegate && [self.delegate respondsToSelector:@selector(dragviewDidGetFileWithURL:withType:)]){
        [self.delegate dragviewDidGetFileWithURL:fileURL withType:self.type];
    }
    return YES;
}
- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"plist"])
        return YES;
    else
        return NO;
}
/**
 点击view 选择文件
 
 @param event mousedown
 */
- (void)mouseDown:(NSEvent *)event
{
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];//是否能选择文件file
    [panel setCanChooseDirectories:NO];//是否能打开文件夹
    [panel setAllowsMultipleSelection:YES];//是否允许多选file
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *pathString = [panel.URLs.firstObject path];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.delegate && [self.delegate respondsToSelector:@selector(dragviewDidGetFileWithURL:withType:)]){
                    [self.delegate dragviewDidGetFileWithURL:[NSURL fileURLWithPath:pathString] withType:self.type];
                }
            });
            
        }
    }];
}

@end
