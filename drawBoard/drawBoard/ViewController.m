//
//  ViewController.m
//  SocketWhiteBoard
//
//  Created by Jennie Ding on 3/10/19.
//  Copyright © 2019 Juan Ding. All rights reserved.
//

#import "BoardToolView.h"
#import "ViewController.h"
#import "SDWebImageManager.h"
#import "drawBoard-Bridging-Header.h"
#import "drawBoard-Swift.h"
#import "UIImageView+WebCache.h"
#import "BHBDrawBoarderView.h"
#import "dataModel.h"

#pragma mark =======  server url and port
static  NSString * Khost = @"192.168.100.12";
static const uint16_t Kport = 17010;
#pragma mark ========  socket event 事件名称
static  NSString *  SINIT = @"presentation_init";
static  NSString * scrollMSG = @"presentation";
static  NSString * pathMSG = @"path";
static  NSString * sigMSG = @"sig";
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIWebViewDelegate,UIScrollViewDelegate,NSStreamDelegate,UITableViewDelegate,UITableViewDataSource,drawPointDelegate,SocketEngineClient>{
    
    UIScrollView* imageSC;
    CGFloat height;
    NSUInteger lastIndex;
    NSArray* currentArrays;
    
}
@property (nonatomic,strong)NSURL *fileURL;
@property (nonatomic,strong)NSThread *thread;
@property (nonatomic,strong) SocketIOClient * clientSocket;
@end

@implementation ViewController
{
    BoardToolView *boardToolView;
    CGFloat rate;
    UITableView* maintab;
    NSArray* fileList;
    UIImageView* imageV;
    UIScrollView* drawSC;
}
-(void)clearimageSC{
    for (UIView* view in imageSC.subviews) {
        [view removeFromSuperview];
    }
    [imageSC removeFromSuperview];
}
#pragma mark ==================点击选择某个课件后，重新加载pdf图片滚动试图 根据图片的高度 计算contentoffset

