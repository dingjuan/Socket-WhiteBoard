//
//  BHBDrawBoarderView.h
//  BHBDrawBoarder
//
//  Created by bihongbo on 16/1/4.
//  Copyright © 2016年 bihongbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHBMyDrawer.h"

typedef void(^draftInfoBlock)(NSInteger num, NSArray * linesInfo, NSArray * canceledLinesInfo);

@interface BHBDrawBoarderView : UIView

@property (nonatomic, strong)NSIndexPath *index;
@property (nonatomic, assign)NSInteger num;
@property (nonatomic, strong)NSArray * linesInfo;
@property (nonatomic, strong)NSArray * canceledLinesInfo;
@property (nonatomic, copy)draftInfoBlock draftInfoBlock;

@property (nonatomic, strong) BHBMyDrawer * myDrawer;
- (void)show;

- (void)dismiss;



@end
