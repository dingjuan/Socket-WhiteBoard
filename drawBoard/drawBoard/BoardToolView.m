//
//  BoardToolView.m
//  SocketWhiteBoard
//
//  Created by Jennie Ding on 3/7/17.
//  Copyright © 2017 Juan Ding. All rights reserved.
//

#import "BoardToolView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@implementation BoardToolView
{
    CGFloat rate;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        rate=kHeight/320;
        _colorArray = @[@"#999999",@"#FF0033",@"#00CC00",@"#0000CC",@"#FFCC00",@"#FF6633",@"#990099",@"#663300",@"#000000"];
        
        _lineArray = @[@1,@5,@10,@15,@20,@25];
        _drawTypeArray=@[@"Line",@"Oral",@"Rectangle"];
       // [self _createSelFunc];
        [self _createColorView];
        [self _createLineWidthView];
        [self createDrawStyle];
    }
    return self;
}


- (void)_createSelFunc {
    

    NSArray *titleArray = @[@"Color",@"Size",@"Erase",@"Clear"];
    
    self.funcView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 20*rate)];
    _funcView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_funcView];
    
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth/titleArray.count*i,0,kWidth/titleArray.count, 20*rate)];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = 100+i;
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_funcView addSubview:btn];
    }
    
    
}
-(UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

- (void)_createColorView {
    self.colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0*rate, kWidth, 40*rate)];
    _colorView.backgroundColor = [UIColor clearColor];
    [self addSubview:_colorView];
    
    for (NSInteger i = 0; i < _colorArray.count; i++) {
        CGFloat width=(kWidth-(_colorArray.count*30*rate))/(_colorArray.count+1);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((width+30*rate)*i+width,5*rate,30*rate,30*rate)];
        btn.layer.cornerRadius=30*rate/2;
        btn.clipsToBounds=YES;
        btn.tag = 100+i;
        btn.backgroundColor = [self colorWithHexString:_colorArray[i] alpha:1];
        [btn addTarget:self action:@selector(colorAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_colorView addSubview:btn];
    }
    
}
-(void)createDrawStyle{
   self.drawStyleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0*rate, kWidth, 40*rate)];
    self.drawStyleView.backgroundColor=[UIColor clearColor];
    [self addSubview:self.drawStyleView];
    for (NSInteger i = 0; i < _drawTypeArray.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth/_drawTypeArray.count*i,0,kWidth/_drawTypeArray.count,40*rate)];
        btn.tag = 400+i;
        btn.backgroundColor = [UIColor colorWithRed:239/255.0 green:101/255.0 blue:79/255.0 alpha:1];
        [btn setTitle:_drawTypeArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(typeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_drawStyleView addSubview:btn];
    }
    
}
- (void)_createLineWidthView {
    
    self.lineWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0*rate, kWidth, 40*rate)];
    _lineWidthView.backgroundColor = [UIColor clearColor];
    _lineWidthView.hidden = YES;
    [self addSubview:_lineWidthView];
    
    for (NSInteger i = 0; i < _lineArray.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth/_lineArray.count*i,0,kWidth/_lineArray.count,40*rate)];
        btn.tag = 100+i;
        btn.backgroundColor = [UIColor colorWithRed:239/255.0 green:101/255.0 blue:79/255.0 alpha:1];
        float width = [_lineArray[i] floatValue];
        [btn setTitle:[NSString stringWithFormat:@"%.0f点",width] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(lineWidthAction:) forControlEvents:UIControlEventTouchUpInside];
        [_lineWidthView addSubview:btn];
    }
}

- (void)btnAction:(UIButton *)btn {
    switch (btn.tag) {
        case 100:
            _lineWidthView.hidden = YES;
            _colorView.hidden = NO;
            
            break;
        case 101:
            _colorView.hidden = YES;
            _lineWidthView.hidden = NO;
            break;
        case 102:
            _colorView.hidden = YES;
            _lineWidthView.hidden = YES;
            if (_eraserBlock) {
                _eraserBlock();
            }
            break;
        case 105:
            if (_backBlock) {
                _backBlock();
            }
            
            break;
        case 103:
            _colorView.hidden = YES;
            _lineWidthView.hidden = YES;
            if (_clearBlock) {
                _clearBlock();
            }
            
            break;
        default:
            break;
    }
}

- (void)colorAction:(UIButton *)btn {
    NSString *color = _colorArray[btn.tag-100];
    if (_colorBlock) {
        _colorBlock(color);
    }

}

-(void)typeAction:(UIButton*)btn{
    if (_typeBlock) {
        _typeBlock(btn.tag-400);
    }
}
- (void)lineWidthAction:(UIButton *)btn {
    
    if (_widthBlock) {
        _widthBlock([_lineArray[btn.tag-100] floatValue]);
    }
}

@end