-(void)openPDF:(NSUInteger)sender{
    [self clearimageSC];
    
    NSDictionary* dic=@{@"presentationName":@"test",@"display":@{@"displayWidth":[NSNumber numberWithFloat: kWidth-160*rate],@"displayHeight":[NSNumber numberWithFloat: kHeight]}};
    NSString* str=[self dictionaryToJson:dic];
    [self.clientSocket emit:SINIT with:@[str]];
    
    
    height=0;
    NSArray* urllist=fileList[sender][@"url"];
    imageSC=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageSC.scrollEnabled=NO;
    imageSC.delegate=self;
    [self.view addSubview:imageSC];
    currentArrays=[NSArray arrayWithArray:urllist];
    for (int i=0; i<urllist.count; i++) {
        UIImageView* im=[[UIImageView alloc]initWithFrame:CGRectMake(80*rate,i*kHeight,self.view.frame.size.width-160*rate , self.view.frame.size.height)];
        
        im.tag=100+i;
        [imageSC addSubview:im];
        
    }
    for (int i=0; i<urllist.count; i++) {
        UIImageView* im=[imageSC viewWithTag:100+i];
        __weak typeof(self) wks=self;
        [im sd_setImageWithURL:[NSURL URLWithString:urllist[i]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (height==0&&image.size.width>0&&image.size.height>0) {
                
                height=(kWidth-160*rate)/image.size.width*image.size.height;
                [wks changeFrameWithIndex:urllist];
            }
        }];
    }
    
}
-(void)changeFrameWithIndex:(NSArray*)array{
    imageSC.contentSize=CGSizeMake(0, height*array.count);
    imageSC.scrollEnabled=YES;
    drawSC.contentSize=CGSizeMake(0, height*array.count);
    BHBDrawBoarderView* view=[drawSC viewWithTag:1003];
    view.frame=CGRectMake(0*rate, 0, kWidth-160*rate, height*array.count);
    view.myDrawer.frame=CGRectMake(0*rate, 0, kWidth-160*rate, height*array.count);
    for (int i=0; i<array.count; i++) {
        UIImageView* im=[imageSC viewWithTag:100+i];
        im.frame=CGRectMake(80*rate,i*height,self.view.frame.size.width-160*rate , height);
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    lastIndex=11111;
    fileList=@[@{@"name":@"课件一 pdf",@"url":@[@"http://192.168.100.12:8889/test/api_1.png",@"http://192.168.100.12:8889/test/api_2.png",@"http://192.168.100.12:8889/test/api_3.png",@"http://192.168.100.12:8889/test/api_4.png",@"http://192.168.100.12:8889/test/api_5.png"]},@{@"name":@"课件二 word",@"url":@[@"http://192.168.100.12:8889/test/api_6.png",@"http://192.168.100.12:8889/test/api_7.png",@"http://192.168.100.12:8889/test/api_8.png",@"http://192.168.100.12:8889/test/api_9.png",@"http://192.168.100.12:8889/test/api_10.png"]},@{@"name":@"DrawBoard"},@{@"name":@"cancle"}];
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    rate=kHeight/320;
    
    [self addDrawing];
    [self alertTintChooseFile];
    
}
#pragma mark ==========选择课件tableview
-(void)alertTintChooseFile{
    maintab=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    maintab.backgroundColor=[UIColor whiteColor];
    maintab.delegate=self;
    maintab.dataSource=self;
    maintab.rowHeight=30*rate;
    [[UIApplication sharedApplication].keyWindow addSubview:maintab];
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30*rate)];
    label.text=@"Please choose File";
    label.font=[UIFont systemFontOfSize:18*rate];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor blackColor];
    maintab.tableHeaderView=label;
}
-(void)showTab{
    [UIView animateWithDuration:.3 animations:^{
        maintab.frame=self.view.bounds;
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return fileList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=fileList[indexPath.row][@"name"];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([fileList[indexPath.row][@"name"] isEqualToString:@"DrawBoard"]){
        [self clearimageSC];
        drawSC.contentSize=CGSizeMake(0, kHeight);
        BHBDrawBoarderView* view=[drawSC viewWithTag:1003];
        [view.myDrawer clearScreen];
        view.frame=CGRectMake(0*rate, 0, kWidth-160*rate,kHeight);
        view.myDrawer.frame=CGRectMake(0*rate, 0, kWidth-160*rate, kHeight);
        lastIndex=indexPath.row;
        
    }else if (![fileList[indexPath.row][@"name"] isEqualToString:@"cancle"]&&(lastIndex != indexPath.row) ) {
        BHBDrawBoarderView* view=[drawSC viewWithTag:1003];
        [view.myDrawer clearScreen];
        lastIndex=indexPath.row;
        [self openPDF:indexPath.row];
    }
    
    [UIView animateWithDuration:.3 animations:^{
        tableView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

// when scroll the file, send location to server to update to other users
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == imageSC) {
        [drawSC setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
        [self sendOffsetToServer:scrollView];
    }
    
}
#pragma mark  send scrollview height to server
-(void)sendOffsetToServer:(UIScrollView*)scrollView{
    NSDictionary* dic=@{@"presentationName":@"test",@"currentHeight":  [NSNumber numberWithFloat:scrollView.contentOffset.y],@"totalHeight":[NSNumber numberWithFloat:scrollView.contentSize.height],@"display":@{@"displayWidth":[NSNumber numberWithFloat: kWidth-160*rate],@"displayHeight":[NSNumber numberWithFloat: kHeight]}};
    NSString* str=[self dictionaryToJson:dic];
    [self.clientSocket emit:scrollMSG with:@[str]];
}

/*!
 @method 懒加载
 @abstract 初始化客户端socket对象
 @result 客户端socket对象
 */
- (SocketIOClient *)clientSocket {
    if (!_clientSocket) {
        //        NSURL *url = [NSURL URLWithString:@"http://webapp.howiech.com"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%hu",Khost,Kport]];
        _clientSocket = [[SocketIOClient alloc]initWithSocketURL:url
                                                          config:@{@"log": @YES, @"forcePolling": @NO}];
        
        
    }
    return _clientSocket;
}
- (void)engineDidErrorWithReason:(NSString * _Nonnull)reason{
    NSLog(@"didError==============>%@",reason);
    
}
- (void)engineDidCloseWithReason:(NSString * _Nonnull)reason{
    NSLog(@"DidClose==============>%@",reason);
}
- (void)engineDidOpenWithReason:(NSString * _Nonnull)reason{
    
}
- (void)parseEngineMessage:(NSString * _Nonnull)msg{
    
}
- (void)parseEngineBinaryData:(NSData * _Nonnull)data{
    
}
-(void)socketIoConnect{
    [self.clientSocket connect];
    [self.clientSocket emit:sigMSG
                       with:@[@"server\n"]];
    [self.clientSocket on:@"error" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        
        
    }];
    
}
- (void)receiveText {
    
    [self.clientSocket on:@"path" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        [self.clientSocket emit:@"text"
                           with:@[@"server\\n"]];
    }];
    
    
}
-(void)addDrawing{
    [self socketIoConnect];
    drawSC=[[UIScrollView alloc]initWithFrame:CGRectMake(80*rate, 0, kWidth-160*rate, kHeight)];
    drawSC.scrollEnabled=NO;
    [[UIApplication sharedApplication].keyWindow addSubview:drawSC];
    
    BHBDrawBoarderView* drawView=[[BHBDrawBoarderView alloc]initWithFrame:CGRectMake(0*rate, 0, kWidth-160*rate, kHeight)];
    drawView.tag=1003;
    drawView.myDrawer.delegate=self;
    drawView.layer.borderColor=[UIColor colorWithRed:239/255.0 green:101/255.0 blue:79/255.0 alpha:1].CGColor;
    drawView.layer.borderWidth=3.0f;
    [drawSC addSubview:drawView];
    
    boardToolView = [[BoardToolView alloc] initWithFrame:CGRectMake(0,kHeight,kWidth, 40*rate)];
    [[UIApplication sharedApplication].keyWindow  addSubview:boardToolView];
    NSArray* a=@[@"Choose File",@"Color",@"Size",@"Undo",@"Clear",@"Type"];
    for ( int i=0 ; i<a.count; i++) {
        UIButton* dBtn=[[UIButton alloc]initWithFrame:CGRectMake(8*rate, 50*rate+i*40*rate, 66*rate, 26*rate)];
        dBtn.tag=1004+i;
        [dBtn setTitle:a[i] forState:UIControlStateNormal];
        [[UIApplication sharedApplication].keyWindow addSubview:dBtn];
        dBtn .titleLabel.font=[UIFont systemFontOfSize:12*rate];
        [dBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if(i==0){
            [dBtn addTarget:self action:@selector(showTab) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [dBtn addTarget:self action:@selector(showOrHide:) forControlEvents:UIControlEventTouchUpInside];
        }
        [dBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        dBtn.layer.cornerRadius=8*rate;
        dBtn.backgroundColor=[UIColor colorWithRed:239/255.0 green:101/255.0 blue:79/255.0 alpha:1];
    }
    
    
    __weak __block typeof(self) blockSelf=self;
    boardToolView.colorBlock = ^(NSString *color) {
        [blockSelf hideTool];
        drawView.myDrawer.color = [blockSelf colorWithHexString:color alpha:1];
        drawView.myDrawer.colorstr=color;
    };
    
    boardToolView.widthBlock = ^(float width) {
        [blockSelf hideTool];
        drawView.myDrawer.width = width;
    };
    
    boardToolView.eraserBlock = ^{
        drawView.myDrawer.color = [UIColor whiteColor];
    };
    
    boardToolView.backBlock = ^{
        // [drawView backAction];
    };
    
    boardToolView.clearBlock = ^{
        [drawView.myDrawer clearScreen];
    };
    boardToolView.typeBlock= ^(NSUInteger type){
        [blockSelf hideTool];
        drawView.myDrawer.drawStyle=(int)type;
    };
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError==>%@",error);
}
-(void)showOrHide:(UIButton*)btn{
    BHBDrawBoarderView* view=[drawSC viewWithTag:1003];
    if(btn.tag==1008){
        
        [view.myDrawer clearScreen];
        [self hideTool];
        return;
    }else if (btn.tag==1007){
        [self hideTool];
        
        [view.myDrawer undo];
        [self.clientSocket emit:sigMSG with:@[@"undo"]];
        return;
    }
    [self updateToolView:btn.tag];
}

-(void) updateToolView:(NSUInteger) tag {
    if (boardToolView.frame.origin.y==kHeight) {
        if (tag==1005) {
            boardToolView.colorView.hidden = NO;
            boardToolView.lineWidthView.hidden = YES;
            boardToolView.drawStyleView.hidden=YES;
        }else if (tag == 1006){
            boardToolView.colorView.hidden = YES;
            boardToolView.lineWidthView.hidden = NO;
            boardToolView.drawStyleView.hidden=YES;
        }else if (tag==1009){
            boardToolView.colorView.hidden = YES;
            boardToolView.lineWidthView.hidden = YES;
            boardToolView.drawStyleView.hidden=NO;
            
        }
        [UIView animateWithDuration:.3 animations:^{
            boardToolView.frame=CGRectMake(0,kHeight-40*rate,kWidth, 40*rate);
        }];
        
    }else{
        [self hideTool];
    }
    
}
-(void)hideTool{
    [UIView animateWithDuration:.3 animations:^{
        boardToolView.frame=CGRectMake(0,kHeight,kWidth, 40*rate);
    }];
    
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

- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
-(void)getStartPoint:(CGPoint)startPoint
            endPoint:(CGPoint)endPoint
               color:(NSString*)color
               width:(CGFloat)width
             isClean:(BOOL)isClean
             isbegin:(BOOL)isbegin
               isend:(BOOL)isend{
    if(isbegin||isend||isClean){
        if (isbegin) {
            [self.clientSocket emit:sigMSG with:@[@"start"]];
        }else if (isend){
            [self.clientSocket emit:sigMSG with:@[@"end"]];
        }else{
            [self.clientSocket emit:sigMSG with:@[@"clear"]];
        }
        
    }else{
        NSString* str=[self dictionaryToJson:[dataModel WithColor:color withStrokeWidth:width withX:endPoint.x withY:endPoint.y withTimeStamp:@"" withIsStart:isbegin withIsEnd:isend withFrameWidth:kWidth-160*rate withFrameHeight:height*currentArrays.count withIsClean:isClean]];
        [self.clientSocket emit:pathMSG with:@[str]];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
