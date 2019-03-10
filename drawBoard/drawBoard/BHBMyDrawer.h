//
//  BHBMyDrawer.h
//  BHBDrawBoarder
//
//  Created by bihongbo on 16/1/4.
//  Copyright © 2016年 bihongbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol drawPointDelegate <NSObject>

@optional
-(void)getStartPoint:(CGPoint)startPoint
                   endPoint:(CGPoint)endPoint
                      color:(NSString*)color
                      width:(CGFloat)width
                    isClean:(BOOL)isClean
                    isbegin:(BOOL)isbegin
                      isend:(BOOL)isend;
@end
@interface BHBMyDrawer : UIView
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) id <drawPointDelegate> delegate;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString* colorstr;
@property (nonatomic, assign) int drawStyle;  //0 线  1 长方形 2 椭圆
/**
 *  撤销的线条数组
 */
@property (nonatomic, strong)NSMutableArray * canceledLines;
/**
 *  线条数组
 */
@property (nonatomic, strong)NSMutableArray * lines;
@property (nonatomic, assign) BOOL canEarse;
/**
 *  清屏
 */
- (void)clearScreen;

/**
 *  撤销
 */
- (void)undo;

/**
 *  恢复
 */
- (void)redo;
@end
