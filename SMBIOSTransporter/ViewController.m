//
//  ViewController.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/3.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "ViewController.h"
#import "HKDragView.h"
#import "SMBIOSKey_F.h"
#import "HKConfigUtility.h"
@interface ViewController ()<HKDragViewDelegate,NSWindowDelegate>
@property (nonatomic,weak) IBOutlet HKDragView  * drapDropImageViewCL;
@property (nonatomic,weak) IBOutlet HKDragView  * drapDropImageViewOC;
@property (nonatomic,weak) IBOutlet NSButton    * runBtn;
@property (nonatomic,weak) IBOutlet NSImageView * bgImageViewCL;
@property (nonatomic,weak) IBOutlet NSImageView * bgImageViewOC;
@property (nonatomic,weak) IBOutlet NSImageView * typeImageViewOC;
@property (nonatomic,weak) IBOutlet NSImageView * typeImageViewCL;
@property (nonatomic,weak) IBOutlet NSTextField * MLBLabel;
@property (nonatomic,weak) IBOutlet NSTextField * ROMLabel;
@property (nonatomic,weak) IBOutlet NSTextField * SNLabel;
@property (nonatomic,strong) HKConfigUtility * oConfig;
@property (nonatomic,strong) HKConfigUtility * cConfig;
@property (nonatomic,strong) HKConfigUtility * localConfig;
@property (weak) IBOutlet NSSegmentedControl *segment;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.drapDropImageViewCL setType:0];
    [self.drapDropImageViewOC setType:1];
    [self.drapDropImageViewCL setDelegate:self];
    [self.drapDropImageViewOC setDelegate:self];
    self.localConfig = [[HKConfigUtility alloc] initWithURL:nil];
    if(self.localConfig.type == ConfigTypeLocal){
        [self dragviewDidGetFileWithURL:nil withType:0];
        [self.segment setAction:@selector(segmentChangeValue:)];
    }else{
        [self.segment setHidden:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reopen) name:@"reopen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openFile:) name:@"openFile" object:nil];
}
- (void) segmentChangeValue:(NSSegmentedControl *) seg{
    NSImageView * dgView = self.typeImageViewCL;
    if(seg.selectedSegment == 0){
      [dgView setImage:[NSImage imageNamed:@"icon-local"]];
        [self changeTextWithConfig:self.localConfig];
    }else{
        if(self.cConfig){
            if(self.cConfig.type == ConfigTypeClover){
                [dgView setImage:[NSImage imageNamed:@"icon-clover"]];
            }else if (self.cConfig.type == ConfigTypeOpenCore){
                [dgView setImage:[NSImage imageNamed:@"icon-opencore"]];
            }else{
                [dgView setImage:[NSImage imageNamed:@"icon-local"]];
            }
        }else{
            [dgView setImage:nil];
            
        }
        [self changeTextWithConfig:self.cConfig];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dragviewDidGetFileWithURL:(NSURL * ) url withType:(NSInteger)type{
    HKConfigUtility * config = nil;
    if(url){
       config = [[HKConfigUtility alloc] initWithURL:url];
        if(config.type == ConfigTypeError||config.type == ConfigTypeOther){
            [self alertMsgWithTitle:@"确定" andMsg:@"不能识别的配置类型"];
            return;
        }
        
    }else{
        [self segmentChangeValue:self.segment];
        [self changeTextWithConfig:self.localConfig];
        [self.segment setSelectedSegment:0];
        [self.typeImageViewCL setImage:[NSImage imageNamed:@"icon-local"]];
        return;
    }
     
    NSImageView * dgView = nil;
    if(type == 0){
        self.cConfig = config;
        dgView = self.typeImageViewCL;
        [self.segment setSelectedSegment:1];
        [self changeTextWithConfig:config];

    }else if (type == 1){
        self.oConfig = config;
        dgView = self.typeImageViewOC;

    }else{
        
    }
    [dgView setImageAlignment:NSImageAlignCenter];
    if(config.type == ConfigTypeClover){
        [dgView setImage:[NSImage imageNamed:@"icon-clover"]];
    }else if (config.type == ConfigTypeOpenCore){
        [dgView setImage:[NSImage imageNamed:@"icon-opencore"]];
    }else{
        [dgView setImage:nil];
    }
}
- (void)changeTextWithConfig:(HKConfigUtility *) config{
    self.MLBLabel.stringValue = [NSString stringWithFormat:@"MLB: %@",config.MLB?:@" <xxxxxxxxxxxxx>"];
    self.ROMLabel.stringValue = [NSString stringWithFormat:@"ROM: %@",config.ROMValue?:@" <xxxxxxxxxxxx>"];
    self.SNLabel.stringValue = [NSString stringWithFormat:@"SerialNumber: %@",config.SerialNumber?:@"<xxxxxxxxxxxx>"];
}
- (void)reopen{
    [self.view.window makeKeyAndOrderFront:self];
}
- (void)openFile:(NSNotification *) noti{
    
   [self.view.window makeKeyAndOrderFront:self];
    NSURL * fileURL = noti.object;
    __weak typeof(self) weakSelf = self;
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = @"打开配置文件";
    [alert addButtonWithTitle:@"作为目标文件"];
    [alert addButtonWithTitle:@"作为源文件"];
    [alert addButtonWithTitle:@"取消"];
    [alert setInformativeText:@"以什么身份打开该文件？"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        NSLog(@"returnCode:%ld",returnCode);
        if(returnCode < 1002)
        [weakSelf dragviewDidGetFileWithURL:fileURL withType:returnCode %1000 ==0 ?1:0];
    }];
}
- (IBAction)runAction:(NSButton *)sender {
    
    NSString * alertMsg = nil;

    if(self.localConfig.type == ConfigTypeError && self.segment.selectedSegment == 0){
        alertMsg = @"本机三码不正确，请选择可配置文件";
        [self alertMsgWithTitle:@"操作错误" andMsg:alertMsg];
        return;
    }
    if(self.segment.selectedSegment == 1 && (self.cConfig.type != ConfigTypeClover && self.cConfig.type != ConfigTypeOpenCore)){
        alertMsg = @"请选择正确的源配置文件";
        [self alertMsgWithTitle:@"操作错误" andMsg:alertMsg];
        return;
    }
    if(self.oConfig == nil){
        alertMsg = @"请选择目标文件";
        [self alertMsgWithTitle:@"操作错误" andMsg:alertMsg];
        return;
    }
    __weak typeof(self) weakself = self;
    
    [self.oConfig changeSMBIOSCodeWithConfig:self.segment.selectedSegment? self.cConfig:self.localConfig withCompleteHandler:^(BOOL isSuccess) {
        NSLog(@"转移成功：%@",isSuccess?@"是":@"否");
        [weakself alertMsgWithTitle:@"三码复制成功" andMsg:[NSString stringWithFormat:@"三码已从%@复制到%@",weakself.segment.selectedSegment? weakself.cConfig.desString:weakself.localConfig.desString,weakself.oConfig.desString]];
    }];
}
- (void)alertMsgWithTitle:(NSString *) alertTitle andMsg:(NSString *) alertMsg{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = alertTitle;
    [alert addButtonWithTitle:@"确定"];
    [alert setInformativeText:alertMsg];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end

