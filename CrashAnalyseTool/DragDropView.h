//
//  DragDropView.h
//  CrashAnalyseTool
//
//  Created by jsonmess on 16/9/21.
//  Copyright © 2016年 com.jsonmess.CrashAnalyseTool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol DragDropViewDelegate;

@interface DragDropView : NSView
@property (assign)  id<DragDropViewDelegate> delegate;
@end

@protocol DragDropViewDelegate <NSObject>

-(void)dragDropViewFileList:(NSArray*)fileList;

@end
