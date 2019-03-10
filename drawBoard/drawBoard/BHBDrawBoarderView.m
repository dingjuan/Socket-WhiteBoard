//
//  BHBDrawBoarderView.m
//  BHBDrawBoarder
//
//  Created by bihongbo on 16/1/4.
//  Copyright © 2016年 bihongbo. All rights reserved.
//
// 屏幕尺寸
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

#import "BHBDrawBoarderView.h"
#import "BHBScrollView.h"

@interface BHBDrawBoarderView ()
{
    
    UIView *_toolView;
    BHBScrollView * _boardView;
  
    
}


/** 按钮图片 */
@property (nonatomic, strong) NSArray   * buttonImgNames;
/** 按钮不可用图片 */
@property (nonatomic, strong) NSArray   * btnEnableImgNames;

//@property (nonatomic, strong)BHBMyDrawer * myDrawer;

@property (nonatomic, strong)UIButton * delAllBtn;//删除
@property (nonatomic, strong)UIButton * fwBtn;//上一步
@property (nonatomic, strong)UIButton * ntBtn;//下一步


@end


@implementation BHBDrawBoarderView

- (BHBMyDrawer *)myDrawer
{
    if (_myDrawer == nil) {
        _myDrawer = [[BHBMyDrawer alloc] initWithFrame:CGRectMake(80, 0, SCREEN_SIZE.width-160, SCREEN_SIZE.height*2)];
        _myDrawer.layer.backgroundColor = [UIColor clearColor].CGColor;
        
    }
    return _myDrawer;
    
}


- (NSArray *)btnEnableImgNames
{
    if (_btnEnableImgNames == nil) {
        _btnEnableImgNames = @[@"close_draft_enable",@"delete_draft_enable",@"undo_draft_enable",@"redo_draft_enable"];
    }
    return _btnEnableImgNames;
}


- (NSArray *)buttonImgNames
{
    if (_buttonImgNames == nil) {
        _buttonImgNames = @[@"close_draft",@"delete_draft",@"undo_draft",@"redo_draft"];
    }
    return _buttonImgNames;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, SCREEN_SIZE.height, SCREEN_SIZE.width, SCREEN_SIZE.height);
    self = [super initWithFrame:frame];
    if (self) {
        

        
        self.delAllBtn = (UIButton *)[_toolView viewWithTag:101];
        self.fwBtn = (UIButton *)[_toolView viewWithTag:102];
        self.ntBtn = (UIButton *)[_toolView viewWithTag:103];
        
        [self.myDrawer addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.myDrawer addObserver:self forKeyPath:@"canceledLines" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        //画板view

        self.myDrawer.color=[UIColor blackColor];
        self.myDrawer.colorstr=@"#000000";
        [self addSubview:self.myDrawer];
  //      _boardView = boardV;
        
    
     //   [[UIApplication sharedApplication].keyWindow addSubview:self];
        
    }
    return self;
}


- (void)show {
    
    _myDrawer.lines = [NSMutableArray arrayWithArray:self.linesInfo];
    for (CALayer * layer in _myDrawer.lines) {
        [_myDrawer.layer addSublayer:layer];
    }
    
    [UIView animateWithDuration:.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y -= frame.size.height ;
                         [self setFrame:frame];
                         
                     }completion:nil];
}

- (void)dismiss{
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y += frame.size.height ;
                         [self setFrame:frame];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             if (self.draftInfoBlock) {
                                 self.draftInfoBlock(self.num, _myDrawer.lines, _myDrawer.canceledLines);
                             }
                         }
                         
                         [self removeFromSuperview];
                         
                         [self.myDrawer removeObserver:self forKeyPath:@"canceledLines"];
                         [self.myDrawer removeObserver:self forKeyPath:@"lines"];
                     }];
}


- (void)btnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
            [self dismiss];
            break;
        case 101:
            [_myDrawer clearScreen];
            break;
        case 102:
            [_myDrawer undo];
            break;
        case 103:
            [_myDrawer redo];
            break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if([keyPath isEqualToString:@"lines"]){
        NSMutableArray * lines = [_myDrawer mutableArrayValueForKey:@"lines"];
        if (lines.count) {
            [self.delAllBtn setEnabled:YES];
            [self.fwBtn setEnabled:YES];
            
        }else{
            [self.delAllBtn setEnabled:NO];
            [self.fwBtn setEnabled:NO];
        }
    }else if([keyPath isEqualToString:@"canceledLines"]){
        NSMutableArray * canceledLines = [_myDrawer mutableArrayValueForKey:@"canceledLines"];
        if (canceledLines.count) {
            [self.ntBtn setEnabled:YES];
        }else{
            [self.ntBtn setEnabled:NO];
            
        }
        
    }
}



@end
