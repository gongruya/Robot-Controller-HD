//
//  robotViewController.m
//  Robot Controller HD
//
//  Created by 龚儒雅 on 13-8-21.
//  Copyright (c) 2013年 Gong Ruya. All rights reserved.
//

#import "robotViewController.h"

@implementation Goods

- (void) init : (UInt8) Id: (NSString *) Nm : (BOOL) fd : (float) pr : (NSString *) Bc {
    ID = Id; Name = Nm; isfood = fd; price = pr; Barcode = Bc;
}

- (NSString *) getName {
    return Name;
}
- (BOOL) getIsFood {
    return isfood;
}
- (float) getPrice {
    return price;
}
- (NSString *) getBarcode {
    return Barcode;
}
- (UInt8) getID {
    return ID;
}
@end

@implementation UILabel (VerticalAlign)
- (void)alignTop {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)alignBottom {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}
@end


@implementation robotViewController


@synthesize GoodsList=_GoodsList, socket;

- (void) viewDidAppear: (BOOL) animated
{
    // run the reader when the view is visible
    [_readerView willRotateToInterfaceOrientation: UIDeviceOrientationLandscapeLeft
                                        duration: 0.5];
    
}
- (int) GetIDByBarcode: (NSString *) Barcode {
    for (Goods *a in GoodsObjArray)
        if ([[a getBarcode] isEqualToString:Barcode])
            return [a getID];
    return 0;
}
- (Goods *) GetObjByBarcode: (NSString *) Barcode {
    for (Goods *a in GoodsObjArray)
        if ([[a getBarcode] isEqualToString:Barcode])
            return a;
    return 0;
}
- (void) viewWillDisappear: (BOOL) animated
{
    [_readerView stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self Initialization];
    if (!Initialized) {
        Initialized = YES;
        [self InitGoods];
    }
/*
    NSDate *mydate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    _Label1.text=[dateformatter stringFromDate:mydate];
*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _GoodsList=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //返回行数
    return [_GoodsList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//返回一行的视图
    NSUInteger row=[indexPath row];
    NSString * tableIdentifier=@"Simple table";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    //当一行上滚在屏幕消失时，另一行从屏幕底部滚到屏幕上，如果新行可以直接使用已经滚出屏幕的那行，系统可以避免重新创建和释放视图，同一个TableView,所有的行都是可以复用的，tableIdentifier是用来区别是否属于同一TableView
    
    if(cell==nil)
    {
        //当没有可复用的空闲的cell资源时(第一次载入,没翻页)
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
        //UITableViewCellStyleDefault 只能显示一张图片，一个字符串，即本例样式
        //UITableViewCellStyleSubtitle 可以显示一张图片，两个字符串，上面黑色，下面的灰色
        //UITableViewCellStyleValue1 可以显示一张图片，两个字符串，左边的黑色，右边的灰色
        //UITableViewCellStyleValue2 可以显示两个字符串，左边的灰色，右边的黑色
        
    }
    cell.textLabel.text=[NSString stringWithFormat: @"%d. %@", row + 1, [_GoodsList objectAtIndex:row]];//设置文字
    UIImage *image=[UIImage imageNamed:@""];//读取图片,无需扩展名
    cell.imageView.image=image;//文字左边的图片
    //    cell.detailTextLabel.text=@"详细描述"; //适用于Subtitle，Value1，Value2样式
    //    cell.imageView.highlightedImage=image; 可以定义被选中后显示的图片
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//被选中前执行
/*    if ([indexPath row]==0) {
        //第一项不可选
        return nil;
    }
*/
    if (InCart > 1) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//被选中后执行
    GoodsSelected = [indexPath row];
    id tmp = [GoodsObjArray objectAtIndex:[indexPath row]];
    NSString *msgtext = [NSString stringWithFormat:@"%@\n-------------------------------\n%@\n价格：%.2f元\n", [tmp getName], (([tmp getIsFood])?(@"食   品"):(@"学习生活用品")), [tmp getPrice]];

    
    //取出被选中项的文字
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"商品信息" message:msgtext delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //[alert show];
    
      
    //    self.view.backgroundColor = [UIColor whiteColor];
    
    /*
    _BarcodeGen1.layer.borderColor =_BarcodeGen2.layer.borderColor = [UIColor grayColor].CGColor;
    _BarcodeGen1.layer.masksToBounds = _BarcodeGen2.layer.masksToBounds =YES;
    _BarcodeGen1.layer.cornerRadius = _BarcodeGen2.layer.cornerRadius = 5;
    _BarcodeGen1.layer.borderWidth = _BarcodeGen2.layer.borderWidth = 0.5f;
    */
    UIImage *img = [UIImage imageFromBarcode:[[NKDEAN13Barcode alloc] initWithContent:[tmp getBarcode] printsCaption:YES]];


    UIImage *img1=[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", [indexPath row] + 1]];
    _GoodsImage.image = img1;
    img1 = nil;
    
    _GoodsImage.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _GoodsImage.alpha = 1;
        _DeleteBtn1.alpha = _DeleteBtn2.alpha = 0;
    }];
    _DeleteBtn1.enabled = _DeleteBtn2.enabled = NO;
    
    if (InCart == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            _ConfirmBtn1.alpha = _InfoBg1.alpha = _GoodsInfoText1.alpha = _BarcodeGen1.alpha = 0;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            _ConfirmBtn1.alpha = _InfoBg1.alpha = _GoodsInfoText1.alpha = _BarcodeGen1.alpha = 1;
        }];
        _ConfirmBtn1.enabled = YES;
        _BarcodeGen1.image = img;
        _GoodsInfoText1.text = msgtext;
    } else if (InCart == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            _ConfirmBtn2.alpha = _InfoBg2.alpha = _GoodsInfoText2.alpha = _BarcodeGen2.alpha = 0;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            _ConfirmBtn2.alpha = _InfoBg2.alpha = _GoodsInfoText2.alpha = _BarcodeGen2.alpha = 1;
        }];
        _ConfirmBtn2.enabled = YES;
        _BarcodeGen2.image = img;
        _GoodsInfoText2.text = msgtext;
    }
    img = nil;

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //返回每行的高度
    //CGFloat就是float
    return 50.0;
}
/*
 其他可能常用的方法：
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
 以上分别返回table头和尾的高度
 
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
 上面两方法可以自定义table头和尾
 
 */



