//
//  robotViewController.h
//  Robot Controller HD
//
//  Created by 龚儒雅 on 13-8-21.
//  Copyright (c) 2013年 Gong Ruya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ZBarSDK.h"
#import "Cocoa-Touch-Barcodes/NKDEAN13Barcode.h"
#import "Cocoa-Touch-Barcodes/UIImage-NKDBarcode.h"

#import "GCDAsyncSocket.h"
#import "MBProgressHUD.h"

#define SOCKET_SERVER @"192.168.1.102"
#define SOCKET_PORT 50000
#define SOCKET_SIG_START_GUIDE 100
#define SOCKET_SIG_GUIDE_GOT_FIRST 101          //READ
#define SOCKET_SIG_GUIDE_CONTINUE_FIRST 102
#define SOCKET_SIG_GUIDE_GOT_SECOND 103         //READ
#define SOCKET_SIG_GUIDE_CONTINUE_SECOND 104
#define SOCKET_SIG_START_FOLLOW 105
#define SOCKET_SIG_FOLLOW_GOT 106
#define SOCKET_SIG_PAY 110

BOOL Initialized = NO;
BOOL MainAct = YES;
int BtnPressed = 0;             //0 - confirm1   1 - confirm2    2 - delete1    3 - delete2
NSMutableArray *GoodsObjArray;
int InCart = 0; //导购阶段已选取商品数
NSMutableArray *Cart;
NSUInteger GoodsSelected = 9999;
int mode = 9999;
int AlreadyGot = 0;
NSString *srv = nil;

@interface robotViewController:UIViewController<UITableViewDelegate,UITableViewDataSource, ZBarReaderDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *HUD;
}

@property(strong)  GCDAsyncSocket *socket;

- (IBAction)ConfirmButton1;
- (IBAction)ConfirmButton2;
- (IBAction)DeleteButton1;
- (IBAction)DeleteButton2;
- (IBAction)ConnectServer;

@property (weak, nonatomic) IBOutlet UIButton *ConfirmBtn1;
@property (weak, nonatomic) IBOutlet UIButton *ConfirmBtn2;
@property (weak, nonatomic) IBOutlet UIButton *DeleteBtn1;
@property (weak, nonatomic) IBOutlet UIButton *DeleteBtn2;

@property (weak, nonatomic) IBOutlet UITextField *SocketServer;

@property (strong,nonatomic) NSArray * GoodsList;
//存储列表数据

@property (weak, nonatomic) IBOutlet UILabel *GoodsInfoText1;
@property (weak, nonatomic) IBOutlet UILabel *GoodsInfoText2;
@property (weak, nonatomic) IBOutlet UILabel *GoodsInfoText3;
@property (weak, nonatomic) IBOutlet UILabel *GoodsInfoText4;

@property (weak, nonatomic) IBOutlet UILabel *InfoBg1;
@property (weak, nonatomic) IBOutlet UILabel *InfoBg2;

@property (weak, nonatomic) IBOutlet UIImageView *BarcodeGen1;
@property (weak, nonatomic) IBOutlet UIImageView *BarcodeGen2;

@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage;
@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage3;
@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage4;
@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage2;
@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage1;

- (IBAction)StartGuide;

@property (weak, nonatomic) IBOutlet UIButton *StartGuideBtn;

@property (weak, nonatomic) IBOutlet UILabel *TotalPrice;

@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;

@property (weak, nonatomic) IBOutlet UIImageView *Goods1Scanned;
@property (weak, nonatomic) IBOutlet UIImageView *Goods2Scanned;

@property (weak, nonatomic) IBOutlet UIButton *SwitchModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *StartFollowBtn;

- (IBAction)StartFollow;

- (IBAction)Pay;
@property (weak, nonatomic) IBOutlet UIButton *PayBtn;


@property (weak, nonatomic) IBOutlet UITextField *DebugSocketText;
- (IBAction)DebugSocketSend;


@end
//END of VIEWCONTROLLER




//------------------------------------
//商品类
@interface Goods: NSObject {
    @private
    NSString *Name;
    BOOL isfood;
    float price;
    NSString *Barcode;
    UInt8 ID;
}
- (void) init : (UInt8) ID: (NSString*) Name: (BOOL) isfood : (float) price : (NSString *) Barcode;
- (NSString *) getName;
- (BOOL) getIsFood;
- (float) getPrice;
- (NSString *) getBarcode;
- (UInt8) getID;

@end

@interface UILabel (VerticalAlign)
- (void)alignTop;
- (void)alignBottom;
@end

