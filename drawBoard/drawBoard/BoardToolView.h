//
//  BoardToolView.h
//  SocketWhiteBoard
//
//  Created by Jennie Ding on 3/7/17.
//  Copyright © 2017 Juan Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ColorSelBlock) (NSString *);
typedef void (^WidthSelBlock) (float);
typedef void (^TypeSelBlock) (NSUInteger);
typedef void (^FuncBlock) (void);

@interface BoardToolView : UIView
{
    NSArray *_colorArray;
    NSArray *_lineArray;
    NSArray *_drawTypeArray;
}
@property (nonatomic, strong) UIView *funcView;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong)  UIView *lineWidthView;
@property (nonatomic, strong) UIView* drawStyleView;
@property (nonatomic, copy) ColorSelBlock colorBlock;
@property (nonatomic, copy) WidthSelBlock widthBlock;
@property (nonatomic, copy) TypeSelBlock typeBlock;
@property (nonatomic, copy) FuncBlock eraserBlock;
@property (nonatomic, copy) FuncBlock backBlock;
@property (nonatomic, copy) FuncBlock clearBlock;

@end