- (IBAction)ConfirmButton1 {
    BtnPressed = 0;
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle: @"确认信息"
                                                   message: [NSString stringWithFormat:@"确认购买 %@？", [[GoodsObjArray objectAtIndex: GoodsSelected] getName]]
                                                  delegate: self
                                         cancelButtonTitle: @"确认"
                                         otherButtonTitles: @"取消",nil ];
    [alert show];
    alert = nil;
}

- (IBAction)ConfirmButton2 {
    BtnPressed = 1;
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle: @"确认信息"
                                                   message: [NSString stringWithFormat:@"确认购买 %@？", [[GoodsObjArray objectAtIndex: GoodsSelected] getName]]
                                                  delegate: self
                                         cancelButtonTitle: @"确认"
                                         otherButtonTitles: @"取消",nil ];
    [alert show];
    alert = nil;
}

- (IBAction)DeleteButton1 {
    NSLog(@"Delete 1");
    _DeleteBtn1.enabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _TotalPrice.alpha = _ConfirmBtn1.alpha = _DeleteBtn1.alpha = _InfoBg1.alpha = _GoodsInfoText1.alpha = _BarcodeGen1.alpha = 0;
        _ConfirmBtn2.alpha = _DeleteBtn2.alpha = _InfoBg2.alpha = _GoodsInfoText2.alpha = _BarcodeGen2.alpha = 0;
    }];
    --InCart;
    [Cart removeLastObject];
}

- (IBAction)DeleteButton2 {
    NSLog(@"Delete 2");
    _DeleteBtn2.enabled = NO;
    _StartGuideBtn.enabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _StartGuideBtn.alpha = _ConfirmBtn2.alpha = _DeleteBtn2.alpha = _InfoBg2.alpha = _GoodsInfoText2.alpha = _BarcodeGen2.alpha = 0;
    }];
    --InCart;
    [Cart removeLastObject];
    [self UpdatePrice];
}

