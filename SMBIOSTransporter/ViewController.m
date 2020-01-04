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
@property (nonatomic,weak) IBOutlet HKDragView * drapDropImageViewCL;
@property (nonatomic,weak) IBOutlet HKDragView * drapDropImageViewOC;
@property (weak) IBOutlet NSButton *runBtn;
@property (nonatomic,strong) HKConfigUtility * oConfig;
@property (nonatomic,strong) HKConfigUtility * cConfig;
@property (weak) IBOutlet NSImageView *bgImageViewCL;
@property (weak) IBOutlet NSImageView *bgImageViewOC;
@property (weak) IBOutlet NSImageView *typeImageViewOC;
@property (weak) IBOutlet NSImageView *typeImageViewCL;
@property (weak) IBOutlet NSTextField *MLBLabel;
@property (weak) IBOutlet NSTextField *ROMLabel;
@property (weak) IBOutlet NSTextField *SNLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.drapDropImageViewCL setType:0];
    [self.drapDropImageViewOC setType:1];
    [self.drapDropImageViewCL setDelegate:self];
    [self.drapDropImageViewOC setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reopen) name:@"reopen" object:nil];
    // Do any additional setup after loading the view.
}
- (void) dragviewDidGetFileWithURL:(NSURL *)url withType:(NSInteger)type{
    HKConfigUtility * config = [[HKConfigUtility alloc] initWithURL:url];
    NSImageView * dgView = nil;
    if(type == 0){
        self.cConfig = config;
        dgView = self.typeImageViewCL;
        self.MLBLabel.stringValue = [NSString stringWithFormat:@"MLB:%@",config.MLB];
        self.ROMLabel.stringValue = [NSString stringWithFormat:@"ROM:%@",config.ROMValue];
        self.SNLabel.stringValue = [NSString stringWithFormat:@"SerialNumber:%@",config.SerialNumber];

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
- (void)reopen{
    [self.view.window makeKeyAndOrderFront:self];
}

- (IBAction)runAction:(NSButton *)sender {
    __weak typeof(self) weakself = self;
    [self.oConfig changeSMBIOSCodeWithConfig:self.cConfig withCompleteHandler:^(BOOL isSuccess) {
        NSLog(@"转移成功：%@",isSuccess?@"是":@"否");
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"三码复制成功";
        [alert addButtonWithTitle:@"确定"];
        [alert setInformativeText:[NSString stringWithFormat:@"三码已从%@复制到%@",weakself.cConfig.desString,weakself.oConfig.desString]];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
    }];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
