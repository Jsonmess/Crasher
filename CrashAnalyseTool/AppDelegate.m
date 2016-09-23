//
//  AppDelegate.m
//  CrashAnalyseTool
//
//  Created by jsonmess on 16/9/22.
//  Copyright © 2016年 com.jsonmess.CrashAnalyseTool. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowViewController.h"

@interface AppDelegate ()
@property (nonatomic)  NSWindowController *MainwindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (self.MainwindowController==nil ) {
        _MainwindowController=[[MainWindowViewController alloc]initWithWindowNibName:@"MainWindowViewController"];
    }
    [self.MainwindowController showWindow:self];
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]];
    
    // disable "New" if the window is already up
    if ([theMenuItem action] == @selector(newDocument:))
    {
        if ([[self.MainwindowController window] isKeyWindow])
        {
            enable = NO;
        }
    }
    return enable;
}
@end