- (IBAction)ConnectServer {
    NSError *err = nil;
    [socket connectToHost: SOCKET_SERVER onPort: SOCKET_PORT error:&err];
}

- (void) UpdatePrice {
    float price = 0;
    for (Goods *tmp in Cart) {
        price += [tmp getPrice];
        NSLog(@"%.2f", [tmp getPrice]);
    }
    _TotalPrice.text = [NSString stringWithFormat:@"总价格: %.2f元", price];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Button Pressed");
            ++InCart;
            [Cart addObject:[GoodsObjArray objectAtIndex:GoodsSelected]];
            [self UpdatePrice];
            if (BtnPressed == 0) {
                _TotalPrice.alpha = 1;
                _InfoBg1.alpha = 0;
                _ConfirmBtn1.enabled = NO;
                _ConfirmBtn1.alpha = 0;
            } else if (BtnPressed == 1) {
                _InfoBg2.alpha = 0;
                _ConfirmBtn2.enabled = NO;
                _ConfirmBtn2.alpha = 0;
                _StartGuideBtn.enabled = YES;
                [UIView animateWithDuration:0.5 animations:^{
                    _StartGuideBtn.alpha = 1;
                }];
            }
            break;
        case 1:
            NSLog(@"Button 1 Pressed");
            break;
    }
    
}

/* 识别侧滑 */
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"Swipe Left");
    if (mode > 1) {
        CGPoint locationTouch = [gestureRecognizer locationInView:self.view];
        if(CGRectContainsPoint(_InfoBg1.frame, locationTouch)) {
            NSLog(@"Info1 Swipe");
            if (InCart == 1) {
                [UIView animateWithDuration:0.5 animations:^{
                    _DeleteBtn1.alpha = (_DeleteBtn1.alpha==0)?1:0;
                }];
                _DeleteBtn1.enabled = !_DeleteBtn1.enabled;
            }
        } else if (CGRectContainsPoint(_InfoBg2.frame, locationTouch)) {
            NSLog(@"Info2 Swipe");
            if (InCart == 2) {
                [UIView animateWithDuration:0.5 animations:^{
                    _DeleteBtn2.alpha = (_DeleteBtn2.alpha==0)?1:0;
                }];
                _DeleteBtn2.enabled = !_DeleteBtn2.enabled;
            }
        }
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"Swipe Right");
    if (mode == 0 && AlreadyGot > 0) {
        UInt8 SendSignal = 0;
        CGPoint locationTouch = [gestureRecognizer locationInView:self.view];
        if(CGRectContainsPoint(_InfoBg1.frame, locationTouch) && _Goods1Scanned.alpha == 0) {
            NSLog(@"Info1");
            [UIView animateWithDuration:0.5 animations:^{
                _Goods1Scanned.alpha = 0.7;
            }];
            switch (AlreadyGot) {
                case 1:
                    SendSignal = SOCKET_SIG_GUIDE_CONTINUE_FIRST;
                    break;
                case 2:
                    SendSignal = SOCKET_SIG_GUIDE_CONTINUE_SECOND;
                    _SwitchModeBtn.enabled = YES;
                {[UIView animateWithDuration:0.5 animations:^{
                    _SwitchModeBtn.alpha = 1;
                }];}
                    break;
                default:
                    break;
            }
            [self SocketSend: [NSString stringWithFormat: @"%c", SendSignal]];
        } else if (CGRectContainsPoint(_InfoBg2.frame, locationTouch)  && _Goods2Scanned.alpha == 0) {
            NSLog(@"Info2");
            [UIView animateWithDuration:0.5 animations:^{
                _Goods2Scanned.alpha = 0.7;
            }];
            switch (AlreadyGot) {
                case 1:
                    SendSignal = SOCKET_SIG_GUIDE_CONTINUE_FIRST;
                    break;
                case 2:
                    SendSignal = SOCKET_SIG_GUIDE_CONTINUE_SECOND;
                    _SwitchModeBtn.enabled = YES;
                {[UIView animateWithDuration:0.5 animations:^{
                    _SwitchModeBtn.alpha = 1;
                }];}
                    break;
                default:
                    break;
            }
            [self SocketSend: [NSString stringWithFormat: @"%c", SendSignal]];
        }
        [_readerView stop];
        _readerView.alpha = 0;
    }
}


