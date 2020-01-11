//
//  AppDelegate.m
//  SMBIOSTransporter
//
//  Created by haoke on 2020/1/3.
//  Copyright © 2020 haoke. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()<NSWindowDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {


}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reopen" object:nil]];
        return YES;
    }
}
-(void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
    
    NSLog(@"urls : %@",urls);
}
@end
