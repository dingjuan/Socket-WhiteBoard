//
//  dataModel.h
//  drawBoard
//
//  Created by Juan Ding on 2017/4/28.
//  Copyright © 2017 Juan Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dataModel : NSObject

+(NSDictionary*)WithColor:(NSString*)color
   withStrokeWidth:(int)strokeWidth
             withX:(float)X
             withY:(float)Y
     withTimeStamp:(NSString*)timeStamp
       withIsStart:(BOOL)isStart
         withIsEnd:(BOOL)withIsEnd
    withFrameWidth:(float)frameWidth
   withFrameHeight:(float)frameHeight
          withIsClean:(BOOL)isclean;
@end