-(void)Initialization {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    //socket init
    socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //socket.delegate = self;
    NSError *err = nil;
/*    if(![socket connectToHost: SOCKET_SERVER onPort: SOCKET_PORT error:&err])
    {
        [self addText:err.description];
    } else
    {
        NSLog(@"ok");
        [self addText:@"打开端口"];
    }
*/
    while (![socket connectToHost: SOCKET_SERVER onPort: SOCKET_PORT error:&err]);
    
    [socket readDataWithTimeout:-1 tag:0];
    
    //显示状态栏
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //初始化
    _GoodsImage.layer.borderColor = _GoodsImage1.layer.borderColor = _GoodsImage2.layer.borderColor = _GoodsImage3.layer.borderColor = _GoodsImage4.layer.borderColor = [UIColor grayColor].CGColor;
    _GoodsImage.layer.masksToBounds = _GoodsImage1.layer.masksToBounds = _GoodsImage2.layer.masksToBounds = _GoodsImage3.layer.masksToBounds = _GoodsImage4.layer.masksToBounds = YES;
    _GoodsImage.layer.cornerRadius = _GoodsImage1.layer.cornerRadius = _GoodsImage2.layer.cornerRadius = _GoodsImage3.layer.cornerRadius = _GoodsImage4.layer.cornerRadius = 10;
    _GoodsImage.layer.borderWidth = _GoodsImage1.layer.borderWidth = _GoodsImage2.layer.borderWidth = _GoodsImage3.layer.borderWidth = _GoodsImage4.layer.borderWidth = 1;
    
    _GoodsImage.alpha = _GoodsImage1.alpha = _GoodsImage2.alpha =  _GoodsImage3.alpha = _GoodsImage4.alpha = 0;
    _GoodsInfoText1.alpha = _GoodsInfoText2.alpha = _GoodsInfoText3.alpha = _GoodsInfoText4.alpha = 0;
    
    _readerView.readerDelegate = self;
    _readerView.alpha = 0;
    _GoodsInfoText1.numberOfLines = _GoodsInfoText2.numberOfLines = 0;
    _GoodsInfoText3.numberOfLines = _GoodsInfoText4.numberOfLines = 0;
    _TotalPrice.text = _InfoBg1.text = _InfoBg2.text = _GoodsInfoText1.text = _GoodsInfoText2.text = _GoodsInfoText3.text = _GoodsInfoText4.text = nil;
    _SwitchModeBtn.alpha = 0; _SwitchModeBtn.enabled = NO;
    _InfoBg1.alpha = _InfoBg2.alpha = 0;
    _DeleteBtn1.enabled = _DeleteBtn2.enabled = _ConfirmBtn1.enabled = _ConfirmBtn2.enabled = NO;
    _DeleteBtn1.alpha = _DeleteBtn2.alpha = _ConfirmBtn1.alpha = _ConfirmBtn2.alpha = 0;
    _Goods1Scanned.alpha = _Goods2Scanned.alpha = 0;
    _StartGuideBtn.alpha = 0; _StartGuideBtn.enabled = NO;
    
    _PayBtn.alpha = 0; _PayBtn.enabled = NO;
    //初始化手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeLeft:)];
    [swipeLeft setNumberOfTouchesRequired:1];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    //[_InfoBg1 setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeRight:)];
    [swipeRight setNumberOfTouchesRequired:1];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}
