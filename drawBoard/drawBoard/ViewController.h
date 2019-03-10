//
//  ViewController.m
//  SocketWhiteBoard
//
//  Created by Jennie Ding on 3/10/19.
//  Copyright © 2019 Juan Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, retain)NSString *fileURLString;
-(void)getStartPoint:(CGPoint)startPoint
            endPoint:(CGPoint)endPoint
               color:(NSString*)color
               width:(CGFloat)width
             isClean:(BOOL)isClean
             isbegin:(BOOL)isbegin
               isend:(BOOL)isend;
@end
