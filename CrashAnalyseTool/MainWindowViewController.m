//
//  MainWindowViewController.m
//  CrashAnalyseTool
//
//  Created by jsonmess on 16/9/22.
//  Copyright © 2016年 com.jsonmess.CrashAnalyseTool. All rights reserved.
//

#import "MainWindowViewController.h"
#import "DragDropView.h"

@interface MainWindowViewController ()<DragDropViewDelegate>
{
        NSString *_LogOut;//动态输出日志
}
@property (weak) IBOutlet DragDropView *dragDropView;
@property (unsafe_unretained) IBOutlet NSTextView *logOutView;

@property (nonatomic,strong)NSString*crashFilePath;
@property (nonatomic,strong)NSString*dsymlFilePath;

@end

@implementation MainWindowViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setUpView];
}
- (void)setUpView
{
    [self.logOutView setEditable:NO];
    [self.dragDropView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self.dragDropView setDelegate:self];
    [self.logOutView setString:NSLocalizedString(@"defaultTitle", nil)];
}
-(void)dragDropViewFileList:(NSArray *)fileList
{
//    NSLog(@"%@",fileList);
    self.crashFilePath = nil;
    self.dsymlFilePath = nil;
    [self.logOutView setString:NSLocalizedString(@"defaultTitle", nil)];
    for (NSString* filePath in fileList) {
        if ([filePath rangeOfString:@".crash"].length > 0 )
        {
            self.crashFilePath = filePath;
        }
        
        if ([filePath rangeOfString:@"dSYM"].length > 0)
        {
            self.dsymlFilePath = filePath;
        }
    }
    
    if (self.crashFilePath == nil && self.crashFilePath.length <= 0)
    {
        [self AlertViewShowWithMessageText:NSLocalizedString(@"warning", @"") InforMativeText:NSLocalizedString(@"nofile", @"")];
        return;
    }
    _LogOut = NSLocalizedString(@"analysing", @"");
    [self.logOutView setString:_LogOut];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [self beginToAnalysisCrashFile];
    });
    //获取文件目录，开始解析
    
}

-(void)beginToAnalysisCrashFile
{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *analysisTask = [[NSTask alloc] init];
    NSString *launchPath = @"/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash";
    if (launchPath==nil||!([launchPath rangeOfString:@"Xcode.app"].length>0))
    {
        [self AlertViewShowWithMessageText:NSLocalizedString(@"warning", @"")  InforMativeText:NSLocalizedString(@"noXcode", @"") ];
    }
    else
    {
        analysisTask.launchPath = launchPath;
    }
    NSArray *array=[NSArray arrayWithObjects:self.crashFilePath, nil];
    [analysisTask setArguments:array];
    [analysisTask setEnvironment:@{
                                  @"DEVELOPER_DIR":@"/Applications/Xcode.app/Contents/Developer"
                                  }];
    [analysisTask setStandardOutput:pipe];
    [analysisTask launch];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    NSString *LogOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if (LogOutput && LogOutput.length > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *logoutFilePath = [[self.crashFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"log"];
            _LogOut = [_LogOut stringByAppendingString:[NSString stringWithFormat:@"%@%@\n",NSLocalizedString(@"finishedAnalyseLog", @""),logoutFilePath]];
            [self.logOutView setString:_LogOut];
        });
    }
//    _LogOut=[_LogOut stringByAppendingString:[NSString stringWithFormat:@"\n%@",LogOutput]];
//    if (_LogOut==nil||[_LogOut isEqualToString:@""]) {
//        _LogOut=@"";
//    }
//    [self.logOutView setString:_LogOut];
//    [self.logOutView scrollRangeToVisible:NSMakeRange(_LogOut.length-1, 1)];
    [self writeToFileWithContent:LogOutput];
}

-(void)writeToFileWithContent:(NSString*)logOut
{
    NSString *logoutFilePath = [[self.crashFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"log"];
    NSError *error;
    [logOut writeToFile:logoutFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self AlertViewShowWithMessageText:NSLocalizedString(@"alert", @"") InforMativeText:NSLocalizedString(@"errorWriteLog", @"")];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _LogOut = [_LogOut stringByAppendingString:NSLocalizedString(@"successWriteLog",@"")];
            [self.logOutView setString:_LogOut];
        });

    }
}
-(void)AlertViewShowWithMessageText:(NSString *)message InforMativeText:(NSString*)info
{
    
    NSAlert *alert=[NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"confirm",@"") alternateButton:NSLocalizedString(@"cancel",@"") otherButton:nil informativeTextWithFormat: info,nil];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
    
}
@end