-(void)InitGoods {
    //初始化商品信息
    NSArray *GoodsName = [NSArray arrayWithObjects:
                          @"康师傅红烧牛肉面", @"可口可乐罐装", @"蒙牛特仑苏牛奶", @"德芙黑巧克力 43克", @"农夫山泉矿泉水 1.5L",
                          @"金锣肉颗粒多", @"达利园蛋黄派", @"娃哈哈八宝粥", @"娃哈哈AD钙奶 220g*4瓶", @"好吃点香脆腰果饼干",
                          @"金丝猴奶糖 118g袋装", @"雀巢脆脆鲨威化饼干", @"康师傅绿茶 550mL", @"黄山毛尖", @"雀巢咖啡罐装",
                          @"清扬男士去屑洗发露", @"天堂雨伞", @"黑人牙膏 90g", @"富光新太空杯 800ml ", @"小闹钟",
                          @"微波饭盒", @"双飞燕鼠标", @"科学计算器", @"英雄蓝色墨水", @"真彩中性笔芯20根装",
                          @"《微积分学导论(下)》", @"笔记本", @"得力订书机", @"LED小台灯", @"心相印纸面巾", nil];
    BOOL goodsisfood[30] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    float goodsprice[30] = {3.5, 2, 4.7, 6.8, 2.5, 14, 9, 3.5, 7, 2.9, 5.9, 23, 2.6, 33.89, 4,
        22, 25, 20, 39, 25, 3.2, 60, 6.4, 3.5, 16, 37.5, 6.6, 13, 33, 5.2};
    
    NSArray *GoodsBarcode = [NSArray arrayWithObjects:
                             @"6920152414019", @"6920476664183", @"6923644266066", @"6914973600041", @"6921168520015",
                             @"6927462214186", @"6911988006783", @"6902083880781", @"6902083881085", @"6911988009777",
                             @"6921681167564", @"6917878131504", @"6920459905166", @"6931386400129", @"6917878027333",
                             @"6902088113112", @"6912003033111", @"4891338005692", @"6921899998084", @"6941326932009",
                             @"6930622800020", @"6949336011332", @"6921734917102", @"6940328702320", @"6945091706056",
                             @"9787312029851", @"6925550576024", @"6921734903259", @"6939020420603", @"6903244984102", nil];
    
    GoodsObjArray = [NSMutableArray arrayWithCapacity:30];
    Cart = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 30; ++i) {
        id NewGoods = [Goods new];
        [NewGoods init:(i + 1):[GoodsName objectAtIndex:i]:goodsisfood[i]:goodsprice[i]:[GoodsBarcode objectAtIndex:i]];
        [GoodsObjArray addObject:NewGoods];
    }
    _GoodsList = GoodsName;
}
-(void)addText:(NSString *)str
{
   NSLog(@"%@\n", str);
}

- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    int GoodsID = 9999;
    NSString * barcode;
    Goods *g;
    ZBarSymbol *sym;
    
    for(sym in syms) {
        NSLog(@"%@", sym.data);
        barcode = sym.data;
        NSLog(@"%d", GoodsID = [self GetIDByBarcode: barcode]);
        break;
    }
    if (GoodsID <= 0 || GoodsID > 30) return;
    
    g = [self GetObjByBarcode: barcode];
    if (mode == 1) {    //跟随模式
        ++AlreadyGot;
        [Cart addObject: g];
        [self UpdatePrice];
        [self SocketSend: [NSString stringWithFormat: @"%c%c", SOCKET_SIG_FOLLOW_GOT, GoodsID]];
        NSString *msgtext = [NSString stringWithFormat:@"%@\n-------------------------------\n%@\n价格：%.2f元\n", [g getName], (([g getIsFood])?(@"食   品"):(@"学习生活用品")), [g getPrice]];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", GoodsID]];
        switch (AlreadyGot) {
            case 3:
                _GoodsInfoText3.text = msgtext;
                _GoodsImage3.image = img;

                {[UIView animateWithDuration:1 animations:^{
                    _GoodsInfoText3.alpha = _GoodsImage3.alpha = 1;
                }];}
                break;
            case 4:
                _GoodsInfoText4.text = msgtext;
                _GoodsImage4.image = img;
                _PayBtn.enabled = YES;
                _readerView.alpha = 0;
                {[UIView animateWithDuration:1 animations:^{
                    _GoodsInfoText4.alpha = _GoodsImage4.alpha = _GoodsInfoText1.alpha = _GoodsImage1.alpha = _GoodsInfoText2.alpha = _GoodsImage2.alpha = _PayBtn.alpha = 1;
                }];}
                [_readerView stop];
                break;
            default:
                break;
        }
    } else if (mode == 0) {
        if ([[Cart objectAtIndex:0] getID] == GoodsID) {
            [UIView animateWithDuration:0.5 animations:^{
                _Goods1Scanned.alpha = 0.7;
            }];
        }
        else if ([[Cart objectAtIndex:1] getID] == GoodsID) {
            _SwitchModeBtn.enabled = YES;
            [UIView animateWithDuration:0.5 animations:^{
                _Goods2Scanned.alpha = 0.7;
            }];
        }
        [_readerView stop];
        _readerView.alpha = 0;
        UInt8 SendSignal = 0;
        switch (AlreadyGot) {
            case 1:
                SendSignal = SOCKET_SIG_GUIDE_CONTINUE_FIRST;
                break;
            case 2:
                SendSignal = SOCKET_SIG_GUIDE_CONTINUE_SECOND;
                {[UIView animateWithDuration:0.5 animations:^{
                    _SwitchModeBtn.alpha = 1;
                }];}
                break;
            default:
                break;
        }
        [self SocketSend: [NSString stringWithFormat: @"%c", SendSignal]];
        
    }
}

