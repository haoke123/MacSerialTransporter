//
//  ViewController.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/3.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "MainViewController.h"
#import "HKDragView.h"
#import "SMBIOSKey_F.h"
#import "HKConfigUtility.h"
#import "BDDiskArbitrationSession.h"
#import "BDDisk.h"
#import "HKIORegPropertyTool.h"
@interface MainViewController ()<HKDragViewDelegate,NSWindowDelegate,BDDiskArbitrationSessionDelegate>
@property (nonatomic,weak) IBOutlet HKDragView  * drapDropImageViewCL;
@property (nonatomic,weak) IBOutlet HKDragView  * drapDropImageViewOC;
@property (nonatomic,weak) IBOutlet NSButton    * runBtn;
@property (nonatomic,weak) IBOutlet NSImageView * bgImageViewCL;
@property (nonatomic,weak) IBOutlet NSImageView * bgImageViewOC;
@property (nonatomic,weak) IBOutlet NSImageView * typeImageViewOC;
@property (nonatomic,weak) IBOutlet NSImageView * typeImageViewCL;
@property (weak) IBOutlet NSTextField *productModel;
@property (nonatomic,weak) IBOutlet NSTextField * MLBLabel;
@property (nonatomic,weak) IBOutlet NSTextField * ROMLabel;
@property (nonatomic,weak) IBOutlet NSTextField * SNLabel;
@property (nonatomic,strong) HKConfigUtility * oConfig;
@property (nonatomic,strong) HKConfigUtility * cConfig;
@property (nonatomic,strong) HKConfigUtility * localConfig;
@property (nonatomic,strong) BDDiskArbitrationSession * diskSession;
@property (weak) IBOutlet NSButton *diskOpenBtn;
@property (weak) IBOutlet NSButton *diskMountBtn;
@property (nonatomic,strong) NSMutableArray * allDisks;
@property (weak) IBOutlet NSSegmentedControl *segment;
@property (weak) IBOutlet NSPopUpButton *diskEFIButton;
@property (nonatomic,assign) BOOL isFirstLoad;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.drapDropImageViewCL setType:0];
    [self.drapDropImageViewOC setType:1];
    [self.drapDropImageViewCL setDelegate:self];
    [self.drapDropImageViewOC setDelegate:self];
    NSString * productModel = nil;
    if (getIORegString(@"IOPlatformExpertDevice", @"model", &productModel))
        self.productModel.stringValue = productModel;
    self.localConfig = [[HKConfigUtility alloc] initWithURL:nil];
    
    if(self.localConfig.type == ConfigTypeLocal){
        [self dragviewDidGetFileWithURL:nil withType:0];
        [self.segment setAction:@selector(segmentChangeValue:)];
    }else{
        [self.segment setHidden:YES];
    }
    [self.diskEFIButton setTitle:@"--"];
    [self.diskEFIButton setAction:@selector(efiSelect:)];
    self.diskSession = [[BDDiskArbitrationSession alloc] initWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reopen) name:@"reopen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openFile:) name:@"openFile" object:nil];
}
- (IBAction)helpBtnClick:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://suo.im/5JR7my"]];
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
    self.MLBLabel.stringValue = [NSString stringWithFormat:@"MLB: %@",config.MLB?:@" <XXXXXXXXXXXX>"];
    self.ROMLabel.stringValue = [NSString stringWithFormat:@"ROM: %@",config.ROMValue?:@" <XXXXXXXXXXXX>"];
    self.SNLabel.stringValue = [NSString stringWithFormat:@"SerialNumber: %@",config.SerialNumber?:@"<XXXXXXXXXXXX>"];
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

- (void) diskDidAppear:(BDDisk *)disk{
    if([disk.mediaName isEqualToString:@"EFI System Partition"]){
        [self.allDisks addObject:disk];
        [self.diskEFIButton addItemWithTitle:[self resumString:[disk.diskDescription objectForKey:@"DADeviceModel"]]];
        if(!_isFirstLoad){
            _isFirstLoad = YES;
            [self checkDiskStatus:disk];
            
        }
    }
}
- (void) diskDidDisappear:(BDDisk *)disk{
    if([disk.mediaName isEqualToString:@"EFI System Partition"]){
        [self.allDisks removeObject:disk];
        [self.diskEFIButton removeItemWithTitle:[self resumString:[disk.diskDescription objectForKey:@"DADeviceModel"]]];
    }
}
- (void) diskDiskUpdate{
    NSMutableArray * tarArr = [[NSMutableArray alloc] init];
    for (BDDisk * disk in self.allDisks) {
        BDDisk * disk2 = [self.diskSession diskForBSDName:disk.BSDName];
        [tarArr addObject:disk2];
    }
    [self.allDisks removeAllObjects];
    self.allDisks = nil;
    self.allDisks = tarArr;
   NSInteger currentIndex = [self.diskEFIButton indexOfSelectedItem];
    if(currentIndex < self.allDisks.count){
        [self checkDiskStatus:self.allDisks[currentIndex]];
    }else{
        [self.diskEFIButton selectItemAtIndex:0];
        [self checkDiskStatus:self.allDisks.firstObject];
    }
}
- (void) efiSelect:(NSPopUpButton *)popBtn{
    
    NSInteger index = popBtn.indexOfSelectedItem;
    BDDisk * disk = self.allDisks[index];
    [self checkDiskStatus:disk];
    
    
}
- (void) checkDiskStatus:(BDDisk *) disk{
    
    [self.diskMountBtn setTitle:disk.isMounted?@"卸载":@"挂载"];
    [self.diskOpenBtn setEnabled:disk.isMounted];
}
- (NSMutableArray *) allDisks{
    if(_allDisks == nil){
        _allDisks = [[NSMutableArray alloc] init];
    }
    return _allDisks;
}
- (NSString *) resumString:(NSString *) deviceModel{
    
    NSArray * arr = [deviceModel componentsSeparatedByString:@" "];
    
    if(arr.count){
        return [arr componentsJoinedByString:@" "];
    }else{
        return deviceModel;
    }
    
}
- (IBAction)openDisk:(id)sender {
    BDDisk * currentDisk = [self.allDisks objectAtIndex:self.diskEFIButton.indexOfSelectedItem];
    NSLog(@"currentDisk:%@",[currentDisk.diskDescription objectForKey:@"DADeviceModel"]);
    if (currentDisk.volumePath == nil)
        return;
    
    NSArray *fileURLs = [NSArray arrayWithObjects:currentDisk.volumePath, nil];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}
- (IBAction)mountDisk:(id)sender {
    BDDisk * currentDisk = [self.allDisks objectAtIndex:self.diskEFIButton.indexOfSelectedItem];
    if(currentDisk.isMounted){
        [currentDisk unmountWithCompletionHandler:^(NSError *error) {
            
        }];
    }else{
        [currentDisk mountWithCompletionHandler:^(NSURL *mountURL, NSError *error) {
            
        }];
    }
    NSLog(@"currentDisk:%@",[currentDisk.diskDescription objectForKey:@"DADeviceModel"]);
}
@end

