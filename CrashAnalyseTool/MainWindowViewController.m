//
//  MainWindowViewController.m
//  CrashAnalyseTool
//
//  Created by jsonmess on 16/9/22.
//  Copyright © 2016年 com.jsonmess.CrashAnalyseTool. All rights reserved.
//

#import "MainWindowViewController.h"
#import "DragDropView.h"

#define DEFAULTTITLE  @"等待解析...\n\n小提示:\n  dsyml文件、crash日志文件和.app 确保放到同一个文件夹 ：）\n\n"

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
    [self.logOutView setString:DEFAULTTITLE];
}
-(void)dragDropViewFileList:(NSArray *)fileList
{
//    NSLog(@"%@",fileList);
    self.crashFilePath = nil;
    self.dsymlFilePath = nil;
    [self.logOutView setString:DEFAULTTITLE];
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
        [self AlertViewShowWithMessageText:@"警告" InforMativeText:@"找不到crash日志文件"];
        return;
    }
    _LogOut = @"解析中,请稍后...\n";
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
        [self AlertViewShowWithMessageText:@"警告" InforMativeText:@"找不到Xcode，请先前往AppStore 下载Xcode"];
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
            _LogOut = [_LogOut stringByAppendingString:[NSString stringWithFormat:@"解析完成..\n正在写入文件\n%@\n",logoutFilePath]];
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
            [self AlertViewShowWithMessageText:@"提示" InforMativeText:@"解析内容写入文件失败，请重试"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _LogOut = [_LogOut stringByAppendingString:@"写入文件成功！"];
            [self.logOutView setString:_LogOut];
        });

    }
}
-(void)AlertViewShowWithMessageText:(NSString *)message InforMativeText:(NSString*)info
{
    
    NSAlert *alert=[NSAlert alertWithMessageText:message defaultButton:@"确认" alternateButton:@"取消" otherButton:nil informativeTextWithFormat: info,nil];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
    
}
@end
