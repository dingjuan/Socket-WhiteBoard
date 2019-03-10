//
//  BHBMyDrawer.m
//  BHBDrawBoarder
//
//  Created by bihongbo on 16/1/4.
//  Copyright © 2016年 bihongbo. All rights reserved.
//

#import "BHBMyDrawer.h"
#import "BHBPaintPath.h"
@interface BHBMyDrawer ()


@property (nonatomic, strong)BHBPaintPath * path;
@property (nonatomic, strong)CAShapeLayer * slayer;
 @property (nonatomic, strong) UIImageView * viewImage;
@end

@implementation BHBMyDrawer
{
    CGPoint currentP;
   CGPoint previousPoint;
    CGPoint beginPoint;
}
- (UIImageView *)drawImage
{
    if (!_viewImage) {
        _viewImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _viewImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _viewImage;
}
- (NSMutableArray *)lines
{
    if (_lines == nil) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}


- (NSMutableArray *)canceledLines
{
    if (_canceledLines == nil) {
        _canceledLines = [NSMutableArray array];
    }
    return _canceledLines;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _width = 5;
     //   imageView=[[UIImageView alloc]initWithFrame:self.bounds];
     //  [self addSubview:self.viewImage];
    }
    return self;
}

// 根据touches集合获取对应的触摸点
- (CGPoint)pointWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    
    return [touch locationInView:self];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint startP = [self pointWithTouches:touches];
    
    if ([event allTouches].count == 1) {
        
        BHBPaintPath *path = [BHBPaintPath paintPathWithLineWidth:_width
                                                     startPoint:startP withColor:_color];
        
        _path = path;

        CAShapeLayer * slayer = [CAShapeLayer layer];
        slayer.path = path.CGPath;
       
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = _color.CGColor;
        slayer.lineWidth = path.lineWidth;
        

        [self.layer addSublayer:slayer];
        _slayer = slayer;
        if(self.drawStyle>=0){
            beginPoint=startP;
        }
        
        [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
        [[self mutableArrayValueForKey:@"lines"] addObject:_slayer];
        if(self.delegate){
            [self.delegate getStartPoint:startP endPoint:startP color:self.colorstr width:self.width isClean:NO isbegin:YES isend:NO];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取移动点
    CGPoint moveP = [self pointWithTouches:touches];
    currentP=moveP;
    if ([event allTouches].count > 1){
        
        [self.superview touchesMoved:touches withEvent:event];
        
    }else if ([event allTouches].count == 1) {
    
        if(self.delegate){
            [self.delegate getStartPoint:moveP endPoint:moveP color:self.colorstr width:self.width isClean:NO isbegin:NO isend:NO];
        }
        if(self.drawStyle==0){
        [_path addLineToPoint:moveP];
        }else{
            CGFloat x = beginPoint.x < moveP.x ? beginPoint.x:moveP.x;
            CGFloat y = beginPoint.y < moveP.y ? beginPoint.y:moveP.y;
            
            CGFloat width = fabs(beginPoint.x - moveP.x);
            CGFloat height = fabs(beginPoint.y - moveP.y);
            if (self.drawStyle==1) {
                _path=(BHBPaintPath*)[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, width, height)];
            }else{
                _path=(BHBPaintPath*)[UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
            }
       
        
        }
        _slayer.path = _path.CGPath;
       
    }
    
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取移动点
    CGPoint endP = [self pointWithTouches:touches];
    if ([event allTouches].count > 1){
        [self.superview touchesMoved:touches withEvent:event];
    }
    _canEarse=NO;
    if(self.delegate){
        [self.delegate getStartPoint:endP endPoint:endP color:self.colorstr width:self.width isClean:NO isbegin:NO isend:YES];
    }
}

/**
 *  画线
 */
- (void)drawLine{

    [self.layer addSublayer:self.lines.lastObject];
    
}
- (void)eraseLine
{
    for (CAShapeLayer* layer in self.layer.sublayers) {
        if ([layer containsPoint:currentP]) {
            NSLog(@"erase==========>%@",layer);
        }
    }
}
//- (void)drawRect:(CGRect)rect
//{
//    [self.viewImage drawInRect:self.bounds];
//}
/**
 *  清屏
 */
- (void)clearScreen
{
    
    if (!self.lines.count) return ;
    if(self.delegate){
        [self.delegate getStartPoint:CGPointZero endPoint:CGPointZero color:self.colorstr width:self.width isClean:YES isbegin:NO isend:NO];
    }
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self mutableArrayValueForKey:@"lines"] removeAllObjects];
    [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];

}

/**
 *  撤销
 */
- (void)undo
{
    //当前屏幕已经清空，就不能撤销了
    if (!self.lines.count) return;
    [[self mutableArrayValueForKey:@"canceledLines"] addObject:self.lines.lastObject];
    [self.lines.lastObject removeFromSuperlayer];
    [[self mutableArrayValueForKey:@"lines"] removeLastObject];
    
}


/**
 *  恢复
 */
- (void)redo
{
    //当没有做过撤销操作，就不能恢复了
    if (!self.canceledLines.count) return;
    [[self mutableArrayValueForKey:@"lines"] addObject:self.canceledLines.lastObject];
    [[self mutableArrayValueForKey:@"canceledLines"] removeLastObject];
    [self drawLine];
    
}


@end