-(void)SocketSend:(NSString *) text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData: data withTimeout:-1 tag:0];
    
    [self addText:[NSString stringWithFormat:@"我:%@", text]];
    //[message resignFirstResponder];
    [socket readDataWithTimeout:-1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self addText:[NSString stringWithFormat:@"%@:%@",sock.connectedHost,newMessage]];
    UInt8 SignalReceived= [newMessage characterAtIndex:0];
    UInt8 GoodsGot;
    switch (SignalReceived) {
        case SOCKET_SIG_GUIDE_GOT_FIRST:
            //GoodsGot = [newMessage characterAtIndex:1];
            //处理已找到
            AlreadyGot = 1;
            _readerView.alpha = 1;
            [_readerView start];
            break;
        case SOCKET_SIG_GUIDE_GOT_SECOND:
            //GoodsGot = [newMessage characterAtIndex:1];
            //处理已找到
            AlreadyGot = 2;
            _readerView.alpha = 1;
            [_readerView start];
            break;
        default:
            break;
    }
    
    [socket readDataWithTimeout:-1 tag:0];
}


- (IBAction)StartGuide {
    mode = 0;
    _DeleteBtn2.enabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _DeleteBtn2.alpha = 0;
    }];
    [self SocketSend:[NSString stringWithFormat:@"%c%c%c", SOCKET_SIG_START_GUIDE, [[Cart objectAtIndex:0] getID], [[Cart objectAtIndex:1] getID] ]];
    _StartGuideBtn.enabled = NO;
    _StartGuideBtn.alpha = 0.5;
}

- (IBAction)StartFollow {
    mode = 1;
    Goods *g = [Cart objectAtIndex: 0];
    _GoodsInfoText1.text = [NSString stringWithFormat:@"%@\n-------------------------------\n%@\n价格：%.2f元\n", [g getName], (([g getIsFood])?(@"食   品"):(@"学习生活用品")), [g getPrice]];
    _GoodsImage1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", [g getID]]];
    
    g = [Cart objectAtIndex: 1];
    _GoodsInfoText2.text = [NSString stringWithFormat:@"%@\n-------------------------------\n%@\n价格：%.2f元\n", [g getName], (([g getIsFood])?(@"食   品"):(@"学习生活用品")), [g getPrice]];
    _GoodsImage2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", [g getID]]];
    
    
    _StartFollowBtn.enabled = NO;
    _StartFollowBtn.alpha = 0;
    _readerView.alpha = 1;
    [_readerView start];
    [self SocketSend:[NSString stringWithFormat:@"%c", SOCKET_SIG_START_FOLLOW]];
}

- (IBAction)Pay {
    [self SocketSend:[NSString stringWithFormat: @"%c", SOCKET_SIG_PAY]];
    _PayBtn.alpha = 0.7;
    _PayBtn.enabled = NO;
}
@end