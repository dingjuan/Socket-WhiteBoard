//
//  dataModel.m
//  drawBoard
//
//  Created by Juan Ding on 2017/4/28.
//  Copyright © 2017 Juan Ding. All rights reserved.
//

#import "dataModel.h"

@implementation dataModel

+(NSDictionary*)WithColor:(NSString*)color
          withStrokeWidth:(int)strokeWidth
                    withX:(float)X
                    withY:(float)Y
            withTimeStamp:(NSString*)timeStamp
              withIsStart:(BOOL)isStart
                withIsEnd:(BOOL)IsEnd
           withFrameWidth:(float)frameWidth
          withFrameHeight:(float)frameHeight
              withIsClean:(BOOL)isclean{
    if (isStart) {
        return @{@"start":@"true"};
    }else if (IsEnd){
        return @{@"end":@"true"};
    }else if(isclean){
        return @{@"clear":@"true"};
    }
    return @{@"frameWidth":[NSString stringWithFormat:@"%.3f",frameWidth],@"frameHeight":[NSString stringWithFormat:@"%.3f",frameHeight],@"paintColor":color,@"timestamp":timeStamp,@"x":[NSString stringWithFormat:@"%.3f",X],@"y":[NSString stringWithFormat:@"%.3f",Y],@"strokeWidth":[NSString stringWithFormat:@"%d",strokeWidth]};
}

@end
