#import "MainView.h"
#import "SoundEngine.h"
#import "Common.h"
#import "JSON.h"
#import "NetworkAvailable.h"
#import "TKND.h"

#define kListenerDistance      0.1f  // リスナー距離
//#define DEBUG_PANEL

// バトルモード
typedef enum {
  kStateNameEntry = 0,
  kStatePicker,
  kStateMultiplayer,
  kStateMultiplayerWaiting,
  kStateMultiplayerCointoss,
  kStateMultiplayerJudge,
  kStateMultiplayerReconnect,
  kStateMultiplayerReplay
} gameStates;

typedef enum {
  kServer,
  kClient
} gameNetwork;

// GameKit Session ID for app
#define kNTTSessionID @"numthetouch"
#define kMaxNTTPacketSize 1024


#pragma mark - MainView Private
//==============================================================================
@interface MainView (private)
- (NSString *)decodeString:(NSString *)urlString;

- (BOOL)checkNowReplayData:(double *)replayData;
- (void)animationStartupInfo;

- (void)createCoverView;    // 連打防止カバーView生成
- (void)destroyCoverView;    // 連打防止カバーView破棄

- (void)downloadDailyAndTotalRankingFromInternet;

- (void)destoryNetworkTimer;

- (void)createGameTimer;
- (void)destoryGameTimer;



- (void)setPrivateRanking;
- (void)setTotalRanking;
- (void)setDailyRanking;
- (void)ExpandedRankingHidden:(BOOL)state;

- (void)postGameCenterPlayCountDaily:(int)count;            // ゲームセンターに1日のプレイ回数を送信する
- (void)postGameCenterPlayScoreTotal:(float)score;            // ゲームセンターにスコア(Total)を送信する
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;  // ゲームセンターにレポートスコアを送信する

// SimpleAlert
- (void)initAllSimpleAlert;
- (void)destoryAllSimpleAlert;
- (void)hideAllSimpleAlert;

- (void)createSimpleAlertJumpToTekunodo;
- (void)handlerSimpleAlertJumpToTekunodo:(NSNumber *)buttonIndex;

- (void)createSimpleAlertConfirmReplay:(NSString *)string;
- (void)handlerSimpleAlertConfirmReplay:(NSNumber *)buttonIndex;

- (void)createSimpleAlertTimeOver;
- (void)handlerSimpleAlertTimeOver:(NSNumber *)buttonIndex;


- (void)createSimpleAlertBattleModeWin;
- (void)handlerSimpleAlertBattleModeWin:(NSNumber *)buttonIndex;

- (void)createSimpleAlertBattleModeLose;
- (void)handlerSimpleAlertBattleModeLose:(NSNumber *)buttonIndex;


- (void)createSimpleAlertErrorDownloadReplay;

@end


//==============================================================================
#pragma mark - implementation MainView


//------------------------------------------------------------------------------
@implementation MainView
@synthesize startDate;
@synthesize textFieldPlayerName;
@synthesize replayDataArray;

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
  LOG();
  self = [super initWithFrame:frame];
  if(self != nil) {
  }
  return self;
}

//------------------------------------------------------------------------------
// アプリ起動時の初期化処理
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder*)coder {
  LOG();
  
  self = [super initWithCoder:coder];
  
  if(self != nil) {
    
    // 画面サイズ取得
    screenSize    = [TKND getScreenSize];    // 画面サイズ取得
    screenCenter  = [TKND getScreenCenter];  // 画面の中心点取得
    
    if(IsIPad){
      LOG(@"iPad");
      screenSize = CGSizeMake(screenSize.width/2, screenSize.height/2);
      screenCenter = CGPointMake(screenCenter.x/2, screenCenter.y/2);
    }
    
    
    if(ALPHABET_FLAG) {
      LOG(@"Alphabet ON!!!!");
    } else {
      LOG(@"Alphabet OFF!!!!");
    }
    
    if(FREE_FLAG) {
      LOG(@"Free ON!!!!");
    } else {
      LOG(@"Free OFF!!!!");
    }
    
    //インターネットアクセスすべきかどうかのフラグの確認。
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"InternetAccess"]==YES){
      flagInternetAccess = YES;
    }
    
    [AdManager sharedManager].view = self;
    

    
    // パネルの色の初期値を登録
    NSDictionary *defaultDic = [NSDictionary dictionaryWithObject:@"0" forKey:@"panelColor"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultDic];
    
    // サウンドの初期化
    SoundEngine_Initialize(44100);
    SoundEngine_SetMasterVolume(1.0);
    
    // 効果音を登録
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"wrap" ofType:@"caf"] UTF8String], &_soundClick);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"select" ofType:@"caf"] UTF8String], &_soundSelect);
    
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"wrap" ofType:@"caf"] UTF8String], &_se[0]);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"wrap" ofType:@"caf"] UTF8String], &_se[1]);
    
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"buzzer" ofType:@"caf"] UTF8String], &_seBuzzer);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"] UTF8String], &_seCount[0]);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"] UTF8String], &_seCount[1]);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"] UTF8String], &_seCount[2]);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"] UTF8String], &_seCount[3]);
    
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"wrap" ofType:@"caf"] UTF8String], &_seFinished[0]);
    SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"seFinishNew" ofType:@"caf"] UTF8String], &_seFinished[1]);
    
    if(ALPHABET_FLAG) {
      SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"ClickAlp" ofType:@"wav"] UTF8String], &_se[2]);
      SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"ClickAlp" ofType:@"wav"] UTF8String], &_se[3]);
      SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"ClickAlp" ofType:@"wav"] UTF8String], &_seFinished[2]);
      SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:@"seFinish_Alp" ofType:@"wav"] UTF8String], &_seFinished[3]);
    }
    

    //画像を登録
    counterNumber[0] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"c1.png"]];
    counterNumber[1] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"c2.png"]];
    counterNumber[2] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"c3.png"]];
    
    //パネル関連
    //    panelColorNo =0;
    
    if(ALPHABET_FLAG) {
      panelImage[0] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Alp.png"]];
      panelImage[1] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Yellow.png"]];
      panelImage[2] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Alp_Pink.png"]];
      panelImage[3] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Blue.png"]];
      panelImage[4] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Purple.png"]];
      panelImage[5] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Red.png"]];
      panelImage[6] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Yellow.png"]];
      
    } else {
      panelImage[0] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Yellow.png"]];
      panelImage[1] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_GY.png"]];
      panelImage[2] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Green.png"]];
      panelImage[3] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Blue.png"]];
      panelImage[4] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Purple.png"]];
      panelImage[5] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Red.png"]];
      panelImage[6] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Panel_Gray.png"]];
    }
  }
  
  if(ALPHABET_FLAG) {
    panel2IMG = [UIImage imageNamed:@"Panel_Alp2.png"];
  } else {
    panel2IMG = [UIImage imageNamed:@"Panel2.png"];
  }
  
  //アニメーションを登録
  CGAffineTransform rotate  = CGAffineTransformMakeRotation(180.0f * (M_PI / 180.0f));
  CGAffineTransform scale    = CGAffineTransformMake(2, 0, 0, 2, 0, 0);
  transform[0]        = CGAffineTransformConcat(rotate, scale);
  
  rotate      = CGAffineTransformMakeRotation(0.0f * (M_PI / 180.0f));
  scale      = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
  transform[1]  =CGAffineTransformConcat(rotate, scale);
  
  rotate      = CGAffineTransformMakeRotation(0.0f * (M_PI / 180.0f));
  scale      = CGAffineTransformMake(0.3, 0, 0, 0.3, 0, 0);
  transform[2]  = CGAffineTransformConcat(rotate, scale);
  
  rotate      = CGAffineTransformMakeRotation(0.0f * (M_PI / 180.0f));
  scale      = CGAffineTransformMake(2, 0, 0, 2, 0, 0);
  transform[3]  = CGAffineTransformConcat(rotate, scale);
  
  pageIsWeekly = YES;
  
  
  rankingData = [[RankingData alloc] init];
  rankingData.flagInternetAccess = flagInternetAccess;
  playerName = rankingData.playerName;
  
  //編集ボタンの設定
  flagEdit = YES;
  
  //広告リフレッシュの設定
  ableToRefresh = YES;
  
  // 待機画面作成
  waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 190.0f, 320.0f, 48.0f)];
  [waitingLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:36.0f]];
  [waitingLabel setText:@"Waiting"];
  [waitingLabel setTextAlignment:NSTextAlignmentCenter];
  [waitingLabel setBackgroundColor:[UIColor blackColor]];
  [waitingLabel setTextColor:[UIColor whiteColor]];
  [waitingLabel setAlpha:0.0];
  
  waitingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, screenSize.height)];
  [waitingView setBackgroundColor:[UIColor blackColor]];
  
  [waitingView addSubview:waitingLabel];
  
  // インフォメーションラベル
  infoLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, screenSize.height - ADVIEW_HEIGHT - 30 - 2, 320.0f, 30.0f)];
  [infoLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:28.0f]];
  [infoLabel setText:@"Replay..."];
  [infoLabel setTextAlignment:NSTextAlignmentRight];
  [infoLabel setBackgroundColor:[UIColor blackColor]];
  [infoLabel setTextColor:[UIColor whiteColor]];
  [infoLabel setAlpha:0.0f];
  
  [self addSubview:infoLabel];
  //  [infoLabel release];
  
  [lblEnemyNextNumber setAlpha:0.0];
  
  // リプレイコントローラー初期化
  replayController  = [[ReplayController alloc] init];
  gameReplay      = 0;  // 非リプレイ状態
  
  // ツールバー
  toolBar.alpha  = 1.0f;
  toolBar.frame  = CGRectMake(0.0f, 0.0f, 320.0f, 30.0f);
  
  // 読込み
  [self loadStats];
  
  // SimpleAlert
  [self initAllSimpleAlert];
  
  // GraphAlert生成
  graphAlert = [[GraphAlert alloc]initWithDelegateAndSelector:self selector:@selector(handlerSimpleAlertConfirmReplay_Post:)];
  // GraphAlertを透過させないView
  backAlertView = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,screenSize.height)];
  backAlertView.backgroundColor = [UIColor blackColor];
  
  // タイマー
  gameTimer    = nil;
  
  // バックグラウンドアクティブ化の設定
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackGround) name:@"enterBackGround" object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"becomeActive" object:nil];
  
  //----------------------------------------------------------
  // リポストした回数を記録 ver3.18
  // DEBUG removeObjectForKey
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Repost_Info"];
  NSArray *arr;
  // 現在の日付
  NSDateFormatter *date = [[NSDateFormatter alloc] init];
  date.dateFormat  = @"MM/dd";
  NSString *nowdate = [date stringFromDate:[NSDate date]];
  LOG(@"*** 今現在:%@",nowdate);
  
  if(![[NSUserDefaults standardUserDefaults] objectForKey:@"Repost_Info"]){
    NSLog(@"*** Repost_Infoがありません・・・。");
    //初回は0で記録
    repostedTimes = 0;
    //現在の日付を記録
    arr = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:repostedTimes],
           nowdate,
           nil];
    // 保存する
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"Repost_Info"];
    
  } else {
    //アプリ起動時に呼び出し
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"Repost_Info"];
    repostedTimes     = (int)[[arr objectAtIndex:0] integerValue];
    NSString *lastday = [arr objectAtIndex:1];
    NSLog(@"*** repostedTimes:%d,repostedTimeslastday:%@",repostedTimes,lastday);
    
    //1日たったらリポストカウントを戻す
    if(![lastday isEqualToString:nowdate]){
      repostedTimes = 0;
      arr = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:repostedTimes],
             nowdate,
             nil];
      // 保存する
      [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"Repost_Info"];
    }
  }
  
//  //----------------------------------------------------------
//  // twitterの設定呼び出し ver3.20
//  if([[NSUserDefaults standardUserDefaults] boolForKey:@"Twitter"]){
//    flagTwitterSwitch        = [[NSUserDefaults standardUserDefaults] boolForKey:@"Twitter"];
//  } else {
//    flagTwitterSwitch = NO;
//    [[NSUserDefaults standardUserDefaults] setBool:flagTwitterSwitch forKey:@"Twitter"];
//  }
//  [[NSUserDefaults standardUserDefaults] synchronize];
//  //----------------------------------------------------------
  flagTwitterSwitch = NO;
  

  return self;
}


//------------------------------------------------------------------------------
// Nib初期化処理
//------------------------------------------------------------------------------
-(void)awakeFromNib {
  LOG();
  [super awakeFromNib];
  
  
  srand((unsigned)time(NULL));
  
  if(ALPHABET_FLAG) {
    //名前入力画面
    [nameEntryImageView setImage:[UIImage imageNamed:@"nameEntry_Alp.png"]];
    //色選択ボタン
    [btnColor0 setBackgroundImage:panelImage[0].image forState:0];
    [btnColor0 setBackgroundImage:panelImage[0].image forState:1];
    [btnColor1 setBackgroundImage:panelImage[1].image forState:0];
    [btnColor1 setBackgroundImage:panelImage[1].image forState:1];
    btnColor2.alpha = 0;
    btnColor3.alpha = 0;
    btnColor4.alpha = 0;
    btnColor5.alpha = 0;
    btnColor6.alpha = 0;
  } else {
    [nameEntryImageView setImage:[UIImage imageNamed:@"nameEntry.png"]];
    nameEntryImageView.frame = CGRectMake(0, -25, 320, 480);
  }
  foot.alpha  = 0.0f;
  
  if(FREE_FLAG) {
    // Footer(Pro版)
    lblStats2.alpha  = 0.0f;
  }
  
  if(flagInternetAccess==YES){
    [self startupInfoProcess];
  }else{
    // startupInfoView生成
    // BG
    startupInfoViewBG.backgroundColor  = [UIColor blackColor];
    startupInfoViewBG.alpha        = 0.5f;
    [self addSubview:startupInfoViewBG];
    
    // 本体
    NSString *tmpMes = [
                        NSString
                        stringWithString:NSLocalizedString(@"Do you want to connect\nto our world-ranking-server\nand Twitter\nvia HTTP?\n\nOnly user inputted name and\ntime will be sent.",nil)
                        ];
    startupInfoLabelTitle.text        = @"Caution";
    startupInfoLabelMessage.text      = tmpMes;
    startupInfoButtonNo.titleLabel.text    = @"No";
    startupInfoButtonYes.titleLabel.text  = @"Yes";
    startupInfoView.backgroundColor      = [UIColor clearColor];
    startupInfoView.alpha          = 0.0f;
    
    [self addSubview:startupInfoView];
    // アニメ初期Transform設定
    [startupInfoView setTransform:transform[2]];
    
    // startupInfoViewのアニメ開始
    [self performSelector:@selector(animationStartupInfo) withObject:nil afterDelay:0.0];
  }
  
  if(FREE_FLAG) {
    [nameEntryView addSubview:adfurikunInterstitialBtnTop];
    [rankingAlViewOwner addSubview:adfurikunInterstitialBtnRanking];
  }
  
  // Newボタン無効化
  newBarButtonItem.enabled = NO;  // awakeFromNib/初期化
  
  //プレイ回数の表示
  if(!FREE_FLAG) {
    startupInfoButton_MoreGames.hidden = YES; // AMoAdボタンの非表示
    [self loadStats];
  }
  
  if(screenSize.height > SCREEN_HEIGHT) {
    // 4インチの場合はtoolBarの高さ分オフセットする
    rankingAlView.frame = CGRectMake(rankingAlView.frame.origin.x, rankingAlView.frame.origin.y + toolBar.frame.size.height, rankingAlView.frame.size.width, rankingAlView.frame.size.height + toolBar.frame.size.height);
  }
  
  // rankingAlViewの親Viewの背景色設定
  rankingAlViewOwner.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
  
  // アラートのパーツを生成
  
  alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
  alertView.backgroundColor = [UIColor blackColor];
  
  alertBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"graph_aleart_dialog.png"]];
  alertBG.frame = CGRectMake(0, 0, 320, 390);
  alertBG.center = CGPointMake(160, 240);
  [alertView addSubview:alertBG];
  
  finishiTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
  finishiTitle.center = CGPointMake(160, 72);
  finishiTitle.backgroundColor = [UIColor clearColor];
  finishiTitle.textAlignment   = NSTextAlignmentCenter;
  finishiTitle.textColor       = [UIColor whiteColor];
  finishiTitle.text            = @"Title";
  finishiTitle.font = [UIFont boldSystemFontOfSize:19];
  [finishiTitle setHighlightedTextColor:[UIColor whiteColor]];
  [alertView addSubview:finishiTitle];
  
  finishiMes = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 280, 42)];
  finishiMes.center = CGPointMake(160, 319);
  finishiMes.backgroundColor = [UIColor clearColor];
  finishiMes.textAlignment   = NSTextAlignmentCenter;
  finishiMes.textColor       = [UIColor whiteColor];
  finishiMes.text            = @"リプレイ / 再送信しますか？";
  finishiMes.numberOfLines   = 2;
  finishiMes.font = [UIFont systemFontOfSize:15];
  [alertView addSubview:finishiMes];
  
  // 各ボタン設定
  alertBtn_Replay = [UIButton buttonWithType:UIButtonTypeCustom];
  alertBtn_Replay.frame = CGRectMake(0, 50, 280, 30);
  alertBtn_Replay.center = CGPointMake(160, 363);
  [alertBtn_Replay setBackgroundImage:[UIImage imageNamed:@"HalfButton0.png"] forState:UIControlStateNormal];
  [alertBtn_Replay setTitle:[NSString stringWithFormat:NSLocalizedString(@"Replay", nil)]
                   forState:UIControlStateNormal];
  alertBtn_Replay.tag = 0;
  [alertBtn_Replay addTarget:self
                      action:@selector(tappedAlertBtn:)
            forControlEvents:UIControlEventTouchUpInside];
  [alertView addSubview:alertBtn_Replay];
  
  alertBtn_Repost = [UIButton buttonWithType:UIButtonTypeCustom];
  alertBtn_Repost.frame = CGRectMake(0, 100, 280, 30);
  alertBtn_Repost.center = CGPointMake(160, 404);
  [alertBtn_Repost setBackgroundImage:[UIImage imageNamed:@"HalfButton0.png"] forState:UIControlStateNormal];
  [alertBtn_Repost setTitle:[NSString stringWithFormat:NSLocalizedString(@"Repost best score", nil)]
                   forState:UIControlStateNormal];
  alertBtn_Repost.tag = 1;
  [alertBtn_Repost addTarget:self
                      action:@selector(tappedAlertBtn:)
            forControlEvents:UIControlEventTouchUpInside];
  [alertView addSubview:alertBtn_Repost];
  
  alertBtn_Cancel = [UIButton buttonWithType:UIButtonTypeCustom];
  alertBtn_Cancel.frame = CGRectMake(0, 150, 280, 30);
  alertBtn_Cancel.center = CGPointMake(160, 404);
  [alertBtn_Cancel setBackgroundImage:[UIImage imageNamed:@"HalfButton1.png"] forState:UIControlStateNormal];
  [alertBtn_Cancel setTitle:@"Cancel" forState:UIControlStateNormal];
  alertBtn_Cancel.tag = 2;
  [alertBtn_Cancel addTarget:self
                      action:@selector(tappedAlertBtn:)
            forControlEvents:UIControlEventTouchUpInside];
  [alertView addSubview:alertBtn_Cancel];
  
  

}



//------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
  LOG();
}


//------------------------------------------------------------------------------
- (void)dealloc {
  LOG();
  [self destoryAllSimpleAlert];
  [self destoryGameTimer];
  [self hideAllSimpleAlert];  // 表示してたら消す
  [self destoryNetworkTimer];
}


#pragma mark - startupInfoView
//==============================================================================
- (void)startupInfoProcess {
  LOG();
  
  [startupInfoViewBG removeFromSuperview];
  [startupInfoView removeFromSuperview];
  
  LOG(@"flagInternetAccess=%d", flagInternetAccess);
  
  if(flagInternetAccess == NO) {
    [btnRankPrivate setAlpha:0.0];
    [btnRankTotal setAlpha:0.0];
    [btnRankWeekly setAlpha:0.0];
    [rankingBackImageView setImage:[UIImage imageNamed:@"RankingBack0.png"]];
    [btnEdit setCenter:CGPointMake(53, 85)];
  } else {
    if(ALPHABET_FLAG) {
      rankURL = @"http://tekunodo.jp/ranking/touchAlp.php";
    } else {
      rankURL = @"http://tekunodo.jp/ranking/ttnRanking.php";
    }
    
    [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4f];

  }
  [self showNameFormAlert];
}


//------------------------------------------------------------------------------
- (void)animationStartupInfo {
  LOG();
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2f];
  [startupInfoView setTransform:transform[1]];
  startupInfoView.center = screenCenter;
  [UIView commitAnimations];
  startupInfoView.alpha = 1.0f;
  
}


//------------------------------------------------------------------------------
- (IBAction)touchStartupInfoButtonNo {
  LOG();
  flagInternetAccess = NO;
  rankingData.flagInternetAccess = NO;
  [self startupInfoProcess];
  SoundEngine_StartEffect( _seCount[3]);  //効果音
}

//------------------------------------------------------------------------------
- (IBAction)touchStartupInfoButtonYes:(id)sender {
  LOG();
  
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"InternetAccess"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  flagInternetAccess = YES;
  rankingData.flagInternetAccess = YES;
  [self startupInfoProcess];
  SoundEngine_StartEffect( _seCount[3]);  //効果音
}


//==============================================================================
#pragma mark - Game

//------------------------------------------------------------------------------
// 名前登録アラートを表示
//------------------------------------------------------------------------------
-(void)showNameFormAlert {
  
  LOG();
  [nameEntryView removeFromSuperview];
  playerScore  = 9999.99;
  rankNow    = 999;
  
  [self insertSubview:nameEntryView belowSubview:tekunodoButton];
  
//  UIButton *btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(98, 90, 48, 48)];
//  [btnTwitter setBackgroundImage:[UIImage imageNamed:@"twit_icon.png"] forState:UIControlStateNormal];
//  [btnTwitter addTarget:self action:@selector(settingTwitter) forControlEvents:UIControlEventTouchUpInside];
//  [nameEntryView addSubview:btnTwitter];
  
  LOG(@"==== リワード広告ボタン配置 ====");
  if(!btnReward){
    btnReward = [[UIButton alloc] initWithFrame:CGRectMake(204, 90, 96, 48)];
    [btnReward setBackgroundImage:[UIImage imageNamed:@"StopAds15min"] forState:UIControlStateNormal];
    [btnReward addTarget:self action:@selector(showMovieReward) forControlEvents:UIControlEventTouchUpInside];
  }
  if([[AdManager sharedManager] movieRewardIsPrepared] && [[AdManager sharedManager] shouldShowAd]){
    [nameEntryView addSubview:btnReward];
  }else{
    [btnReward removeFromSuperview];
  }
  
//  if(!FREE_FLAG) {
//    // 設定ボタン(Pro版)
//    UIButton *btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(257, 90, 51, 51)];
//    [btnSetting setBackgroundImage:[UIImage imageNamed:@"setting_icon.png"] forState:UIControlStateNormal];
//    [btnSetting addTarget:self action:@selector(openSettingsView) forControlEvents:UIControlEventTouchUpInside];
//    [nameEntryView addSubview:btnSetting];
//  }
  
  // ゲームモード
  if(!FREE_FLAG && [settingsViewController getStatusTraningMode] == YES) {
    gameModeView.alpha = 1.0f;
    gameModeLabel.text = @"Traning mode";
  } else {
    gameModeView.alpha = 0.0f;
    gameModeLabel.text = @"";
  }
  
  // 名前入力TextField
  if(!textFieldName){
    textFieldName            = [[UITextField alloc] initWithFrame:CGRectMake(108, 202 - 25, 170.0, 30.0)];
    textFieldName.clearsOnBeginEditing  = NO;
    textFieldName.clearButtonMode    = UITextFieldViewModeWhileEditing;
    textFieldName.returnKeyType      = UIReturnKeyDone;
    textFieldName.text          = [NSString stringWithFormat:@"%@",playerName ];
    [textFieldName setBorderStyle:UITextBorderStyleRoundedRect];
    [textFieldName setDelegate:self];
    [nameEntryView addSubview:textFieldName];
  }
  
  
  // 色選択View
  btnColor0.alpha = 0.3f;
  btnColor1.alpha = 0.3f;
  btnColor2.alpha = 0.3f;
  btnColor3.alpha = 0.3f;
  btnColor4.alpha = 0.3f;
  btnColor5.alpha = 0.3f;
  btnColor6.alpha = 0.3f;
  
  colorNum = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"panelColor"];
  
  switch(colorNum) {
    case 0:    btnColor0.alpha = 1.0f;  break;
    case 1:    btnColor1.alpha = 1.0f;  break;
    case 2:    btnColor2.alpha = 1.0f;  break;
    case 3:    btnColor3.alpha = 1.0f;  break;
    case 4:    btnColor4.alpha = 1.0f;  break;
    case 5:    btnColor5.alpha = 1.0f;  break;
    case 6:    btnColor6.alpha = 1.0f;  break;
    default:              break;
  }
  
  if(ALPHABET_FLAG) {
    btnColor2.alpha = 0;
    btnColor3.alpha = 0;
    btnColor4.alpha = 0;
    btnColor5.alpha = 0;
    btnColor6.alpha = 0;
  }
  colorSelectView.center = CGPointMake(159, 231);
  [nameEntryView addSubview:colorSelectView];
  
  CGRect rect_btnStart = CGRectMake(30, 311, 260, 42);
  CGRect rect_btnChallenge = CGRectMake(164, 258, 126, 42);
  CGRect rect_btnRanking = CGRectMake(30, 258, 126, 42);
  
  // Start Gameボタン
  if(!btnStart){
    btnStart = [[UIButton alloc] initWithFrame:rect_btnStart];
    [btnStart setBackgroundImage:[UIImage imageNamed:@"HalfButton0.png"] forState:UIControlStateNormal];
    [btnStart setTitle:@"Start Game" forState:UIControlStateNormal];
    [btnStart.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19]];
    [btnStart setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnStart addTarget:self action:@selector(touchStartGame) forControlEvents:UIControlEventTouchUpInside];
    [nameEntryView addSubview:btnStart];
  }
  
  // Challengeボタン
  if(!btnChallenge){
    btnChallenge = [[UIButton alloc] initWithFrame:rect_btnChallenge];
    [btnChallenge setBackgroundImage:[UIImage imageNamed:@"HalfButton1.png"] forState:UIControlStateNormal];
    
    UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 96, 42)];
    [challengeLabel setText:[NSString stringWithFormat:@"Level %d",[self selectedlevel]]];
    [challengeLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:15]];
    challengeLabel.textColor = [UIColor whiteColor];
    challengeLabel.textAlignment = NSTextAlignmentCenter;
    
    [btnChallenge addSubview:challengeLabel];
    
    UIImageView *challengeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 0, 30, 43)];
    [challengeIcon setImage:[UIImage imageNamed:@"ic_challenge.png"]];
    [btnChallenge addSubview:challengeIcon];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchChallengeGame)];
    [btnChallenge addGestureRecognizer:tapGesture];
    
    [nameEntryView addSubview:btnChallenge];
  }
  
  // Rankingボタン
  if(!btnRanking){
    btnRanking = [[UIButton alloc] initWithFrame:rect_btnRanking];
    [btnRanking setBackgroundImage:[UIImage imageNamed:@"HalfButton0.png"] forState:UIControlStateNormal];
    [btnRanking setTitle:@"Ranking" forState:UIControlStateNormal];
    [btnRanking setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnRanking.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [btnRanking addTarget:self action:@selector(touchWebRanking) forControlEvents:UIControlEventTouchUpInside];
    [nameEntryView addSubview:btnRanking];
  }
  
  
  if(FREE_FLAG) {
    // 自社広告
    footerView.alpha  = 0.0f;
    foot.alpha      = 0.0f;
    lblStats2.alpha    = 0.0f;
  } else {
    // ユーザー情報を表示(Pro版)
    footerView.frame  = CGRectMake(0, screenSize.height - 50, 320, 50);
    foot.alpha      = 1.0f;
    lblStats2.alpha    = 1.0f;
    
    [lblStats2 setText:[NSString stringWithFormat:@"Play count Total : %5d\n            Today : %5d", totalPlay, dailyPlay]];
    [lblStats2 setLineBreakMode:NSLineBreakByWordWrapping];  //改行モード
    [lblStats2 setNumberOfLines:0];
  }
  
  if(!flagCountStop){
    [nameEntryView setTransform:transform[2]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [nameEntryView setTransform:transform[1]];
    [UIView commitAnimations];
  }
  
  //[[AdManager sharedManager] showBanner];
  [[AdManager sharedManager] showMovieNative];

}

//------------------------------------------------------------------------------
// 色変更ボタンを押したときの処理
//------------------------------------------------------------------------------
- (IBAction)changeColor:(UIButton*)sender{
  LOG();
  
  btnColor0.alpha = 0.3f;
  btnColor1.alpha = 0.3f;
  btnColor2.alpha = 0.3f;
  btnColor3.alpha = 0.3f;
  btnColor4.alpha = 0.3f;
  btnColor5.alpha = 0.3f;
  btnColor6.alpha = 0.3f;
  
  if(ALPHABET_FLAG) {
    btnColor2.alpha = 0.0f;
    btnColor3.alpha = 0.0f;
    btnColor4.alpha = 0.0f;
    btnColor5.alpha = 0.0f;
    btnColor6.alpha = 0.0f;
  }
  
  colorNum = (int)sender.tag;
  [sender setAlpha:1.0];
  SoundEngine_StartEffect( _soundSelect);
}

#pragma mark - UITextFieldDelegate

//------------------------------------------------------------------------------
// 入力内容が変化したとき呼ばれる
//------------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  LOG();
  
  //文字入力数の制限と、名前の更新
  BOOL change = NO;
  
  if(range.location + range.length + [string length] < 24) {
    playerName  = [NSString stringWithFormat:@"%@%@",textFieldName.text,string];
    change    = YES;
  }
  LOG(@"string = %@",string);
  LOG(@"%d",[string isEqualToString:@"&"] );
  
  if(  [string isEqualToString:@"&"] || [string isEqualToString:@"<"] ||
     [string isEqualToString:@">"] || [string isEqualToString:@"'"] ||
     [string isEqualToString:@"$"] || [string isEqualToString:@","]
     )
  {
    change = NO;
  }
  
  return change;
  
}


//------------------------------------------------------------------------------
//  完了ボタンが押されたときに呼ばれる
//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)tf{
  LOG();
  
  if([textFieldName canResignFirstResponder]) {
    [textFieldName resignFirstResponder];
  }
  playerName = [NSString stringWithFormat:@"%@", textFieldName.text];
  rankingData.playerName = playerName;
  return YES;
}

#pragma mark -

//------------------------------------------------------------------------------
// ニューゲーム
//------------------------------------------------------------------------------
- (IBAction)newGameFromRanking {
  LOG();
  
  playerScore  = 9999.99f;
  gameState  = 1;
  
  [self hideEditBtn];    // 編集モード解除の処理
  [self stopEditing];
  
  [self newGame];
}

- (IBAction)newGameFromChallenge {
  LOG();
  
  gameChallenge = 0;
  gameState  = 1;
  
  [self newGame];
  
}


//------------------------------------------------------------------------------
- (IBAction)newGame {
  LOG();
  
  if(gameState != 0 ){
    

    [infoLabel setAlpha:0.0f];
    
    [numbersView removeFromSuperview];
    [titleView removeFromSuperview];
    [rankingAlViewOwner removeFromSuperview];
    [challengeInfoViewOwner removeFromSuperview];
    [challengeFinishViewOwner removeFromSuperview];
    [challengeFailedViewOwner removeFromSuperview];
    
    [self destoryGameTimer];  // ゲームタイマーが動いていたら止める
    [self showNameFormAlert];

    
    if (!flagRestart && !flagCountStop){
      SoundEngine_StartEffect( _soundClick);  //効果音
    }
    [self performSelector:@selector(newGame2) withObject:nil afterDelay:0.5f];
    
  }
  infoLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
}


//------------------------------------------------------------------------------
- (void)newGame2 {
  LOG();
  
  gameState    = 0;
  gameReplay    = 0;
  gameChallenge   = 0;
  infoLabel.alpha  = 0.0f;
}


//------------------------------------------------------------------------------
// スタートボタンにタッチした
//------------------------------------------------------------------------------
-(IBAction)touchStartGame{
  LOG();
  
  [[AdManager sharedManager] hideMovieNative];
  
  // 編集モードの処理
  if(!flagEdit){
    [self show_EdittingMode];
  } else {
    
  }
  
  // ゲームタイマーが動いていたら止める
  [self destoryGameTimer];
  
  // ゲームモード(通常)
  gameReplay = 0;
  
  // ゲーム内乱数初期化
  stage = time(NULL);
  srand((unsigned)stage);
  
  [self startGame];
  tekunodoButton.enabled  = NO;  // tekunodo.ボタン有効化
}

#pragma mark - Ads

- (void)showMovieReward{

  [[AdManager sharedManager] showMovieReward];
  [btnReward removeFromSuperview];
  
}

#pragma mark - Challenge Mode
//------------------------------------------------------------------------------
// チャレンジモード関連は以下にまとめる
//------------------------------------------------------------------------------
//クリア後の動作では次のレベルへ
- (IBAction)touchFinishToNext {
  int nextlevel = gameLevel+1;
  if(nextlevel > 100) nextlevel = 100;
  [[NSUserDefaults standardUserDefaults] setInteger:nextlevel forKey:@"SelectedLevel"];
  
  [self touchChallengeGame];
}

- (IBAction)touchFinishToNew:(id)sender {
  int nextlevel = gameLevel+1;
  if(nextlevel > 100) nextlevel = 100;
  [[NSUserDefaults standardUserDefaults] setInteger:nextlevel forKey:@"SelectedLevel"];
  
  [self newGame];
}

-(IBAction)touchChallengeGame{
  LOG();
  
  SoundEngine_StartEffect( _seCount[3]);  //効果音
  
  //終了時にもここを通るため結果表示viewを消す
  [challengeFinishViewOwner removeFromSuperview];
  [challengeFailedViewOwner removeFromSuperview];
  
  //現在のレベルを取得 ver3.24
  selectedLevel = [self selectedlevel];
  gameLevel = selectedLevel;
  [selectedLevelLabel setText:[NSString stringWithFormat:@"LEVEL %d",selectedLevel]];
  
  //アチーブメント(星)の情報取得
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Achievement"]) {
    
    // Dataがあれば
    achievementArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"Achievement"];
    
    //初期起動処理
  }else{
    
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 100; i++) { // ~ Level 100 までの配列作成
      [dataArr addObject:[NSNumber numberWithInt:0]];
    }
    
    // Save
    [[NSUserDefaults standardUserDefaults] setObject:dataArr forKey:@"Achievement"];
    
    NSLog(@"--- Achievement Saved!");
    
  }
  
  [self initChallengeInfo];
  
  [self showChallengeInfoView];
  
}

-(void)showChallengeInfoView{
  
  
  [challengeInfoView setTransform:transform[2]];
  [self addSubview:challengeInfoViewOwner];
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.32];
  [challengeInfoView setTransform:transform[1]];
  [UIView commitAnimations];
  
  //名前入力ビューを削除
  [nameEntryView removeFromSuperview];
  
  if(FREE_FLAG) {
  } else {
    [foot setAlpha:1.0];
  }
  
}

- (IBAction)touchStartChallenge:(id)sender {
  
  //終了時にもここを通るため結果表示viewを消す
  [challengeFinishViewOwner removeFromSuperview];
  [challengeFailedViewOwner removeFromSuperview];
  
  gameChallenge = 1;
  
  [self touchStartGame];
  
}

//challengeInfoViewの表示周りの実装

-(void)initChallengeInfo{
  
  [selectedLevelLabel setText:[NSString stringWithFormat:@"LEVEL %d",gameLevel]];
  
  NSString *path = [[NSBundle mainBundle]pathForResource:@"stage" ofType:@"plist"];
  
  NSDictionary *stageDic = [NSDictionary dictionaryWithContentsOfFile:path];
  
  NSLog(@"れべる%d",gameLevel);
  //そのレベルの情報読み込んで表示する
  NSString *levelStr = [NSString stringWithFormat:@"LEVEL %d",gameLevel];
  
  NSDictionary *nowlevelDic = [NSDictionary dictionaryWithDictionary:
                               [stageDic objectForKey:levelStr]];
  
  NSLog(@"すとりんぐ%@",levelStr);
  
  panel_color = [[nowlevelDic objectForKey:@"panel_color"]intValue];
  
  start_panel = [[nowlevelDic objectForKey:@"start_panel"]intValue];
  
  end_panel = [[nowlevelDic objectForKey:@"end_panel"]intValue];
  
  limit_time = [[nowlevelDic objectForKey:@"limit_time"]floatValue];
  
  selectedInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ChallengeInfoMsg", nil), limit_time, start_panel, end_panel];
  
  
  //7ランダム色
  if(panel_color == 7){
    selectedPanelImage.image = [UIImage imageNamed:@"panel_shuffle.png"];
  }else{
    selectedPanelImage.image = panelImage[panel_color].image;
  }
  
  //ピッカービュー角丸
  challengePickerView.layer.cornerRadius = 5;
  
  [challengePickerView reloadComponent:0];
  
  [challengePickerView selectRow:[self nowlevel] - gameLevel inComponent:0 animated:NO];
  
}

//PickerViewのデリゲートメソッドとか

// Component
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  
  return 1;
}

// Row
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
  
  return [self nowlevel];
  
}

// 表示する内容
- (NSString*)pickerView:(UIPickerView*)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component {
  
  NSMutableArray *strArr = [[NSMutableArray alloc]init];
  
  for (int i = 0; i < row; i++) {
    [strArr addObject:[NSString stringWithFormat:@"%d",row+1]];
  }
  
  return [strArr objectAtIndex:row];
}

- (int)nowlevel {
  
  if([[NSUserDefaults standardUserDefaults] integerForKey:@"NowLevel"]){
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"NowLevel"];
  } else {
    return 1;
  }
}

-(int)selectedlevel{
  
  if([[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"]){
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLevel"];
  } else {
    return 1;
  }
  
}

// 幅設定
- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component {
  return 40.0f;
}


// Picker変更時の処理
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  
  // Change Game Level
  gameLevel = [self nowlevel] - (int)row;
  
  [[NSUserDefaults standardUserDefaults] setInteger:gameLevel forKey:@"SelectedLevel"];
  
  //情報更新
  [self initChallengeInfo];
  
}

// Row Customize
- (UIView*)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view_
{
  
  float rowWidth, rowHeight;
  rowWidth  = challengePickerView.frame.size.width;
  rowHeight = 40.0f;
  
  // 星の数
  int pickerstarNum = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"Achievement"] objectAtIndex:[self nowlevel] -row -1]intValue];
  
  // View
  UIView *view = [[UIView alloc]init];
  view.frame   = CGRectMake(0, 0, rowWidth, rowHeight);
  //  view.backgroundColor = self.backgroundColor;
  view.backgroundColor =[UIColor whiteColor];
  //    view.layer.cornerRadius = 5;
  
  // Label
  UILabel *label  = [[UILabel alloc]initWithFrame:view.frame];
  label.frame     = CGRectMake(0.0f, 0.0f, 55.0f, rowHeight); // font補正
  label.textColor = [UIColor darkGrayColor];
  label.text      = [NSString stringWithFormat:@"%d",[self nowlevel] - row];
  label.textColor = [UIColor blackColor];
  label.textAlignment = NSTextAlignmentCenter;
  [view addSubview:label];
  
  float starPointX = 48.0f;
  
  // Version
  if ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f) { // iOS6以下
    view.backgroundColor = [UIColor clearColor];
    label.backgroundColor = [UIColor clearColor];
    starPointX -= 13.0f;
  }
  
  
  // Image View *Star Count
  for (int i = 0; i < 3; i++) { // starNum
    
    UIImage *star;
    
    
    
    if (i < pickerstarNum) {
      star = [UIImage imageNamed:@"ic_star_on.png"];
    } else {
      star = nil; //　星なし
    }
    
    UIImageView *image = [[UIImageView alloc] initWithImage:star];
    image.frame = CGRectMake(starPointX + i*35.0f, 5.0f, 30.0f, 30.0f);
    [view addSubview:image];
  }
  
  return view;
}

//------------------------------------------------------------------------------
//チャレンジモードの終了時のView関連は以下にまとめる
//------------------------------------------------------------------------------
-(void)initChallengeFinish {
  
  [challengeFinishLabel setText:[NSString stringWithFormat:NSLocalizedString(@"ChallengeClearMsg", nil),gameLevel]];
  
  challengeFinishMoreBtn.alpha = 0.0f;
  challengeFinishNextBtn.alpha = 0.0f;
  challengeFinishRetryBtn.alpha = 0.0f;
  adfuriView_Finish.alpha = 0.0f;
  
  [self setFinishStars];
  
}

-(void)showChallengeFinishView {
  
  [challengeFinishView setTransform:transform[2]];
  [self addSubview:challengeFinishViewOwner];
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.32];
  [challengeFinishView setTransform:transform[1]];
  [UIView commitAnimations];
  
  [self performSelector:@selector(setChallengeFinishViewAlpha_On) withObject:nil afterDelay:1.32f];
  
}

-(void)setChallengeFinishViewAlpha_On{
  challengeFinishMoreBtn.alpha = 1.0f;
  challengeFinishNextBtn.alpha = 1.0f;
  challengeFinishRetryBtn.alpha = 1.0f;
  adfuriView_Finish.alpha = 1.0f;
}

-(void)initChallengeFailed{
  challengeFailedMoreBtn.alpha = 0.0f;
  challengeFailedRetryBtn.alpha = 0.0f;
  adfuriView_Failed.alpha = 0.0f;
}

-(void)showChallengeFailedView{
  
  //効果音
  SoundEngine_StopEffect(_seBuzzer, YES);
  SoundEngine_StartEffect( _seBuzzer);
  
  [challengeFailedView setTransform:transform[2]];
  [self addSubview:challengeFailedViewOwner];
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.32];
  [challengeFailedView setTransform:transform[1]];
  [UIView commitAnimations];
  
  [self performSelector:@selector(setChallengeFailedViewAlpha_On) withObject:nil afterDelay:1.32f];
}

-(void)setChallengeFailedViewAlpha_On{
  challengeFailedMoreBtn.alpha = 1.0f;
  challengeFailedRetryBtn.alpha = 1.0f;
  adfuriView_Failed.alpha = 1.0f;
}

//チャレンジ終了画面の星セット
-(void)setFinishStars{
  
  [challengeFinishStar_1 setImage:[UIImage imageNamed:@"ic_star_off.png"]];
  [challengeFinishStar_2 setImage:[UIImage imageNamed:@"ic_star_off.png"]];
  [challengeFinishStar_3 setImage:[UIImage imageNamed:@"ic_star_off.png"]];
  
  switch (starNum) {
    case 1:
      [challengeFinishStar_1 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      break;
    case 2:
      [challengeFinishStar_1 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      [challengeFinishStar_2 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      break;
    case 3:
      [challengeFinishStar_1 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      [challengeFinishStar_2 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      [challengeFinishStar_3 setImage:[UIImage imageNamed:@"ic_star_on.png"]];
      break;
      
    default:
      break;
  }
  
}
//アチーブメント保存
- (void)saveAchievementData {
  
  NSMutableArray *dataArr;
  
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Achievement"]) {
    
    NSArray *arr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Achievement"]];
    
    dataArr = [NSMutableArray arrayWithArray:arr];
    
    // 更新かどうか
    int nowLevelData = [[dataArr objectAtIndex:gameLevel-1]intValue];
    
    NSLog(@"--- Compare Now Data:%d, Achivement Data:%d",starNum, nowLevelData);
    
    if (nowLevelData < starNum) { // Achivement 更新
      [dataArr replaceObjectAtIndex:gameLevel-1 withObject:[NSNumber numberWithInt:starNum]];
    }
    
    // Save
    [[NSUserDefaults standardUserDefaults] setObject:dataArr forKey:@"Achievement"];
    NSLog(@"Achievement Save!!");
  }
  
}

// クリアしたら呼ばれる
- (void)checkGettingAchievement:(float)noSeconds {
  
  float rateValue = (float)noSeconds / (float)limit_time;
  
  starNum = 0;
  
  if (rateValue < 0.8) {
    starNum = 3;
  } else if (rateValue < 0.9) {
    starNum = 2;
  } else if (rateValue <= 1.0) {
    starNum = 1;
  } else{
    starNum = 1;
  }
  
  // Save
  [self saveAchievementData];
}

- (void)saveMyLevel{
  
  int saveLevel = gameLevel + 1;
  
  // Setting Max Level
  if (100 < saveLevel) {
    saveLevel = 100;
  }
  
  int maxLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NowLevel"]intValue];
  
  // Save Data
  if (maxLevel < saveLevel) { // レベル更新したら
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:saveLevel]
                                              forKey:@"NowLevel"];
    
    NSLog(@"--- 最高レベル:%d 更新！！ Saved...",saveLevel);
  }
  
}


//------------------------------------------------------------------------------
-(void)startGame {
  LOG();
  
  newBarButtonItem.enabled = NO;  // startGame/スタートボタン押下、リプレイ、バトル
  
  [infoLabel setAlpha:0.0f];
  
  //チャレンジモード情報viewを消す
  [challengeInfoViewOwner removeFromSuperview];
  
  //待機画面を消す
  [waitingLabel setAlpha:0.0f];
  [waitingView removeFromSuperview];
  
  // 白に戻しておく
  [lblNextNumber setTextColor:[UIColor whiteColor]];
  
  win = 0;
  
  //チャレンジモード時
  if(gameChallenge == 1){
    nextNumber = start_panel-1;
    
    
  }else{
    nextNumber = 0;
    
  }
  
  [self updateLblNext];
  
  if(battleState != kStateNameEntry) {
    [lblNextNumber setTextColor:[UIColor whiteColor]];
    [lblEnemyNextNumber setTextColor:[UIColor whiteColor]];
    
    nextEnemyNumber      = 1;
    lblEnemyNextNumber.text  = [NSString stringWithFormat:@"%2d",nextEnemyNumber];
  }
  [self loadStats];
  
  // とりあえずラベル消去
  [foot setAlpha:0.0f];
  [lblStats2 setText:@""];
  
  // 名前エントリーやランキングを外す
  [nameEntryView removeFromSuperview];
  [rankingAlViewOwner removeFromSuperview];
  
  // インジケーターを外す
  [indicatorView removeFromSuperview];
  
  // 未ポスト状態にする
  isPosted    = 0;
  gameState    = 0;  //カウント中
  playerScore    = 9999.99;
  ableToRefresh  = NO;
  
  // パネルカラー登録
  [[NSUserDefaults standardUserDefaults] setInteger:colorNum forKey:@"panelColor"];
  
  // 0秒後に「3」の表示をする。
  [self performSelector:@selector(showCountThree) withObject:nil afterDelay:0.0f];
}


//------------------------------------------------------------------------------
//  カウント3
//------------------------------------------------------------------------------
-(void)showCountThree {
  LOG();
  NSLog(@"***** カウント３");
  // フラグ初期化
  flagCountStop = NO;
  
  [numbersView removeFromSuperview];
  counterNumber[2].center = CGPointMake(screenCenter.x, screenCenter.y);
  [counterNumber[2] setTransform:transform[2]];
  [self addSubview:counterNumber[2]];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.2];
  [counterNumber[2] setTransform:transform[1]];
  [UIView commitAnimations];
  
  SoundEngine_StartEffect( _seCount[0]);  //効果音
  
  [self performSelector:@selector(showCountTwo) withObject:nil afterDelay:1.0f];
}

//------------------------------------------------------------------------------
//  カウント2
//------------------------------------------------------------------------------
-(void)showCountTwo {
  LOG();
  
  NSLog(@"***** カウント２");
  SoundEngine_SetMasterVolume(1.0);
  
  ableToRefresh = NO;
  
  counterNumber[1].center = CGPointMake(screenCenter.x, screenCenter.y);
  [counterNumber[2] removeFromSuperview];
  
  [counterNumber[1] setTransform:transform[2]];
  [self addSubview:counterNumber[1]];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.2];
  [counterNumber[1] setTransform:transform[1]];
  [UIView commitAnimations];
  
  SoundEngine_StartEffect( _seCount[1]);  //効果音
  
  [self performSelector:@selector(showCountOne) withObject:nil afterDelay:1.0f];
  
}

//------------------------------------------------------------------------------
//  カウント1
//------------------------------------------------------------------------------
-(void)showCountOne {
  LOG();
  
  NSLog(@"***** カウント１");
  counterNumber[0].center = CGPointMake(screenCenter.x, screenCenter.y);
  [counterNumber[1] removeFromSuperview];
  
  [counterNumber[0] setTransform:transform[2]];
  [self addSubview:counterNumber[0]];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.2];
  [counterNumber[0] setTransform:transform[1]];
  [UIView commitAnimations];
  
  SoundEngine_StartEffect( _seCount[2]);  //効果音
  
  [self performSelector:@selector(start) withObject:nil afterDelay:1.0f];
  
}

//------------------------------------------------------------------------------
// ゲーム内で使用するパネルデータ作成
//------------------------------------------------------------------------------
- (void)createGamePanelData {
  LOG();
  
  // 数字を割り当て
  for(int i = 0; i < PANEL_MAX; i++){
    btnNumberValue[i] = i + 1;
  }
  
#ifndef DEBUG_PANEL
  //　数字を入替え
  for(int i = 0; i < PANEL_MAX; i++){
    int  rnd        = rand() % PANEL_MAX;
    int  tmp        = btnNumberValue[i];
    btnNumberValue[i]  = btnNumberValue[rnd];
    btnNumberValue[rnd]  = tmp;
  }
#endif
}


//------------------------------------------------------------------------------
//  ゲームスタート
//------------------------------------------------------------------------------
-(void)start {
  LOG();
  
  // analytics
  //  [tracker trackView:@"/game"];
  
  flagRestart = YES; // バックグラウンドの処理
  
  if(FREE_FLAG) {
    //    adfurikunView.hidden = NO;  // start/アドフリくん表示
  }
  newBarButtonItem.enabled  = YES;  // start/通常ゲーム、リプレイ、バトル
  tekunodoButton.enabled    = YES;  // tekunodo.ボタン有効化
  
  // バトルモードではない、リプレイモードでなければ統計情報表示(練習モードは状態としてありえない)
  if(battleState == kStateNameEntry && gameReplay != 1) {
    if(!FREE_FLAG) {
      [foot setAlpha:1.0f];
    }
    [lblStats2 setText:[NSString stringWithFormat:@"Play count Total : %5d\n            Today : %5d", totalPlay, dailyPlay]];
    [lblStats2 setLineBreakMode:NSLineBreakByWordWrapping];//改行モード
    [lblStats2 setNumberOfLines:0];
  } else {
    if(FREE_FLAG) {
      [foot setAlpha:0.0f];
    }
  }
  
  if(battleState != kStateNameEntry) {
    if(battleState == kStateMultiplayer) {
      infoLabel.alpha  = 1.0f;
      infoLabel.text  = @"Battle mode";
      infoLabel.font  = [UIFont fontWithName:@"Verdana-Bold" size:14.0f];
    } else {
      infoLabel.font  = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
    }
    lblEnemyNextNumber.alpha = 1.0f;
  } else {
    if(gameReplay == 0 && [settingsViewController getStatusTraningMode] == YES) {
      infoLabel.alpha  = 1.0f;
      infoLabel.text  = @"Traning mode";
      infoLabel.font  = [UIFont fontWithName:@"Verdana-Bold" size:14.0f];
    } else {
      infoLabel.font  = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
    }
    lblEnemyNextNumber.alpha = 0.0f;
  }
  
  ableToRefresh = NO;
  
  [counterNumber[0] removeFromSuperview];
  
  LOG(@"Start");
  gameState      = 1;  //ゲーム中
  rankNow        = 100;
  numbersView.alpha  = 1.0f;
  numbersView.frame  = CGRectMake((toolBar.frame.size.width - numbersView.frame.size.width) / 2, toolBar.frame.size.height, numbersView.frame.size.width, numbersView.frame.size.height);
  [self addSubview:numbersView];
  
  // ゲーム内で使用するパネルデータ作成
  [self createGamePanelData];
  
  [self setButton:btnNumber0 num:0];
  [self setButton:btnNumber1 num:1];
  [self setButton:btnNumber2 num:2];
  [self setButton:btnNumber3 num:3];
  [self setButton:btnNumber4 num:4];
  [self setButton:btnNumber5 num:5];
  [self setButton:btnNumber6 num:6];
  [self setButton:btnNumber7 num:7];
  [self setButton:btnNumber8 num:8];
  [self setButton:btnNumber9 num:9];
  [self setButton:btnNumber10 num:10];
  [self setButton:btnNumber11 num:11];
  [self setButton:btnNumber12 num:12];
  [self setButton:btnNumber13 num:13];
  [self setButton:btnNumber14 num:14];
  [self setButton:btnNumber15 num:15];
  [self setButton:btnNumber16 num:16];
  [self setButton:btnNumber17 num:17];
  [self setButton:btnNumber18 num:18];
  [self setButton:btnNumber19 num:19];
  [self setButton:btnNumber20 num:20];
  [self setButton:btnNumber21 num:21];
  [self setButton:btnNumber22 num:22];
  [self setButton:btnNumber23 num:23];
  [self setButton:btnNumber24 num:24];
  
  SoundEngine_StartEffect(_seCount[3]);  //効果音
  
  // 開始時間取得
  self.startDate = [NSDate date];
  
  // ゲームタイマー生成
  [self createGameTimer];
  
  // finishedは一ゲームいっかいしかきません（主に通信用）
  finishOnce = 0;
  
  // カウントダウン時にバックグララウンドに回るとリスタート
  if(flagCountStop){
    [self performSelector:@selector(newGame) withObject:nil afterDelay:0.3f];
  }
}

//------------------------------------------------------------------------------
//  ゲームクリア処理
//------------------------------------------------------------------------------
-(void)finished {
  LOG();
  
  // バックグラウンドのフラグを初期化
  flagRestart = NO;
  
  if(!FREE_FLAG) {  // Pro版のみ
    // リプレイではない かつ バトルモードではない かつ 練習モードの場合
    if(gameReplay == 0 && battleState == kStateNameEntry && [settingsViewController getStatusTraningMode] != FALSE) {
      // 規定時間で成功
      SoundEngine_StopEffect(_seBuzzer, YES);
      SoundEngine_StartEffect(_seFinished[1]);  //効果音
      [self touchStartGame];            // ゲーム再開
      return;
    }
  }
  
  if(gameReplay != 1) {
    rankingPage = 0;
    replayType  = kReplayType_Private;  // 20120514 ランキング表示不具合修正
  }
  
  switch(rankingPage) {
    case 0: {
      [btnRankPrivate setAlpha:1.0f];
      [btnRankTotal setAlpha:0.5f];
      [btnRankWeekly setAlpha:0.5f];
    }
      break;
      
    case 1: {
      [btnRankPrivate setAlpha:0.5f];
      [btnRankTotal setAlpha:1.0f];
      [btnRankWeekly setAlpha:0.5f];
    }
      break;
      
    case 2: {
      [btnRankPrivate setAlpha:0.5f];
      [btnRankTotal setAlpha:0.5f];
      [btnRankWeekly setAlpha:1.0f];
    }
      break;
      
    default: {
    }
      break;
  }
  
  //ネット接続がないときはボタンを消す。
  if(flagInternetAccess == NO){
    [btnRankPrivate setAlpha:0.0f];
    [btnRankTotal setAlpha:0.0f];
    [btnRankWeekly setAlpha:0.0f];
    [rankingBackImageView setImage:[UIImage imageNamed:@"RankingBack0.png"]];
  }
  
  // バトルモードのネットワーク対戦時に何度もここに入ってきてしまう可能性があるためブロック
  if(finishOnce == 1) {
    return;
  }
  finishOnce = 1;
  
  ableToRefresh = YES;
  SoundEngine_StopBackgroundMusic(FALSE);
  
  // 最終時刻決定
  double noSeconds = finishedTime;
  
  // ゲームタイマーが動いていたら止める
  [self destoryGameTimer];
  
  // リプレイ時は同期処理を行う
  if(gameReplay == 1) {
    switch(rankingPage) {
      case 0: {
        //        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", privateRankingScore[replayTag]];
        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", [rankingData privateScoreAt:replayTag]];
      }
        break;
      case 1: {
        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", [rankingData totalTimeAt:replayTag]];
//        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", rankingTotalTime[replayTag]];
      }
        break;
      case 2: {
        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", [rankingData dailyTimeAt:replayTag]];
//        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f", rankingDailyTime[replayTag]];
      }
        break;
      default: {
      }
        break;
    }
    LOG(@"label : %@ : %d",lblTimeCounter.text ,replayTag);
  }
  
  // 通常モード
  int tmpSEPN = 0;
  
  if(ALPHABET_FLAG) {
    tmpSEPN = (colorNum != 1) * 2;
  }
  LOG(@"SEPN:%d", tmpSEPN);
  LOG(@"SingleMode");
  
  if(gameReplay == 0) {
    playerScore = noSeconds;
    
    LOG(@"score");
    
    if(playerScore < [rankingData privateScoreAt:RANKING_PRIVATE_MAX - 1]) {
      //      if(playerScore < privateRankingScore[RANKING_PRIVATE_MAX - 1]) {
      
      
      NSLog(@"***** privateRankingの更新作業");
      
      rankNow = [rankingData privateRankWithInsertName:playerName time:playerScore replay:replay stage:stage];
      
      NSLog(@"rankNow:%d",rankNow);
      
      //      [self insertPrivateRanking];
      //      [self sortPrivateRanking];
      
      
      SoundEngine_StartEffect( _seFinished[1 + tmpSEPN]);  //効果音
    }
    else {
      SoundEngine_StartEffect( _seFinished[0 + tmpSEPN]);  //効果音
    }
  } else {
    SoundEngine_StartEffect( _seFinished[0 + tmpSEPN]);  //効果音
  }
  
  //ランキング画面の表示
  //リプレイ時にはネットランキング更新はなしです
  if(gameReplay == 0) {
    flagDataIsUploaded = NO;
    [btnEdit setAlpha:0.0f]; // リプレイ終了後エディットボタンは消す
  }
  
  [self hideEditBtn];
  [self showWorldRankingAlert];
  
  
  if(gameReplay == 0) {
    // 通常モード
    [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.7f];
    [rankingData savePrivateRanking];
    
    [self loadStats];  // ゲーム情報入力(ファイル)
    [self saveStats];  // ゲーム情報出力(ファイル/ここでインクリメントしている)
    [self postGameCenterPlayCountDaily:dailyPlay];
    [btnEdit setAlpha:0.8f]; // エディットボタンの表示
  }
  
  gameReplay    = 0;
  infoLabel.font  = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
  [infoLabel setAlpha:0.0f];
  
  
  [[AdManager sharedManager] showMovieInterstitial];
}


//------------------------------------------------------------------------------
//  チャレンジモードのクリア処理
//------------------------------------------------------------------------------
-(void)challengeFinished {
  
  // バックグラウンドのフラグを初期化
  flagRestart = NO;
  
  // 最終時刻決定
  double noSeconds = finishedTime;
  
  // ゲームタイマーが動いていたら止める
  [self destoryGameTimer];
  
  SoundEngine_StartEffect( _seFinished[1]);  //効果音
  
  [self checkGettingAchievement:noSeconds];
  [self saveMyLevel];
  [self initChallengeFinish];
  [self showChallengeFinishView];
}


//==============================================================================
#pragma mark -

//------------------------------------------------------------------------------
//  ボタンに画像と数字をセット
//------------------------------------------------------------------------------

-(void) setButton:(UIButton*)sender num:(int)btn {
  LOG();
  
  sender.opaque = YES;
  colorNum = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"panelColor"];
  
  [sender setBackgroundImage:panelImage[colorNum].image forState:0];
  [sender setBackgroundImage:panelImage[colorNum].image forState:1];
  
  if(ALPHABET_FLAG) {
    NSString *tmpStr = [@" ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                        substringWithRange:NSMakeRange(btnNumberValue[btn], 1)];
    
    [sender setTitle:tmpStr forState:0];
    [sender setTitle:tmpStr forState:1];
    
    replaybtn[btnNumberValue[btn]-1] = btn;
    
    [sender.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24]];
    [sender setTitleShadowColor:[UIColor blueColor] forState:0];
    
    if(colorNum == 1) {
      [sender setTitleColor:[UIColor blackColor] forState:0];
    } else {
      [sender setTitleColor:[UIColor darkGrayColor] forState:0];
    }
    //チャレンジモード時の初期化
  }else if(gameChallenge == 1){
    
    //指定の番号だけ
    if(btnNumberValue[btn] >= start_panel && btnNumberValue[btn] <= end_panel){
      
      //7は色がランダムになる仕様
      if(panel_color == 7){
        int rand = arc4random() % 7;
        [sender setBackgroundImage:panelImage[rand].image forState:0];
        [sender setBackgroundImage:panelImage[rand].image forState:1];
      }else{
        [sender setBackgroundImage:panelImage[panel_color].image forState:0];
        [sender setBackgroundImage:panelImage[panel_color].image forState:1];
      }
    }else{
      [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:0];
      [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:1];
    }
    
    [sender setTitle:[NSString stringWithFormat:@"%d",btnNumberValue[btn]] forState:0];
    [sender setTitle:[NSString stringWithFormat:@"%d",btnNumberValue[btn]] forState:1];
    
    replaybtn[btnNumberValue[btn]-1] = btn;
    
    [sender.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:24]];
    [sender setTitleColor:[UIColor blackColor] forState:0];
    [sender setTitleShadowColor:[UIColor blueColor] forState:0];
    
    //それ以外のプレイ時の初期化
  }else{
    [sender setTitle:[NSString stringWithFormat:@"%d",btnNumberValue[btn]] forState:0];
    [sender setTitle:[NSString stringWithFormat:@"%d",btnNumberValue[btn]] forState:1];
    
    replaybtn[btnNumberValue[btn]-1] = btn;
    
    [sender.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:24]];
    [sender setTitleColor:[UIColor blackColor] forState:0];
    [sender setTitleShadowColor:[UIColor blueColor] forState:0];
    
  }
}


//------------------------------------------------------------------------------
// カウンターを更新
// リプレイ処理もする
//------------------------------------------------------------------------------

-(void)updateCounter{
  //LOG();  // ログおおすぎ
  
  double noSeconds = (double)[self.startDate timeIntervalSinceNow] * -1;
  
  if(!FREE_FLAG) {  // Pro版のみ
    // リプレイモードではない かつ バトルモードではない かつ 練習モード有効時
    if(gameReplay == 0 && battleState == kStateNameEntry && [settingsViewController getStatusTraningMode] != FALSE) {
      if(noSeconds > (double)[settingsViewController getSecondTraningMode]) {
        [self destoryGameTimer];    // タイマーを止める
        [self touchStartGame];      // カウントダウンから再開
        return;
      }
    }
  }
  
  lblTimeCounter.textColor = [UIColor whiteColor];
  
  //チャレンジモード時の処理
  if(gameChallenge == 1){
    //タイム表示
    lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f/%3.3f",noSeconds,limit_time];
    
    if(noSeconds >= limit_time*0.8f){
      lblTimeCounter.textColor = [UIColor redColor];
    }
    
    //タイムオーバー
    if(noSeconds >= limit_time ){
      lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f/%3.3f",limit_time,limit_time];
      [self challengeTimeOver];
    }
    
  }else{
    
    // リプレイ時の同期処理の都合
    lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f",noSeconds];
    
    // タイムオーバー処理も挟む
    if(noSeconds > SEC_TIME_OVER ){
      [self timeOver];
    }
  }
  
  // 以下リプレイ処理。ボタン押しを再現
  // ランキングからのリプレイとバトル後リプレイの二通りがある
  if(gameReplay == 1 || battleState == kStateMultiplayerReplay) {
    UIButton  *button  = btnNumber0;
    int      num    = replaybtn[replayNumber];
    
    switch(num) {
      case 0: button = btnNumber0; break;
      case 1: button = btnNumber1; break;
      case 2: button = btnNumber2; break;
      case 3: button = btnNumber3; break;
      case 4: button = btnNumber4; break;
      case 5: button = btnNumber5; break;
      case 6: button = btnNumber6; break;
      case 7: button = btnNumber7; break;
      case 8: button = btnNumber8; break;
      case 9: button = btnNumber9; break;
      case 10: button = btnNumber10; break;
      case 11: button = btnNumber11; break;
      case 12: button = btnNumber12; break;
      case 13: button = btnNumber13; break;
      case 14: button = btnNumber14; break;
      case 15: button = btnNumber15; break;
      case 16: button = btnNumber16; break;
      case 17: button = btnNumber17; break;
      case 18: button = btnNumber18; break;
      case 19: button = btnNumber19; break;
      case 20: button = btnNumber20; break;
      case 21: button = btnNumber21; break;
      case 22: button = btnNumber22; break;
      case 23: button = btnNumber23; break;
      case 24: button = btnNumber24; break;
    }
    
    if(replayNumber < PANEL_MAX && replay[replayNumber] <= noSeconds) {
      [self numberTouched:button num:replaybtn[replayNumber]];
      replayNumber ++;
    }
  }
}


//------------------------------------------------------------------------------
//  次の数字を更新
//------------------------------------------------------------------------------
-(void)updateLblNext {
  LOG();
  
  if(ALPHABET_FLAG) {
    [lblNextNumber setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36]];
    
    if(nextNumber++ > 25){
      lblEnemyNextNumber.alpha  = 0.0f;
      lblNextNumber.text      = @"Finished";
    } else {
      NSString *tmpStr  = [@" ABCDEFGHIJKLMNOPQRSTUVWXYZ" substringWithRange:NSMakeRange(nextNumber, 1)];
      lblNextNumber.text  = [NSString stringWithFormat:@"%@",tmpStr];
    }
  } else {
    if(nextNumber++ >= PANEL_MAX) {
      lblEnemyNextNumber.alpha  = 0.0f;
      lblNextNumber.text      = @"Finished";
    } else {
      lblNextNumber.text = [NSString stringWithFormat:@"%2d",nextNumber];
    }
  }
}


//------------------------------------------------------------------------------
//  各ボタンの処理 リプレイ中は反応しない
//------------------------------------------------------------------------------

- (IBAction)tapBtn0 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber0 num:0];  }
- (IBAction)tapBtn1 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber1 num:1];  }
- (IBAction)tapBtn2 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber2 num:2];  }
- (IBAction)tapBtn3 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber3 num:3];  }
- (IBAction)tapBtn4 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber4 num:4];  }
- (IBAction)tapBtn5 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber5 num:5];  }
- (IBAction)tapBtn6 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber6 num:6];  }
- (IBAction)tapBtn7 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber7 num:7];  }
- (IBAction)tapBtn8 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber8 num:8];  }
- (IBAction)tapBtn9 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber9 num:9];  }
- (IBAction)tapBtn10 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber10 num:10];  }
- (IBAction)tapBtn11 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber11 num:11];  }
- (IBAction)tapBtn12 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber12 num:12];  }
- (IBAction)tapBtn13 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber13 num:13];  }
- (IBAction)tapBtn14 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber14 num:14];  }
- (IBAction)tapBtn15 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber15 num:15];  }
- (IBAction)tapBtn16 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber16 num:16];  }
- (IBAction)tapBtn17 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber17 num:17];  }
- (IBAction)tapBtn18 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber18 num:18];  }
- (IBAction)tapBtn19 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber19 num:19];  }
- (IBAction)tapBtn20 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber20 num:20];  }
- (IBAction)tapBtn21 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber21 num:21];  }
- (IBAction)tapBtn22 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber22 num:22];  }
- (IBAction)tapBtn23 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber23 num:23];  }
- (IBAction)tapBtn24 {  if(battleState != kStateMultiplayerReplay && gameReplay != 1) [self numberTouched:btnNumber24 num:24];  }


//------------------------------------------------------------------------------
// 数字がタッチされたときの処理
//------------------------------------------------------------------------------
-(void)numberTouched:(UIButton*)sender num:(int)btn{
  LOG(@"%s %d : %ld : %d : %d", __FUNCTION__, nextNumber, (long)sender.tag, btn, btnNumberValue[btn]);
  
  if(nextNumber == btnNumberValue[btn]){
    double noSeconds = (double)[self.startDate timeIntervalSinceNow] * -1;
    //    LOG(@"numberTouced(S):%f", noSeconds);
    if(gameReplay != 1 && battleState != kStateMultiplayerReplay && gameChallenge!= 1) {
      // Free版またはバトルモード中またはトレーニングモードではない(Pro版)
      if(FREE_FLAG || battleState != kStateMultiplayerReplay || [settingsViewController getStatusTraningMode] == FALSE) {
        replay[nextNumber - 1] = noSeconds;
        //        LOG(@"%3.3f", replay[nextNumber - 1]);
      }
    }
    
    //アニメーション
    [sender setTitleColor:[UIColor whiteColor] forState:0];
    [sender setTransform:transform[0]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.2];
    [sender setTransform:transform[1]];
    [sender setTitleColor:[UIColor blackColor] forState:0];
    [UIView commitAnimations];
    
    sender.opaque = NO;
    
    if(ALPHABET_FLAG) {
      if(colorNum == 1) {
        [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:0];
        [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:1];
      } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"Panel_Alp2.png"] forState:0];
        [sender setBackgroundImage:[UIImage imageNamed:@"Panel_Alp2.png"] forState:1];
      }
    } else {
      [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:0];
      [sender setBackgroundImage:[UIImage imageNamed:@"Panel2.png"] forState:1];
    }
    
    [self updateLblNext];
    
    
    //クリア判定
    if(ALPHABET_FLAG) {
      //      LOG(@"%d",nextNumber);
      if(nextNumber==26){
        
        int rnd = rand() % PANEL_MAX;
        UIButton *tmpBtn;
        
        //        LOG(@"**** ****  btn:%d -- rnd:%d",btn,rnd);
        while (btn==rnd) {
          //          LOG(@"****  btn:%d == rnd:%d",btn,rnd);
          rnd = rand() % PANEL_MAX;
        }
        
        switch(rnd) {
          case  0:  tmpBtn = btnNumber0;  break;
          case  1:  tmpBtn = btnNumber1;  break;
          case  2:  tmpBtn = btnNumber2;  break;
          case  3:  tmpBtn = btnNumber3;  break;
          case  4:  tmpBtn = btnNumber4;  break;
          case  5:  tmpBtn = btnNumber5;  break;
          case  6:  tmpBtn = btnNumber6;  break;
          case  7:  tmpBtn = btnNumber7;  break;
          case  8:  tmpBtn = btnNumber8;  break;
          case  9:  tmpBtn = btnNumber9;  break;
          case  10:  tmpBtn = btnNumber10;  break;
          case  11:  tmpBtn = btnNumber11;  break;
          case  12:  tmpBtn = btnNumber12;  break;
          case  13:  tmpBtn = btnNumber13;  break;
          case  14:  tmpBtn = btnNumber14;  break;
          case  15:  tmpBtn = btnNumber15;  break;
          case  16:  tmpBtn = btnNumber16;  break;
          case  17:  tmpBtn = btnNumber17;  break;
          case  18:  tmpBtn = btnNumber18;  break;
          case  19:  tmpBtn = btnNumber19;  break;
          case  20:  tmpBtn = btnNumber20;  break;
          case  21:  tmpBtn = btnNumber21;  break;
          case  22:  tmpBtn = btnNumber22;  break;
          case  23:  tmpBtn = btnNumber23;  break;
          case  24:  tmpBtn = btnNumber24;  break;
          default:  tmpBtn = btnNumber12;  break;
            break;
        }
        btnNumberValue[rnd]=26;
        [tmpBtn setTitle:@"Z" forState:0];
        [tmpBtn setTitle:@"Z" forState:1];
        [tmpBtn setBackgroundImage:panelImage[colorNum].image forState:0];
        [tmpBtn setBackgroundImage:panelImage[colorNum].image forState:1];
        
      }
      
      if(nextNumber==27) {
        finishedTime = noSeconds;
        //        LOG(@"numberTouced(E):%f", finishedTime);
        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f",finishedTime];
        [self destoryGameTimer];  // ここでタイマーを止める
        [self performSelector:@selector(finished) withObject:nil afterDelay:0.05f];
      } else {
        if(ALPHABET_FLAG) {
          if(colorNum==1) {
            SoundEngine_StopEffect(_se[nextNumber%2], YES);
            SoundEngine_StartEffect(_se[nextNumber%2]);
          } else {
            SoundEngine_StopEffect(_se[nextNumber%2+2], YES);
            SoundEngine_StartEffect(_se[nextNumber%2+2]);
          }
        } else {
          SoundEngine_StopEffect(_se[nextNumber%2], YES);
          SoundEngine_StartEffect(_se[nextNumber%2]);
        }
        
      }
    } else {
      // TtN
      
      //チャレンジモードのクリア判定
      if(gameChallenge == 1 && nextNumber == end_panel+1){
        newBarButtonItem.enabled = NO;  // numberTouched(ゲーム終了)
        finishedTime = noSeconds;
        lblTimeCounter.text = [NSString stringWithFormat:@"%3.3f/%3.3f",finishedTime,limit_time];
        lblNextNumber.text      = @"Finished";
        [self destoryGameTimer];  // ここでタイマーを止める
        [self performSelector:@selector(challengeFinished) withObject:nil afterDelay:0.05f];
        
        //通常モードのクリア判定
      }else if(nextNumber == 26) {
        newBarButtonItem.enabled = NO;  // numberTouched(ゲーム終了)
        
        finishedTime = noSeconds;
        //        LOG(@"numberTouced(E):%f", finishedTime);
        
        lblTimeCounter.text  = [NSString stringWithFormat:@"%3.3f",finishedTime];
        [self destoryGameTimer];  // ここでタイマーを止める
        [self performSelector:@selector(finished) withObject:nil afterDelay:0.05f];
        
        
        //クリアしてない場合
      }else {
        if(ALPHABET_FLAG) {
          if(colorNum==1) {
            SoundEngine_StopEffect(_se[nextNumber%2], YES);
            SoundEngine_StartEffect(_se[nextNumber%2]);
          } else {
            SoundEngine_StopEffect(_se[nextNumber%2+2], YES);
            SoundEngine_StartEffect(_se[nextNumber%2+2]);
          }
        } else {
          SoundEngine_StopEffect(_se[nextNumber%2], YES);
          SoundEngine_StartEffect(_se[nextNumber%2]);
        }
      }
    }
  } else {
    SoundEngine_StopEffect(_seBuzzer, YES);
    SoundEngine_StartEffect( _seBuzzer);
  }
  
}


//==============================================================================
#pragma mark - ReplayControllerDelegate

//------------------------------------------------------------------------------
- (void)finishDownloadingReplayFile:(NSMutableArray *)array {
  LOG();
  
  int count = (int)[array count];
  //LOG(@"count:%d", count);
  
  if(count > 0) {
    gameReplay    = 1;
    replayNumber  = 0;
    
    // スコア
    playerScore  = [[array objectAtIndex:1] doubleValue];
    
    // リプレイデータ
    for(int i = 2; i < 27; i ++) {
      replay[i - 2] = [[array objectAtIndex:i] doubleValue];
      //LOG(@"///// %d:%f", i - 2, replay[i - 2]);
    }
    
    // パネル情報
    srand([[array lastObject] intValue]);
    LOG(@"stage : %d", [[array lastObject] intValue]);
    
    // リプレイ状態で実行
    [self startGame];
    
  } else {
    [self hideAllSimpleAlert];  // 表示してたら消す
    [self createSimpleAlertErrorDownloadReplay];
  }
}


//==============================================================================
#pragma mark -

//------------------------------------------------------------------------------
//  あまりに時間がかかりすぎたときの処理
//------------------------------------------------------------------------------
- (void)timeOver {
  LOG();
  
  [self destoryGameTimer];  // タイマーを止める
  
  if(gameReplay != 1) {
    [self hideAllSimpleAlert];  // 表示してたら消す
    [self createSimpleAlertTimeOver];
  }
}

//------------------------------------------------------------------------------
//  チャレンジモードのゲーム終了
//------------------------------------------------------------------------------
- (void)challengeTimeOver {
  LOG();
  
  [self destoryGameTimer];  // タイマーを止める
  
  if(gameReplay != 1) {
    [self hideAllSimpleAlert];  // 表示してたら消す
    [self initChallengeFailed];
    [self showChallengeFailedView];
  }
}



//------------------------------------------------------------------------------
//  ローカルの統計データを読み出す(もしくは統計を初期化)
//------------------------------------------------------------------------------
- (void)loadStats {
  LOG();
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filepathForTotalData = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"totaldata.dat"];
  NSArray *tmpArrayForTotalData = [[NSArray alloc] initWithContentsOfFile:filepathForTotalData];
  
  
  if([tmpArrayForTotalData objectAtIndex:0]==NULL){ // 統計データなければ作るde
    LOG(@"Stats data not found.");
    totalPlay  = 0;
    sinceDate  = [NSDate date];
    dailyPlay  = 0;
    latestDate  = [NSDate date];
  } else {
    LOG(@"Stats data exists!");
    
    totalPlay  = [[tmpArrayForTotalData objectAtIndex:0] intValue];
    sinceDate  = [[tmpArrayForTotalData objectAtIndex:1] copy];
    dailyPlay  = [[tmpArrayForTotalData objectAtIndex:2] intValue];
    latestDate  = [[tmpArrayForTotalData objectAtIndex:3] copy];
    
    int day    = [latestDate timeIntervalSinceReferenceDate] / (60 * 60 * 24); // 最終プレイ日を求める
    int nowDay  = [[NSDate date] timeIntervalSinceReferenceDate] / (60 * 60 * 24); // プレイ日を求める
    LOG(@"{{%d %d}}", day, nowDay);
    
    if(nowDay > day) { // 最終プレイから一日以上たったぽい
      latestDate  = [NSDate date];
      dailyPlay  = 0;
    } else {
      //　特に何もしない
    }
  }
  LOG(@"[%d %d]", totalPlay, dailyPlay);
  
}


//------------------------------------------------------------------------------
//  ローカルの統計データを保存
//------------------------------------------------------------------------------
- (void)saveStats {
  LOG();
  
  totalPlay++;  // 総プレイ回数増やす
  dailyPlay++;  // その日のプレイ回数増やす
  
  //ファイルパスを指定
  NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
  NSString *filepathForTotalData=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"totaldata.dat"];
  
  NSArray *tmpArray = [
                       [NSArray alloc]
                       initWithObjects:
                       [NSNumber numberWithInt:totalPlay],
                       sinceDate,
                       [NSNumber numberWithInt:dailyPlay],
                       latestDate,
                       nil
                       ];
  
  [tmpArray writeToFile:filepathForTotalData atomically:NO];
  
}


//------------------------------------------------------------------------------
//  unsentdata.dat内のリプレイデータをチェックする
//  NOTE  : checkNowReplayData()のチェックでNOならリプレイデータは-1.0fとなる
//------------------------------------------------------------------------------
- (BOOL)checkSendReplayData:(NSMutableArray *)array_replay {
  LOG();
  
  BOOL result = YES;
  
  for(int i = 0; i < PANEL_MAX; i++) {
    if([[array_replay objectAtIndex:i] doubleValue] == -1.0f) {
      result = NO;
      break;
    }
  }
  return result;
}


////------------------------------------------------------------------------------
//- (void)postRankingOrSave {
//  LOG("##### 要確認");
//
//  LOG("未送信データ部分だけ別の場所で処理する形に");
//
//  [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4f];
//  return;
//
//
////
////  NSLog(@"flagResendData:%d",flagResendData);
////
////  if(flagInternetAccess && [NetworkAvailable state]) {
////    LOG(@"flagInternetAccess ON && networkAvailable");
////    LOG(@"gameReplay:%d",gameReplay);
////    LOG(@"flagResendData:%d",flagResendData);
////
////    // 未送信データの読み込み
////    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////    NSString *unsentFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"unsentdata.dat"];
////    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:unsentFilePath];
////
////    NSString *tmpPlayerName = [dictionary objectForKey:@"playerName"];
////    double tmpScore = [[dictionary objectForKey:@"playerScore"] doubleValue];
////    //    NSMutableArray *tmpData = [dictionary objectForKey:@"replayData"];
////
////    if(tmpPlayerName) {
////      BOOL isSuccess = NO;
////      indicatorView.center = CGPointMake(screenCenter.x, screenCenter.y);
////
////      if(!gameReplay) {
////
////        // スコアしかおくらない
////        if(!flagResendData){
////          // 通常用
////          LOG(@"***** Send only Score !");
////          isSuccess = [replayController sendScore:tmpScore username:tmpPlayerName flagResendData:flagResendData];
////          [self postGameCenterPlayScoreTotal:(float)tmpScore];  // ゲームセンターに送信
////        } else {
////          // Repost用
////          LOG(@"***** Repost only Score !");
////          isSuccess = [replayController sendScore:tmpScore username:tmpPlayerName flagResendData:flagResendData];
////          flagResendData = NO;
////        }
////
////
////        if(isSuccess) {
////          LOG(@"success to post ranking data!");
////          flagInternetConnection = YES;
////
////          // sendが成功したらunsentdataを消す
////          [dictionary removeAllObjects];
////          [dictionary writeToFile:unsentFilePath atomically:NO];
////
////        } else {
////          LOG(@"Connection Failed");
////          flagInternetConnection = NO;
////        }
////      }
////      [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4f];
////    }
////  }
//}

//==============================================================================
#pragma mark -

//------------------------------------------------------------------------------
//  テクノードWEBサイトへ。
//------------------------------------------------------------------------------

-(IBAction)showURL:(id) sender{
  LOG();
  
  [self hideAllSimpleAlert];  // 表示してたら消す
  [self createSimpleAlertJumpToTekunodo];
}


//==============================================================================
#pragma mark - Battle mode

//------------------------------------------------------------------------------
//  Battle Mode 処理（通信処理)
//------------------------------------------------------------------------------





//==============================================================================
#pragma mark - Picker

//------------------------------------------------------------------------------
//  バトルモード中の対戦相手選択ピッカー表示
//------------------------------------------------------------------------------


- (NSString *) platform{
  int mib[2];
  size_t len;
  char *machine;
  
  mib[0] = CTL_HW;
  mib[1] = HW_MACHINE;
  sysctl(mib, 2, NULL, &len, NULL, 0);
  machine = malloc(len);
  sysctl(mib, 2, machine, &len, NULL, 0);
  
  NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
  free(machine);
  return platform;
}



//==============================================================================
#pragma mark - Network







//==============================================================================
#pragma mark - Ranking

//------------------------------------------------------------------------------
//  ランキングボタンをタッチ
//------------------------------------------------------------------------------
-(IBAction)touchWebRanking {
  LOG();
  SoundEngine_StartEffect( _seCount[3]);  //効果音
  [self showEditBtn]; // ランキング編集ボタンを表示
  [self performSelector:@selector(showWorldRankingAlert) withObject:nil afterDelay:0.01];
}


//------------------------------------------------------------------------------
//  世界ランキングを表示
//------------------------------------------------------------------------------
-(void)showWorldRankingAlert{
  LOG(@"%s gameState:%d, gameReplay:%d", __FUNCTION__, gameState,gameReplay);
  
  // analytics
  //  [tracker trackView:@"/ranking"];
  
  if(FREE_FLAG) {
  } else {
    [lblStats2 setText:[NSString stringWithFormat:@"Play count Total : %5d\n            Today : %5d", totalPlay, dailyPlay]];
    [lblStats2 setLineBreakMode:NSLineBreakByWordWrapping];  //改行モード
    [lblStats2 setNumberOfLines:0];
  }
  [rankingAlView setTransform:transform[2]];
  [self addSubview:rankingAlViewOwner];
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.32];
  [rankingAlView setTransform:transform[1]];
  [UIView commitAnimations];
  
  //名前入力ビューを削除
  [nameEntryView removeFromSuperview];
  
  //ランキング用スクロールビューの用意。
  [rankView removeFromSuperview];
  
  if(!rankView){
    rankView = [[UIScrollView alloc] initWithFrame:CGRectMake(32.0f, 108.0f, 256.0f, 250.0f)];
    rankView.showsVerticalScrollIndicator  = YES;
    rankView.showsHorizontalScrollIndicator  = YES;
    rankView.scrollsToTop          = YES;
    rankView.pagingEnabled          = NO;
  }
  
  // ランキングデータの表示
  for(int i = 0; i < RANKING_LINE_MAX; i++) {
    if(!rankingLineView[i]){
      rankingLineView[i] = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (float)(0 + 25 * i), 256.0f, 25.0f)];
      
      rankingRankLabel[i] = [[UILabel alloc] initWithFrame:RankLabelRect];
      rankingRankLabel[i].textAlignment  = NSTextAlignmentRight;
      rankingRankLabel[i].textColor    = [UIColor whiteColor];
      rankingRankLabel[i].backgroundColor  = [UIColor clearColor];
      [rankingLineView[i] addSubview:rankingRankLabel[i]];
      
      rankingTimeLabel[i] = [[UILabel alloc] initWithFrame:TimeLabelRect];
      rankingTimeLabel[i].textAlignment  = NSTextAlignmentRight;
      rankingTimeLabel[i].textColor    = [UIColor whiteColor];
      rankingTimeLabel[i].backgroundColor  = [UIColor clearColor];
      [rankingLineView[i] addSubview:rankingTimeLabel[i]];
      
      rankingNameLabel[i]          = [[UILabel alloc] initWithFrame:NameLabelRect];
      rankingNameLabel[i].textAlignment  = NSTextAlignmentLeft;
      rankingNameLabel[i].textColor    = [UIColor whiteColor];
      rankingNameLabel[i].backgroundColor  = [UIColor clearColor];
      [rankingLineView[i] addSubview:rankingNameLabel[i]];
      
      btnReplay[i]    = [UIButton buttonWithType:UIButtonTypeCustom];
      btnReplay[i].alpha  = 0.0f;
      btnReplay[i].tag  = i;
      [btnReplay[i] setImage:[UIImage imageNamed:@"ttnTriangle.png"] forState:UIControlStateNormal];
      [btnReplay[i] setFrame:ReplayBtnRect];
      [btnReplay[i] addTarget:self action:@selector(respondToButtonClick:) forControlEvents:UIControlEventTouchUpInside];
      [btnReplay[i] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
      [rankingLineView[i] addSubview:btnReplay[i]];
      
      [rankView addSubview:rankingLineView[i]];
      //Delete Btn を追加
      btnDeleteKey[i]    = [UIButton buttonWithType:UIButtonTypeCustom];
      btnDeleteKey[i].alpha  = 0.0f;
      btnDeleteKey[i].tag  = i;
      [btnDeleteKey[i] setFrame:DeleteBtnRect];
      [btnDeleteKey[i] setImage:[UIImage imageNamed:@"delete_button.png"] forState:UIControlStateNormal];
      [btnDeleteKey[i] addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
      [btnDeleteKey[i] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
      [rankingLineView[i] addSubview:btnDeleteKey[i]];
    }
  }
  [self createCoverView];
  [self showRankView];
  
  // 統計情報表示
  [self loadStats];
  
  if(FREE_FLAG) {
  } else {
    [foot setAlpha:1.0];
  }
  
}


//------------------------------------------------------------------------------
//  ランキングの表示処理
//------------------------------------------------------------------------------
- (void)showRankView {
  LOG(@" gamestate = %d",gameState);
  
  [rankView removeFromSuperview];
  
  //ネット接続の有無でテキストの位置を初期化（エディットボタン追加のため）
  if(flagInternetAccess == NO){
    [lblRankingMessage setCenter:CGPointMake(160.0f, 86.0f)];
    // ボタンの処理
    [btnRankPrivate setEnabled:FALSE];
    [btnRankTotal setEnabled:FALSE];
    [btnRankWeekly setEnabled:FALSE];
  }else{
    [lblRankingMessage setCenter:CGPointMake(160.0f, 39.0f)];
  }
  
  //----------------------------------------------------
  
  if(gameState==0){
    [lblRankingMessage setText:[NSString stringWithFormat:@"Ranking"]];
  } else {
    //ネット接続の有無でテキストの位置を変更（エディットボタン追加のため）
    if(flagInternetAccess == NO){
      [lblRankingMessage setCenter:CGPointMake(180.0f, 86.0f)];
    }else{
      [lblRankingMessage setCenter:CGPointMake(180.0f, 39.0f)];
    }
    
    if(gameReplay == 0) {
      if(playerScore < [rankingData privateScoreAt:RANKING_PRIVATE_MAX - 1]){ // ハイスコアが出た！
        //        if(playerScore < privateRankingScore[RANKING_PRIVATE_MAX - 1]){ // ハイスコアが出た！
        [lblRankingMessage setText:[NSString stringWithFormat:@"New Record %3.3f !!", playerScore]];
      } else {
        // ふつうに終わった
        if(playerScore <= 9900.0f) {
          [lblRankingMessage setText:[NSString stringWithFormat:@"Finished at %3.3f !!", playerScore]];
        } else {
          NSLog(@"****** フラグ;%d",flagEdit);
          [lblRankingMessage setText:[NSString stringWithFormat:@"Replay is finished."]];
          
          flagEdit = YES;
          [self showEditBtn];
        }
      }
      
      
//      //--------------------------------------------------
//      // Social.frameworkでtwitter投稿 ver3.20
//      //--------------------------------------------------
//      if(flagInternetAccess == 1) { // まずネット接続許可があるかどうか
//        if(flagTwitterSwitch) { //投稿フラグ
//          //自己ランキング順位が1位であることを確認
//          if(rankNow == 0 && isPosted == 0) { // 一位更新！ && まだ表示してなかった
//            isPosted = 1;
//            // twitter frameworkで投稿
//            NSString     *msg  = [NSString stringWithFormat:TWITTER_MESSAGE, playerName, playerScore];
//            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:msg, @"TwitterMessage",nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"showTwitterDialog" object:self userInfo:info];
//          }
//        }
//      }
      //--------------------------------------------------
      
    } else {
      NSLog(@"****** フラグ;%d",flagEdit);
      [lblRankingMessage setText:[NSString stringWithFormat:@"Replay is finished."]];
      
      flagEdit = YES;
      [self showEditBtn];
    }
  }
  
  // ランキングデータ設定
  if(rankingPage == 0) {
    [self setPrivateRanking];
  } else if(rankingPage == 1) {
    [self setTotalRanking];
  } else if(rankingPage == 2) {
    [self setDailyRanking];
  }
  
  [rankingAlView addSubview:rankView];
  
  // カバービュー削除
  [self performSelector:@selector(destroyCoverView) withObject:nil afterDelay:0.25f];
  
  
  [[AdManager sharedManager] showBanner];

}


//------------------------------------------------------------------------------
//  RankingAlertViewのランニング表示切替ボタン
//------------------------------------------------------------------------------
-(IBAction)changeRankingPage:(UIButton*)sender{
  LOG(@"%s sender.tag=%d", __FUNCTION__, (int)sender.tag);
  
  rankingPage = (int)sender.tag;
  SoundEngine_StartEffect( _seCount[3]);  //効果音
  
  switch(rankingPage) {
    case 0:
      [btnRankPrivate setAlpha:1.0f];
      [btnRankTotal setAlpha:0.5f];
      [btnRankWeekly setAlpha:0.5f];
      
      // 編集ボタンを表示
      [self showEditBtn];
      
      replayType = kReplayType_Private;
      
      break;
      
    case 1:
      [btnRankPrivate setAlpha:0.5];
      [btnRankTotal setAlpha:1.0];
      [btnRankWeekly setAlpha:0.5];
      
      // 編集モードの処理
      [self hideEditBtn];
      
      // 編集中なら
      if(!flagEdit){
        [self stopEditing];
      }
      
      replayType = kReplayType_Total;
      
      break;
      
    case 2:
      [btnRankPrivate setAlpha:0.5];
      [btnRankTotal setAlpha:0.5];
      [btnRankWeekly setAlpha:1.0];
      
      // 編集モードの処理
      [self hideEditBtn];
      
      // 編集中なら
      if(!flagEdit){
        [self stopEditing];
      }
      
      replayType = kReplayType_Daily;
      
      break;
      
    default:
      break;
  }
  
  if(flagDataIsUploaded == NO) {
    flagDataIsUploaded = YES;
    
    if(flagInternetAccess){
      //インジケーター表示
      indicatorView.center = screenCenter;
      [self addSubview:indicatorView];
      [self performSelector:@selector(downloadDailyAndTotalRankingFromInternet) withObject:nil afterDelay:0.01f];
    }
  }
  [self createCoverView];
  [self performSelector:@selector(showRankView) withObject:nil afterDelay:0.1f];
}




- (void)downloadDailyAndTotalRankingFromInternet {
  LOG(@"*************");
  //  LOG(@"%@",[rankingData rankingDict]);
  //  LOG(@"Total:%@",[[rankingData rankingDict] objectForKey:@"Total"]);
  //  LOG(@"Daily:%@",[[rankingData rankingDict] objectForKey:@"Daily"]);
  
  if([rankingData rankingDict]!=nil){
  }else{
    
    [rankingData loadWorldRankingData];

    
    
    flagInternetConnection = NO;
    if(!connectionFailedLabel){
      connectionFailedLabel =[[UILabel alloc] initWithFrame:CGRectMake(38.0f, 224.0f, 244.0f, 32.0f)];
      [connectionFailedLabel setText:@"Connection Failed"];
      [connectionFailedLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.3f alpha:1.0f]];
      [connectionFailedLabel setTextColor:[UIColor whiteColor]];
      [connectionFailedLabel setTextAlignment:NSTextAlignmentCenter];
      [rankingAlView addSubview:connectionFailedLabel];
    }
  }
  [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4f];
  return;
  
}


//------------------------------------------------------------------------------
//  ランキングの順位の行を押下
//------------------------------------------------------------------------------
- (IBAction)respondToButtonClick:(UIButton*)sender {
  LOG(@"sender.tag:%ld", (long)sender.tag);
  
  double    score;
  NSString  *name;
  
  switch(replayType) {
    case kReplayType_Private: {
      score  = [rankingData privateScoreAt:(int)sender.tag];
      name  = [rankingData privateNameAt:(int)sender.tag];
      //　エディットボタンを表示
      flagEdit = YES;
    }
      break;
      
    case kReplayType_Total: {
      score  = [rankingData totalTimeAt:(int)sender.tag];
      name  = [rankingData totalNameAt:(int)sender.tag];
    }
      break;
      
    case kReplayType_Daily: {
      score  = [rankingData dailyTimeAt:(int)sender.tag];
      name  = [rankingData dailyNameAt:(int)sender.tag];
    }
      break;
      
    default: {
      // ありえない
    }
      break;
  }
  
  // show Graph alert
  //--------------------------------------------------
  // アラート表示
  //--------------------------------------------------
  NSString *str, *str2;
  
  // Private
  if(replayType == kReplayType_Private) {
    
    str = [NSString stringWithFormat:NSLocalizedString(@"ReplayDataMsg", nil), sender.tag + 1, score, name];
    str2 = [NSString stringWithFormat:NSLocalizedString(@"ReplayDataMsg2", nil), sender.tag + 1, score, name];
    
  }
  else {
    str = [NSString stringWithFormat:NSLocalizedString(@"DownloadAndReplayDataMsg", nil), sender.tag + 1, score, name];
  }
  
  NSString *record = [NSString stringWithFormat:@"%2d :  %3.3f   %@",sender.tag + 1, score, name];
  
  // Rankingを送る
  replayTag = (int)sender.tag;
  
  [self hideAllSimpleAlert];  // 表示してたら消す
  
  // グラフアラートを表示させる細かい処理
  [self changeAlertType:(int)sender.tag mes:str mes2:str2 record:record];
  
}

// グラフアラートを表示させる各リプレイタイプでの処理
- (void)changeAlertType:(int)tag mes:(NSString*)mes mes2:(NSString*)mes2 record:(NSString*)record{
  
  // グラフ描画用にセット
  replayDataTmpArr = [NSMutableArray array];
  NSString *title, *message;
  BOOL flagShowGraph = NO;
  
  // アラート設定
  switch (replayType) {
      
    case kReplayType_Private:
      //--------------------------------------------------
      // Private
      //--------------------------------------------------
      replayDataTmpArr = [self replayDataArray:tag];
      
      // Ranking 1st
      if(tag == 0){
        if(flagInternetAccess && [NetworkAvailable state]){
          
          // ネット接続している時のみ スコア送信可能
          title   = @"Replay / Repost";
          message = mes2;
          
        } else {
          // オフライン
          title   = @"Replay";
          message = mes;
        }
        
        [self showAlertView:title message:message transform:YES];
        LOG(@"***** mes:%@",message);
      }
      
      if(tag > 0){
        // プライベート2位以下
        [self showAlertView:@"Replay" message:mes transform:NO];
        
      }
      break;
      
    case kReplayType_Total:
      
      //--------------------------------------------------
      // Total 通常アラート
      //--------------------------------------------------
      // リプレイデータを取得
      replayDataTmpArr = [replayController replayGraphDataArray:[rankingData totalNameAt:replayTag]
                                                           time:[rankingData totalTimeAt:replayTag]
                                                           type:kDownloadType_Total
                                                            tag:replayTag];
      
      // 不要なデータは削除
      [replayDataTmpArr removeObjectAtIndex:0];
      [replayDataTmpArr removeLastObject];
      
      // 再生したデータと照合できれば
      for (int i = 0; i < [totalShowedNumArr count]; i++) {
        if (tag == [[totalShowedNumArr objectAtIndex:i]intValue]) {
          flagShowGraph = YES;
        }
      }
      
      // 不正データかチェック
      resultFalseData = [self checkFalseData:replayDataTmpArr];
      
      
      if (!flagShowGraph || replayDataTmpArr == nil || resultFalseData == FALSE) {
        // 通常アラート
        [self createSimpleAlertConfirmReplay:mes];
        
      } else {
        [self showAlertView:@"Replay"
                    message:[NSString stringWithFormat:NSLocalizedString(@"DownloadAndReplayDataMsg2", nil),record]
                  transform:NO
         ];
      }
      
      break;
      
    case kReplayType_Daily:
      //--------------------------------------------------
      // Daily 通常アラート
      //--------------------------------------------------
      
      // リプレイを表示したか確認
      for (int i = 0; i < [dailyShowedNumArr count]; i++) {
        if (tag == [[dailyShowedNumArr objectAtIndex:i]intValue]) {
          flagShowGraph = YES;
        }
      }
      
      // リプレイデータを取得
      replayDataTmpArr = [replayController replayGraphDataArray:[rankingData dailyNameAt:replayTag]
                                                           time:[rankingData dailyTimeAt:replayTag]
                                                           type:kDownloadType_Daily
                                                            tag:replayTag];
      
      // 不要なデータは削除
      [replayDataTmpArr removeObjectAtIndex:0];
      [replayDataTmpArr removeLastObject];
      
      
      
      // 不正データかチェック
      resultFalseData = [self checkFalseData:replayDataTmpArr];
      
      
      if (!flagShowGraph || replayDataTmpArr == nil || resultFalseData == FALSE) {
        // 通常アラート
        [self createSimpleAlertConfirmReplay:mes];
        
      } else {
        [self showAlertView:@"Replay"
                    message:[NSString stringWithFormat:NSLocalizedString(@"DownloadAndReplayDataMsg2", nil),record]
                  transform:NO];
        
      }
      
      break;
      
    default:
      break;
  }
  
}

//------------------------------------------------------------------------------


- (void)showAlertView:title message:(NSString*)message transform:(BOOL)transform_{
  LOG();
  // 初期化して再描画出来るようにする
  graphView = [[GraphView alloc]initWithFrame:CGRectMake(0, 0, 280, 200)];
  graphView.center = CGPointMake(160, self.center.y -90 );
  graphView.backgroundColor = RGBA(0.0, 7.0, 99.0, 1.0);
  [alertView addSubview:graphView];
  [alertView setAlpha:1.0f];
  
  if(screenSize.height == 480.0){
    if(!FREE_FLAG){
      graphView.center = CGPointMake(160, self.center.y -50 );
    } else {
      graphView.center = CGPointMake(160, self.center.y - 50 );
      alertView.center = CGPointMake(160, self.center.y - 30 );
    }
  }
  
  // data set
  [[NSUserDefaults standardUserDefaults]setObject:replayDataTmpArr forKey:@"drawData"];
  [[NSUserDefaults standardUserDefaults]setObject:[self replayDataArray:0] forKey:@"drawData1st"];
  
  [finishiTitle setText:title];
  [finishiMes setText:message];
  LOG(@"///// setText:message:%@",message);
  
  if(transform_){
    // Repost用レイアウト調整
    if(screenSize.height == 568.0){
      // 4inch
      alertBG.transform = CGAffineTransformMakeScale(1.0, 1.15);
      finishiTitle.transform = CGAffineTransformMakeTranslation(0, -25);
      graphView.transform = CGAffineTransformMakeTranslation(0, -15);
      finishiMes.transform  = CGAffineTransformMakeTranslation(0, -10);
      
      alertBtn_Replay.transform = CGAffineTransformMakeTranslation(0, -10);
      alertBtn_Repost.transform  = CGAffineTransformMakeTranslation(0, -10);
      alertBtn_Cancel.transform  = CGAffineTransformMakeTranslation(0, 33);
    } else {
      // 3.5inch
      alertBG.transform = CGAffineTransformMakeScale(1.0, 1.05);
      finishiTitle.transform = CGAffineTransformMakeTranslation(0, -18);
      graphView.transform = CGAffineTransformMakeTranslation(0, -20);
      finishiMes.transform  = CGAffineTransformMakeTranslation(0, -20);
      
      alertBtn_Replay.transform  = CGAffineTransformMakeTranslation(0, -25);
      alertBtn_Repost.transform  = CGAffineTransformMakeTranslation(0, -25);
      alertBtn_Cancel.transform  = CGAffineTransformMakeTranslation(0, 15);
      
    }
    
    
    // RepostBtnは表示しない
    alertBtn_Repost.hidden = NO;
  } else {
    // Repostしないとき
    alertBG.transform      = CGAffineTransformMakeScale(1.0, 1.0);
    finishiTitle.transform = CGAffineTransformMakeTranslation(0, 0);
    graphView.transform    = CGAffineTransformMakeTranslation(0, 0);
    finishiMes.transform   = CGAffineTransformMakeTranslation(0, 0);
    
    alertBtn_Replay.transform  = CGAffineTransformMakeTranslation(0, 0);
    alertBtn_Repost.transform  = CGAffineTransformMakeTranslation(0, 0);
    alertBtn_Cancel.transform  = CGAffineTransformMakeTranslation(0, 0);
    
    // RepostBtnを表示
    alertBtn_Repost.hidden = YES;
  }
  
  alertView.transform = CGAffineTransformMakeScale(0.4, 0.4);
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2f];
  alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
  [UIView commitAnimations];
  
  //alertView.center = self.center;
  [rankingAlViewOwner addSubview:alertView];
  
}

//------------------------------------------------------------------------------
// グラフアラートのアクション
-(void)tappedAlertBtn:(UIButton*)button {
  LOG(@"");
  
  switch (button.tag) {
    case 0:
      // リプレイ
      [self handlerSimpleAlertConfirmReplay:[NSNumber numberWithInt:0]];
      [alertView setAlpha:0.0f];
      break;
      
    case 1:
      // 再送信
      [self handlerSimpleAlertConfirmReplay_Post:[NSNumber numberWithInt:1]];
      [alertView setAlpha:0.0f];
      break;
      
    case 2:
      // Cancel
      alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.2f];
      alertView.transform = CGAffineTransformMakeScale(0.7, 0.7);
      [alertView setAlpha:0.0f];
      [UIView commitAnimations];
      
      break;
      
    default:
      break;
  }
  
  // graph消す
  [graphView removeFromSuperview];
}

// 不正データかどうかチェック
- (BOOL)checkFalseData:(NSMutableArray*)array {
  LOG();
  
  BOOL result = TRUE;
  
  // 0より小さい値は偽
  for(int i =0; i < [array count]; i++){
    if([[array objectAtIndex:i]floatValue] < 0){
      result = FALSE;
    }
  }
  
  if(result == FALSE) {
    LOG(@"***** バグデータです！ *****");
  }
  
  return result;
}

//------------------------------------------------------------------------------
// 一度リプレイを見たらグラフボタンにチェンジ
//------------------------------------------------------------------------------
- (void)addGraphBtn:(NSString*)replayName time:(float)time tag:(int)tag {
  LOG();
  
  if (tag == 1){
    // Total
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"TOTAL_GRAPH_BTN"]){
      //初回起動
      LOG(@"***** 初回起動");
      totalGraphBtnArr = [NSMutableArray array];
    } else {
      // 既存
      totalGraphBtnArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"TOTAL_GRAPH_BTN"]];
      
      // 同じデータは保存しない
      for(int i = 0; i < [totalGraphBtnArr count]; i++){
        
        if(time == [[totalGraphBtnArr objectAtIndex:i]floatValue]){
          [totalGraphBtnArr removeObjectAtIndex:i];
        }
      }
    }
    
    // データが正常なら
    if(replayDataTmpArr != nil && resultFalseData == TRUE) {
      // add object
      [totalGraphBtnArr addObject:[NSNumber numberWithFloat:time]];
      // save
      [[NSUserDefaults standardUserDefaults]setObject:totalGraphBtnArr forKey:@"TOTAL_GRAPH_BTN"];
      LOG(@"///// Save /////");
    }
  }
  
  if (tag == 2){
    // Daily
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"DAILY_GRAPH_BTN"]) {
      // 初回起動
      dailyGraphBtnArr = [NSMutableArray array];
      
    } else {
      // 既存
      dailyGraphBtnArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"DAILY_GRAPH_BTN"]];
      
      // Data Check
      for(int i = 0; i < [dailyGraphBtnArr count]; i++){
        if(time == [[dailyGraphBtnArr objectAtIndex:i]floatValue]){
          [dailyGraphBtnArr removeObjectAtIndex:i];
        }
      }
    }
    
    // データが正常なら
    if(replayDataTmpArr != nil && resultFalseData == TRUE) {
      // add object
      [dailyGraphBtnArr addObject:[NSNumber numberWithFloat:time]];
      // save
      [[NSUserDefaults standardUserDefaults]setObject:dailyGraphBtnArr forKey:@"DAILY_GRAPH_BTN"];
      LOG(@"///// Save /////");
    }
  }
  
  [[NSUserDefaults standardUserDefaults]synchronize];
  
}

//------------------------------------------------------------------------------
// ボタンイメージをグラフに変更
//------------------------------------------------------------------------------
-(BOOL)checkShownData:(float)time tag:(int)tag{
  
  BOOL result = FALSE;
  NSMutableArray *checkArr;
  
  // tagでcheckArrを入れ替える
  if (tag == kReplayType_Total){
    checkArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"TOTAL_GRAPH_BTN"]];
  }
  if (tag == kReplayType_Daily){
    checkArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"DAILY_GRAPH_BTN"]];
  }
  
  if([checkArr count] > 0){
    for (int i = 0; i < [checkArr count]; i++){
      // タイムが照合したら、TRUEを返す
      if(time == [[checkArr objectAtIndex:i]floatValue]){
        result = TRUE;
      }
    }
  }
  
  return result;
}


//------------------------------------------------------------------------------
// 描画用リプレイデータを取得
- (NSMutableArray *)replayDataArray:(int)tag {
  
  NSMutableArray *tmpArray = [NSMutableArray array];
  [tmpArray addObject:[NSNumber numberWithDouble:[rankingData privateScoreAt:tag] ]];
  
  for(int j = 0; j < PANEL_MAX; j ++) {
    [tmpArray addObject:[NSNumber numberWithDouble:[rankingData pPrivateReplayAt:tag] ->replay[j]]];
  }
  
  return tmpArray;
}

//------------------------------------------------------------------------------
// 後で場所変更 描画するリプレイデータ
- (void)selectReplayData {
  NSMutableArray *tmpArray_rank1 = [NSMutableArray array];
  int p = 0;
  [tmpArray_rank1 addObject:[rankingData privateNameAt:p]];
  [tmpArray_rank1 addObject:[NSNumber numberWithDouble:[rankingData privateScoreAt:p]]];
  
  for(int j = 0; j < PANEL_MAX; j ++) {
    [tmpArray_rank1 addObject:[NSNumber numberWithDouble:[rankingData pPrivateReplayAt:p]->replay[j]]];
  }
  [tmpArray_rank1 addObject:[NSNumber numberWithInt:(int)[rankingData pPrivateReplayAt:p]->stage]];
}

//------------------------------------------------------------------------------
//  エディットボタンアクション
//------------------------------------------------------------------------------
- (IBAction)touch_EditBtn:(UIButton *)sender {
  [self show_EdittingMode];
}

// エディットボタンの実行内容
- (void)show_EdittingMode{
  
  if(flagEdit){
    
    flagEdit = NO;
    
    //ボタンをずらす
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.4];
    
    for(int i = 0; i < RANKING_LINE_MAX; i++) {
      // テキストの移動
      rankingRankLabel[i].frame = DelRankLabelRect;
      rankingTimeLabel[i].frame = DelTimeLabelRect;
      rankingNameLabel[i].frame = DelNameLabelRect;
      // ボタンの移動
      btnReplay[i].frame = DelReplayBtnRect;
      btnReplay[i].userInteractionEnabled = NO;
      btnDeleteKey[i].frame = DelDeleteBtnRect;
      btnDeleteKey[i].alpha = 1.0;
    }
    [btnEdit setTitle:@"Done" forState:UIControlStateNormal];
    [btnEdit setBackgroundImage:[UIImage imageNamed:@"mini40Button3.png"]  forState:UIControlStateNormal];
    
    [UIView commitAnimations];
  }
  else{
    
    flagEdit = YES;
    
    //ボタンを戻す
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.4];
    
    // after の動作
    for(int i = 0; i < RANKING_LINE_MAX; i++) {
      // テキストの移動
      rankingRankLabel[i].frame = RankLabelRect;
      rankingTimeLabel[i].frame = TimeLabelRect;
      rankingNameLabel[i].frame = NameLabelRect;
      // ボタンの移動
      btnReplay[i].frame = ReplayBtnRect;
      btnReplay[i].userInteractionEnabled = YES;
      btnDeleteKey[i].frame = DeleteBtnRect;
      btnDeleteKey[i].alpha = 0.0;
    }
    [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
    [btnEdit setBackgroundImage:[UIImage imageNamed:@"mini40Button1.png"]  forState:UIControlStateNormal];
    
    [UIView commitAnimations];
  }
  
}


// デリートボタンアクション
- (IBAction)deleteButtonClick:(UIButton*)sender{
  
  UIAlertView *alert_ = [[UIAlertView alloc] initWithTitle:@"Delete Record ?"
                                                   message:[NSString stringWithFormat:@"%d:  %@  %.3f",sender.tag+1,
                                                            [rankingData privateNameAt:(int)sender.tag],
                                                            [rankingData privateScoreAt:(int)sender.tag]]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
  alert_.tag = sender.tag;
  [alert_ show];
  
}

// リプレイデータを削除
-(void)deletePrivateRankingAt:(int)index_{
  
  [rankingData deletePrivateRankingAt:index_];
  // リプレイボタンの表示 リプレイデータが無いものはリプレイボタン非表示 99位まで確認
  for (int i=0; i<RANKING_PRIVATE_MAX; i++) {
    if ([rankingData pPrivateReplayAt:i]->stage == 0) {
      btnReplay[i].alpha = 0.0;
    }
  }
  //再描画
  [self showRankView];
  [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.7f];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  NSLog(@"%@",alertView.title);
  
  if ([alertView.title isEqualToString:@"Delete Record ?"] && buttonIndex==1 ) {
    [self deletePrivateRankingAt:(int)alertView.tag];
  }
  
}

// エディットボタンを表示
- (void)showEditBtn {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.1];
  [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
  [btnEdit setBackgroundImage:[UIImage imageNamed:@"mini40Button1.png"]  forState:UIControlStateNormal];
  [btnEdit setEnabled:YES];
  [UIView commitAnimations];
}

// エディットボタンを隠す
- (void)hideEditBtn {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.2];
  [btnEdit setEnabled:NO];
  [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
  [UIView commitAnimations];
}

// 編集モードを解除
- (void)stopEditing {
  
  // 編集モードから戻る時
  
  flagEdit = YES;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration:0.3];
  
  for(int i = 0; i < RANKING_LINE_MAX; i++) {
    // テキストの移動
    rankingRankLabel[i].frame = RankLabelRect;
    rankingTimeLabel[i].frame = TimeLabelRect;
    rankingNameLabel[i].frame = NameLabelRect;
    // ボタンの移動
    btnReplay[i].frame = ReplayBtnRect;
    btnReplay[i].userInteractionEnabled = YES;
    btnDeleteKey[i].frame = DeleteBtnRect;
    btnDeleteKey[i].alpha = 0.0;
  }
  [UIView commitAnimations];
  
}



//------------------------------------------------------------------------------
- (NSString *)decodeString:(NSString *)urlString {
  //LOG();
  
  return (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                NULL,
                                                                                                (CFStringRef) urlString,
                                                                                                CFSTR(""),
                                                                                                kCFStringEncodingUTF8
                                                                                                ));
}


//------------------------------------------------------------------------------
//  rankingView表示時のカバーViewの作成
//------------------------------------------------------------------------------
- (void)createCoverView {
  LOG();
  
  CGRect        rect;
  rect.origin.x    = 0.0f;
  rect.origin.y    = 0.0f;
  rect.size.width    = screenSize.width;
  rect.size.height  = screenSize.height;
  
  if(!coverView){
    coverView          = [[UIView alloc] initWithFrame:rect];
    coverView.backgroundColor  = [UIColor clearColor];
  }
  
  [self addSubview:coverView];
}


//------------------------------------------------------------------------------
//  rankingView表示時のカバーViewの削除
//------------------------------------------------------------------------------
- (void)destroyCoverView {
  LOG();
  
  [coverView removeFromSuperview];
  coverView = nil;
}


//------------------------------------------------------------------------------
//  拡張ランキング部分の表示、非表示を設定する
//------------------------------------------------------------------------------
- (void)ExpandedRankingHidden:(BOOL)state {
  for(int i = RANKING_PRIVATE_MAX; i < RANKING_LINE_MAX; i++) {
    rankingLineView[i].hidden = state;
  }
}


//==============================================================================
#pragma mark - Private Ranking





//------------------------------------------------------------------------------
//  現在のリプレイデータをチェックする
//  NOTE  :  ここでの結果を元にunsentdata.datの"replayData"には-1が書き込まれる
//        送る直前のcheckSendReplayData()で-1を検出しNOを返す
//------------------------------------------------------------------------------
- (BOOL)checkNowReplayData:(double *)replayData {
  LOG();
  
  BOOL result = YES;
  
  for(int i = 1; i < PANEL_MAX; i++) {
    if(replayData[i - 1] > replayData[i]) {
      result = NO;
      break;
    }
  }
  return result;
}



//------------------------------------------------------------------------------
//  プライベートランキング表示データ設定
//------------------------------------------------------------------------------
- (void)setPrivateRanking {
  LOG();
  
  [self ExpandedRankingHidden:YES];
  
  rankView.alpha      = 1.0f;
  rankView.contentSize  = CGSizeMake(256.0f, (float)(RANKING_LINE_HEIGHT * RANKING_PRIVATE_MAX));
  
  for(int i = 0; i < RANKING_PRIVATE_MAX; i++) {
    if(i % 2 == 0) {
      [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.7f alpha:1.0f]];
    } else {
      [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:1.0f]];
    }
    
    if(rankNow == i) {
      [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.8f alpha:1.0f]];
      [rankView scrollRectToVisible:CGRectMake(0.0, (i - 4.5) * 25, 244, 250) animated:YES];
    }
    [rankingRankLabel[i] setText:[NSString stringWithFormat:@"%3d: ", i + 1]];
    
    // リプレイグラフボタンに変更
    [btnReplay[i] setImage:[UIImage imageNamed:@"graphBtn.png"] forState:UIControlStateNormal];
    if(flagEdit){ // 編集モードではボタン位置固定
      [btnReplay[i] setFrame:ReplayBtnRect];
    }
    
    
    if([rankingData privateScoreAt:i] < 9900.0f) {
      if([rankingData pPrivateReplayAt:i]->replay[0] >= 0) {
        // 初期値以外ならリプレイボタンを表示
        btnReplay[i].alpha = 1.0f;
      }
      NSMutableString  *tmp  = [[NSMutableString alloc] init];
      [tmp setString:[NSString stringWithFormat:@"%.3f", [rankingData privateScoreAt:i]]];
      
      if([tmp length] > 6) {
        [tmp setString:[tmp substringWithRange:NSMakeRange(0, 6)]];
      }
      [rankingTimeLabel[i] setText:tmp];
      [rankingNameLabel[i] setText:[NSString stringWithFormat:@"%@", [rankingData privateNameAt:i]]];
      
      // リプレイボタンの位置微調整
      UIEdgeInsets insets;
      
      insets.top    = 0;
      insets.bottom  = 0;
      insets.right  = 0;
      insets.left    = 50;
      [btnReplay[i] setImageEdgeInsets:insets];
      [btnReplay[i] setContentEdgeInsets:insets];
      
    } else {
      [rankingTimeLabel[i] setText:[NSString stringWithFormat:@" "]];
      [rankingNameLabel[i] setText:[NSString stringWithFormat:@" "]];
      btnReplay[i].alpha = 0.0f;
      btnDeleteKey[i].hidden = YES; // スコアがないところは非表示
    }
  }
  
  
}


//==============================================================================
#pragma mark - Total Ranking

//------------------------------------------------------------------------------
//  Totalランキング表示データ設定
//------------------------------------------------------------------------------
- (void)setTotalRanking {
  LOG();
  totalShowedNumArr = [NSMutableArray array]; // グラフボタンに変えるランキングの配列
  
  if([rankingData totalRankingArray]!=nil){
    LOG(@"ランキングデータを表示する処理");
    [self ExpandedRankingHidden:NO];
    
    rankView.alpha      = 1.0f;
    rankView.contentSize  = CGSizeMake(256.0f, (float)(RANKING_LINE_HEIGHT * RANKING_TOTAL_MAX));
    
    for(int i = 0; i < RANKING_TOTAL_MAX; i++) {
      
      NSString *name_ = [rankingData totalNameAt:i];
      double time_ = [rankingData totalTimeAt:i];
      BOOL replayFlag_ = [rankingData totalReplayFlagAt:i];
      
      if(i % 2 == 0) {
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.7f alpha:1.0f]];
      } else {
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:1.0f]];
      }
      
      if([playerName compare:name_] == NSOrderedSame && floor(time_ * 1000) == floor(playerScore * 1000)) {
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.8f alpha:1.0f]];
        [rankView scrollRectToVisible:CGRectMake(0.0f, (float)(i - 4.5) * 25, 244.0f, 250.0f) animated:YES];
      }
      [rankingRankLabel[i] setText:[NSString stringWithFormat:@"%3d: ", i + 1]];
      
      if(time_ < 9900.0f){
        NSMutableString  *tmp = [[NSMutableString alloc] init];
        [tmp setString:[NSString stringWithFormat:@"%.3f", time_]];
        
        if([tmp length] > 6) {
          [tmp setString:[tmp substringWithRange:NSMakeRange(0, 6)]];
        }
        [rankingTimeLabel[i] setText:tmp];
        [rankingNameLabel[i] setText:[NSString stringWithFormat:@"%@", name_]];
        
      } else {
        [rankingTimeLabel[i] setText:[NSString stringWithFormat:@" "]];
        [rankingNameLabel[i] setText:[NSString stringWithFormat:@" "]];
        //[btnDeleteKey[i] setImage:[UIImage imageNamed:@" "] forState:UIControlStateNormal];
        btnDeleteKey[i].hidden = YES;
      }
      
      if(replayFlag_) {
        // リプレイボタンの位置微調整
        UIEdgeInsets insets;
        insets.top      = 0;
        insets.bottom    = 0;
        insets.right    = 0;
        insets.left      = 50;
        btnReplay[i].alpha  = 1.0f;
        [btnReplay[i] setImageEdgeInsets:insets];
        [btnReplay[i] setContentEdgeInsets:insets];
        
      } else {
        btnReplay[i].alpha  = 0.0f;
      }
      
      //-------------------------------------------------------------------
      // Save Dataがあればボタン画像を変える
      // リプレイデータが再生されたものか確認する
      
      BOOL checkLoadData = [self checkShownData:time_ tag:kReplayType_Total];
      
      // されていればグラフボタンに
      if (checkLoadData == TRUE){
        [btnReplay[i] setImage:[UIImage imageNamed:@"graphBtn.png"] forState:UIControlStateNormal];
        [btnReplay[i] setFrame:ReplayBtnRect];
        
        // グラフボタンに変えるランキングの配列
        [totalShowedNumArr addObject:[NSNumber numberWithInt:i]];
        
      } else if (checkLoadData == FALSE) {
        // リプレイ表示してないものは通常ボタン
        [btnReplay[i] setImage:[UIImage imageNamed:@"ttnTriangle.png"] forState:UIControlStateNormal];
        [btnReplay[i] setFrame:CGRectMake(-0.0f, 0.0f, 256.0f, 25.0f)];
      }
    }
  }else{
    LOG(@"通信失敗してるっぽい処理");
    rankView.alpha = 0.0f;
  }
}


//==============================================================================
#pragma mark - Daily Ranking

//------------------------------------------------------------------------------
//  Dailyランキング表示データ設定
//------------------------------------------------------------------------------
- (void)setDailyRanking {
  LOG();
  
  LOG(@"setTotalRankingと同様に変更。");
  
  dailyShowedNumArr = [NSMutableArray array]; // ランキングボタンに変える順位配列
  
  if([rankingData dailyRankingArray]!=nil){
    LOG(@"ランキングデータを表示する処理");
    [self ExpandedRankingHidden:NO];
    
    rankView.alpha      = 1.0f;
    rankView.contentSize  = CGSizeMake(256.0f, (float)(RANKING_LINE_HEIGHT * RANKING_DAILY_MAX));
    
    for(int i = 0; i < RANKING_DAILY_MAX; i++) {
      
      NSString *name_ = [rankingData dailyNameAt:i];
      double time_ = [rankingData dailyTimeAt:i];
      BOOL replayFlag_ = [rankingData dailyReplayFlagAt:i];
    
      if(i % 2 == 0) {
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.7f alpha:1.0f]];
      } else {
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:1.0f]];
      }
      
      if([playerName compare:name_] == NSOrderedSame && floor(time_ * 1000) == floor(playerScore * 1000)){
        [rankingLineView[i] setBackgroundColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.8f alpha:1.0f]];
        [rankView scrollRectToVisible:CGRectMake(0.0f, (float)(i - 4.5) * 25, 244.0f, 250.0f) animated:YES];
      }
      [rankingRankLabel[i] setText:[NSString stringWithFormat:@"%3d: ", i + 1]];
      
      if(time_ < 9900.0f){
        NSMutableString  *tmp = [[NSMutableString alloc] init];
        [tmp setString:[NSString stringWithFormat:@"%.3f", time_]];
        
        if([tmp length] > 6) {
          [tmp setString:[tmp substringWithRange:NSMakeRange(0, 6)]];
        }
        [rankingTimeLabel[i] setText:tmp];
        [rankingNameLabel[i] setText:[NSString stringWithFormat:@"%@", name_]];
      } else {
        [rankingTimeLabel[i] setText:[NSString stringWithFormat:@" "]];
        [rankingNameLabel[i] setText:[NSString stringWithFormat:@" "]];
        btnDeleteKey[i].hidden = YES; // スコアがないところは非表示
      }
      
      if(replayFlag_) {
        // リプレイボタンの位置微調整
        UIEdgeInsets insets;
        insets.top      = 0;
        insets.bottom    = 0;
        insets.right    = 0;
        insets.left      = 50;
        btnReplay[i].alpha  = 1.0f;
        [btnReplay[i] setImageEdgeInsets:insets];
        [btnReplay[i] setContentEdgeInsets:insets];
        
      } else {
        btnReplay[i].alpha  = 0.0f;
      }
      
      //-------------------------------------------------------------------
      // Save Dataがあればボタン画像を変える
      // リプレイデータが再生されたものか確認する
      BOOL checkLoadData = [self checkShownData:time_ tag:kReplayType_Daily];
      // されていればグラフボタンに
      if (checkLoadData == TRUE){
        [btnReplay[i] setImage:[UIImage imageNamed:@"graphBtn.png"] forState:UIControlStateNormal];
        [btnReplay[i] setFrame:ReplayBtnRect];
        
        // グラフボタンに変えるランキングの配列
        [dailyShowedNumArr addObject:[NSNumber numberWithInt:i]];
        
      } else if (checkLoadData == FALSE) {
        // リプレイ表示してないものは通常ボタン
        [btnReplay[i] setImage:[UIImage imageNamed:@"ttnTriangle.png"] forState:UIControlStateNormal];
        [btnReplay[i] setFrame:CGRectMake(-0.0f, 0.0f, 256.0f, 25.0f)];
      }
    }
  }else{
        rankView.alpha = 0.0f;
  }
  
}


//==============================================================================
#pragma mark - twitter

//------------------------------------------------------------------------------
// twitterアカウントチェック
- (void)settingTwitter{
  LOG();
  
  // iOS6以上はSocial.frameworkを使う
  Class flagiOS6 = NSClassFromString(@"SLComposeViewController");
  
  if(flagiOS6){
    // iOS6 〜
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
      // アカウントあり
      [self showTwitterSettingAlert];
      return;
    }
    
  } else {
    // iOS5
    if([TWTweetComposeViewController canSendTweet]) {
      // アカウントあ
      [self showTwitterSettingAlert];
      return;
    }
  }
  
  SoundEngine_StartEffect( _soundSelect);
  
  // アカウント設定Alert
  NSString *msg  = [NSString stringWithFormat:NSLocalizedString(@"TwitterAlertTitle", nil)];
  NSString *msg2 = [NSString stringWithFormat:NSLocalizedString(@"TwitterAlertMessa", nil)];
  
  UIAlertView *alert  =  [[UIAlertView alloc] initWithTitle: msg
                                                    message: msg2
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil
                          ];
  [alert show];
  
}

//------------------------------------------------------------------------------
// twitter設定Alert
- (void)showTwitterSettingAlert{
  LOG();
  
  SoundEngine_StartEffect( _soundSelect);
  
  NSString *mes = [NSString stringWithFormat:@"Post 1st record"];
  
  [  simpleAlert[SA_MV_SETTING_TWITTER]
   show      : @"twitter account setting"
   message  : mes
   buttons  : @"ON",@"OFF", nil
   ];
}

//------------------------------------------------------------------------------
// twitter framework alerthandler
- (void)handlerSimpleAlertSettingTwitter:(NSNumber *)buttonIndex{
  LOG();
  
  // ON
  if([buttonIndex intValue] == 0){
    flagTwitterSwitch = YES;
  }
  // OFF
  if([buttonIndex intValue] == 1){
    flagTwitterSwitch = NO;
  }
  
  // Save
  [[NSUserDefaults standardUserDefaults] setBool:flagTwitterSwitch forKey:@"Twitter"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

//==============================================================================
#pragma mark - SettingsView

//------------------------------------------------------------------------------
- (void)openSettingsView {
  LOG();
  
  if(!FREE_FLAG) {  // Pro版のみ
    SoundEngine_StartEffect( _soundSelect);
    
    settingsViewController.view.frame = CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height);
    [self addSubview:settingsViewController.view];
    /*
     // アニメ設定
     [settingsViewController.view setTransform:transform[2]];
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:0.3];
     [settingsViewController.view setTransform:transform[1]];
     [UIView commitAnimations];
     */
  }
  return;
}
//------------------------------------------------------------------------------
- (void)hideSettingsView {
  LOG();
  
  if(!FREE_FLAG) {  // Pro版のみ
    SoundEngine_StartEffect( _soundSelect);
    [settingsViewController.view removeFromSuperview];
    
    // ゲームモード
    if([settingsViewController getStatusTraningMode] == YES) {
      gameModeView.alpha = 1.0f;
      gameModeLabel.text = @"Traning mode";
    } else {
      gameModeView.alpha = 0.0f;
    }
  }
  return;
}
//==============================================================================
#pragma mark - HouseAdViewControllerDelegate


//==============================================================================
#pragma mark - AdWebView

//------------------------------------------------------------------------------
- (IBAction)backFromAdWebView:(id)sender {
  LOG();
  
  [self hideAdWebView];
}


//------------------------------------------------------------------------------
- (void)didHideAdWebView {
  LOG();
  
  [adWebViewController.view removeFromSuperview];
}


//------------------------------------------------------------------------------
- (void)showAdWebView {
  LOG();
  
  adWebViewController.view.center = CGPointMake(
                                                self.center.x,
                                                self.bounds.size.height + adWebViewController.view.bounds.size.height / 2
                                                );
  [self addSubview:adWebViewController.view];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3f];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  adWebViewController.view.center = CGPointMake(self.center.x, self.center.y);
  [UIView commitAnimations];
  [adWebViewController initAdWebView];
}


//------------------------------------------------------------------------------
- (void)hideAdWebView {
  LOG();
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDuration:0.3f];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(didHideAdWebView)];
  adWebViewController.view.center = CGPointMake(
                                                self.center.x,
                                                self.bounds.size.height + adWebViewController.view.bounds.size.height / 2
                                                );
  [UIView commitAnimations];
  
}


//==============================================================================
#pragma mark - Game Center

//------------------------------------------------------------------------------
//  ゲームセンターに1日のプレイ回数を送信する
//------------------------------------------------------------------------------
- (void)postGameCenterPlayCountDaily:(int)count {
  LOG(@"%d", count);
  
  [self reportScore:(int64_t)count forCategory:GAME_CENTER_PLAY_COUNT];
  
}


//------------------------------------------------------------------------------
//  ゲームセンターにスコア(Total)を送信する
//------------------------------------------------------------------------------
- (void)postGameCenterPlayScoreTotal:(float)score {
  //LOG();
  
  int post_score = [[NSString stringWithFormat:@"%3.3f", ((score * 100) + 0.5f)] intValue];
  
  LOG(@"%d", post_score);
  [self reportScore:(int64_t)post_score forCategory:GAME_CENTER_PLAY_SCORE];
  
}


//------------------------------------------------------------------------------
- (void)reportScore:(int64_t)score forCategory:(NSString *)category {
  LOG(@"catefory:%@, score:%lld", category, score);
  
  GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
  
  scoreReporter.value = score;
  [  scoreReporter
   reportScoreWithCompletionHandler:^(NSError *error) {
     if(error != nil) {
       // handle the reporting error
       LOG(@"%@",[error localizedDescription]);
     }
   }
   ];
}


// =============================================================================
#pragma mark - SimpleAlert


//------------------------------------------------------------------------------
//  全SimpleAlertの生成
//------------------------------------------------------------------------------
- (void)initAllSimpleAlert {
  LOG();
  
  simpleAlert[SA_MV_JUMP_TO_TEKUNODO]      = [[SimpleAlert alloc] initWith:self selector:@selector(handlerSimpleAlertJumpToTekunodo:)];
  simpleAlert[SA_MV_CONFIRM_REPLAY]      = [[SimpleAlert alloc] initWith:self selector:@selector(handlerSimpleAlertConfirmReplay:)];
  simpleAlert[SA_MV_CONFIRM_REPLAY_POST]    = [[SimpleAlert alloc] initWith:self selector:@selector(handlerSimpleAlertConfirmReplay_Post:)];
  simpleAlert[SA_MV_SETTING_TWITTER]        = [[SimpleAlert alloc] initWith:self selector:@selector(handlerSimpleAlertSettingTwitter:)];
  simpleAlert[SA_MV_TIME_OVER]        = [[SimpleAlert alloc] initWith:self selector:@selector(handlerSimpleAlertTimeOver:)];
  simpleAlert[SA_MV_ERROR_TIMEOUT]      = [[SimpleAlert alloc] initWith:nil selector:nil];
  simpleAlert[SA_MV_ERROR_CONNECTION_LOST]  = [[SimpleAlert alloc] initWith:nil selector:nil];
  simpleAlert[SA_MV_ERROR_DOWNLOAD_REPLAY]  = [[SimpleAlert alloc] initWith:nil selector:nil];
}


//------------------------------------------------------------------------------
//  全SimpleAlertの破棄
//------------------------------------------------------------------------------
- (void)destoryAllSimpleAlert {
  LOG();
  
  for(int i = 0; i < SA_MV_MAX; i++) {
    if(simpleAlert[i] != nil) {
      simpleAlert[i] = nil;
    }
  }
}


//------------------------------------------------------------------------------
//  全SimpleAlertの非表示
//------------------------------------------------------------------------------
- (void)hideAllSimpleAlert {
  LOG();
  
  for(int i = 0; i < SA_MV_MAX; i++) {
    [simpleAlert[i] hide];
  }
}


//------------------------------------------------------------------------------
//  リプレイ実行確認アラート
//------------------------------------------------------------------------------
- (void)createSimpleAlertConfirmReplay:(NSString *)string {
  LOG();
  
  [  simpleAlert[SA_MV_CONFIRM_REPLAY]
   show  : @"Replay"
   message  : string
   buttons  : [NSString stringWithFormat:NSLocalizedString(@"Replay", nil)],
   @"Cancel", nil
   ];
  
}

//------------------------------------------------------------------------------
//  リプレイ実行確認アラート（ランキング1位のデータを再送信用）
//------------------------------------------------------------------------------
- (void)createSimpleAlertConfirmReplay_ResendReplayData:(NSString *)string {
  LOG();
  
  NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Replay", nil)];
  NSString *msg2 = [NSString stringWithFormat:NSLocalizedString(@"Repost best score", nil)];
  
  [  simpleAlert[SA_MV_CONFIRM_REPLAY_POST]
   show      : @"Replay / Repost"
   message  : string
   buttons  : msg , msg2 ,@"Cancel", nil
   ];
  
}
//------------------------------------------------------------------------------
//  リプレイ実行確認アラートのハンドラー
//------------------------------------------------------------------------------
- (void)handlerSimpleAlertConfirmReplay:(NSNumber *)buttonIndex {
  LOG();
  
  // OK
  if([buttonIndex intValue] == 0) {
    LOG(@"replaytype:%d", replayType);
    
    switch(replayType) {
      case kReplayType_Private: {
        gameReplay    = 1;
        replayNumber  = 0;
        playerScore    = [rankingData privateScoreAt:replayTag];
        
        for(int i = 0; i < PANEL_MAX; i ++) {
          replay[i] = [rankingData pPrivateReplayAt:replayTag]->replay[i];
        }
        srand((unsigned)[rankingData pPrivateReplayAt:replayTag]->stage);
        [self startGame];                  // リプレイ状態で実行
      }
        break;
        
        // 一度リプレイを見たらGraph表示
      case kReplayType_Total: {
        [replayController downloadReplayData:[rankingData totalNameAt:replayTag] time:[rankingData totalTimeAt:replayTag] type:kDownloadType_Total delegate:self];

        // GraphBtnに変更
        LOG(@"トータルがリプレイされました");
        [self addGraphBtn:[rankingData totalNameAt:replayTag] time:[rankingData totalTimeAt:replayTag] tag:kReplayType_Total];

      }
        break;
        
      case kReplayType_Daily: {
        [replayController downloadReplayData:[rankingData dailyNameAt:replayTag] time:[rankingData dailyTimeAt:replayTag] type:kDownloadType_Daily delegate:self];

        // GraphBtnに変更
        LOG(@"デイリーがリプレイされました");
        [self addGraphBtn:[rankingData dailyNameAt:replayTag] time:[rankingData dailyTimeAt:replayTag] tag:kReplayType_Daily];

      }
        break;
    }
  }
  
}

//------------------------------------------------------------------------------
//  リプレイポストのアラートのハンドラー
//------------------------------------------------------------------------------
- (void)handlerSimpleAlertConfirmReplay_Post:(NSNumber *)buttonIndex {
  
  LOG(@"%@",buttonIndex);
  
  if([buttonIndex intValue] == 0){
    
    switch(replayType) {
      case kReplayType_Private: {
        gameReplay    = 1;
        replayNumber  = 0;
        playerScore    = [rankingData privateScoreAt:replayTag];  // 最後に同期させるのに必要
        
        for(int i = 0; i < PANEL_MAX; i ++) {
          replay[i] = [rankingData pPrivateReplayAt:replayTag]->replay[i];
          LOG(@"%f", replay[i]);
        }
        srand((unsigned)[rankingData pPrivateReplayAt:replayTag]->stage);
        [self startGame];                  // リプレイ状態で実行
      }
        break;
        
      case (kReplayType_Total):
        // GraphAlert -> Replay
        [replayController downloadReplayData:[rankingData totalNameAt:replayTag] time:[rankingData totalTimeAt:replayTag] type:kDownloadType_Total delegate:self];
        break;
        
      case (kReplayType_Daily):
        // GraphAlert -> Replay
        [replayController downloadReplayData:[rankingData dailyNameAt:replayTag] time:[rankingData dailyTimeAt:replayTag] type:kDownloadType_Daily delegate:self];
        break;
        
      default:
        break;
    }
  }
  
  if([buttonIndex intValue] == 1){
    flagResendData = YES;
    repostedTimes ++;
    LOG(@"*** 本日Repostした回数:%d",repostedTimes);
    
    // 日付を保存
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    date.dateFormat  = @"MM/dd";
    NSString *lastdate = [date stringFromDate:[NSDate date]];
    LOG(@"*** 今現在:%@",lastdate);
    
    if(repostedTimes<4){
      NSArray *arr = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:repostedTimes],
                      lastdate,
                      nil];
      // 保存する
      [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"Repost_Info"];
      
      // リポストする
      [self showProgresAlert];
      [indicatorView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.7f];
      [rankingData resendBestTime];
      
    } else {
      // 何もせず終了
      [self showRepostedAlert];
      flagResendData = NO;
    }
  }
  
  if([buttonIndex intValue] == 2){
    
    // キャンセル処理
  }
  
  // graph alert release
  if ( graphAlert.alert )  {
    // 広告戻す
    //    adfurikunView = graphAlert.adView ;
    //    adfurikunView.frame = CGRectMake(
    //                     0.0f,
    //                     screenSize.height -  ADFRJS_VIEW_SIZE_320x50.height,
    //                     ADFRJS_VIEW_SIZE_320x50.width,
    //                     ADFRJS_VIEW_SIZE_320x50.height
    //                     );
    //    [self addSubview:adfurikunView];
    
    // release graphAlert
    [graphAlert releaseAlert];
    
  }
  
  // remove
  [backAlertView removeFromSuperview];
  
}
//------------------------------------------------------------------------------
//  スコア送信時のUIProgressView Alert
//------------------------------------------------------------------------------

- (void)showProgresAlert {
  
  alertView_Post = [[UIAlertView alloc] initWithTitle:@"Sending"
                                              message: @"Please wait..."
                                             delegate: self
                                    cancelButtonTitle: nil
                                    otherButtonTitles: nil
                    ];
  
  progressView = [[UIProgressView alloc]initWithFrame:CGRectMake
                  (30.0f, 80.0f, 225.0f, 90.0f)];
  
  
  [alertView_Post addSubview:progressView];
  [progressView setProgressViewStyle: UIProgressViewStyleDefault];
  [alertView_Post show];
  
  //---------------------------------------------
  // iOSVersion 4.3ではprogressBarはタイマー処理
  float iOSVersion = [[NSString stringWithFormat:@"%@",[TKND iOSVersion]] floatValue];
  LOG(@"### iOSVersion:%0.2f",iOSVersion);
  
  // iOS5.1.1でリリースするのでここはコメントする
  if(4.9 < iOSVersion){
    // versionによる挙動変更
    [progressView setProgress:1.0 animated:YES];
    [self performSelector:@selector(hiddenAlert) withObject:nil afterDelay:1.7];
    
    
  } else {
    [NSTimer scheduledTimerWithTimeInterval:0.03f
                                     target:self
                                   selector:@selector(updateInformation:)
                                   userInfo:nil
                                    repeats:YES];
  }
  // 初期値にする
  n = 1;
  //---------------------------------------------
}
//------------------------------------------------------------------------------
- (void)updateInformation:(NSTimer*)timer
{
  progressView.progress = (float)n/150.0;
  n++;
  if (progressView.progress==1.0f) {
    // タイマーを止める
    [timer invalidate];
    [alertView_Post dismissWithClickedButtonIndex:0 animated:YES];
  }
}
//------------------------------------------------------------------------------
-(void)hiddenAlert{
  [alertView_Post dismissWithClickedButtonIndex:0 animated:YES];
  
  // ProgressBarが完了したら、ランキングリロードフラグを立てる
  flagDataIsUploaded = NO;
  
  [self showRepostedAlert];
}
//------------------------------------------------------------------------------
//回数制限のアラート
-(void)showRepostedAlert{
  // 一日の制限Repostアラートの表示
  alertView_finishiRepost =  [[UIAlertView alloc] initWithTitle: nil
                                                        message: nil
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil
                              ];
  // message処理
  int times = 3 - repostedTimes;
  
  NSString *str;
  if(repostedTimes<4){
    [alertView_finishiRepost setTitle:@"Complete !"];
    str = [NSString stringWithFormat:@"%d  Repost / Day",times];
  } else {
    [alertView_finishiRepost setTitle:@"Upload limit exceeded today"];
    str = [NSString stringWithFormat:@"0  Repost / Day"];
  }
  
  
  [alertView_finishiRepost setMessage:str];
  
  [alertView_finishiRepost show];
}


//------------------------------------------------------------------------------
//  tekunodo.web表示確認アラート
//------------------------------------------------------------------------------
- (void)createSimpleAlertJumpToTekunodo {
  LOG();
  
  // アプリバージョン取得
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
  
  [  simpleAlert[SA_MV_JUMP_TO_TEKUNODO]
   show  : @"Jump to tekunodo web?"
   message  : [NSString stringWithFormat:@"version: %@", version]
   buttons  : @"OK", @"Cancel", nil
   ];
}


//------------------------------------------------------------------------------
//  tekunodo.web表示確認アラートのハンドラー
//------------------------------------------------------------------------------
- (void)handlerSimpleAlertJumpToTekunodo:(NSNumber *)buttonIndex {
  LOG();
  
  if([buttonIndex intValue] == 0) {
    adWebViewController.url            = [NSURL URLWithString:kTekunodoWebURL];
    adWebViewController.navigationTitle.title  = @"tekunodo.";
    [self showAdWebView];
  }
}


//------------------------------------------------------------------------------
//  リプレイダウンロード失敗アラート
//------------------------------------------------------------------------------
- (void)createSimpleAlertErrorDownloadReplay {
  LOG();
  
  [  simpleAlert[SA_MV_ERROR_DOWNLOAD_REPLAY]
   show  : NSLocalizedString(@"Error",nil)
   message  : NSLocalizedString(@"Download failed",nil)
   buttons  : @"OK", nil
   ];
}


//------------------------------------------------------------------------------
//  タイムオーバー時のアラート
//------------------------------------------------------------------------------
- (void)createSimpleAlertTimeOver {
  LOG();
  
  [  simpleAlert[SA_MV_TIME_OVER]
   show  : @"Failure"
   message  : @"Timed out."
   buttons  : @"Retry", nil
   ];
}


//------------------------------------------------------------------------------
//  タイムオーバー時のアラートのハンドラー
//------------------------------------------------------------------------------
- (void)handlerSimpleAlertTimeOver:(NSNumber *)buttonIndex {
  LOG();
  
  if([buttonIndex intValue] == 0) {
    if(battleState == kStateNameEntry) {
      // バトルモードではない
      stage = time(NULL);
      srand((unsigned)stage);
      [self startGame];  //ゲーム開始
    } else {
      // バトルモードである
      [self newGame];
    }
  }
}



//==============================================================================
#pragma mark - Timer

//------------------------------------------------------------------------------
- (void)createGameTimer {
  LOG();
  
  if(gameTimer == nil) {
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:(0.009f) target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
  }
}


//------------------------------------------------------------------------------
- (void)destoryGameTimer {
  LOG();
  
  if([gameTimer isValid]) {
    [gameTimer invalidate];
    gameTimer = nil;
  }
}

//==============================================================================
#pragma mark - Background Activetion
-(void)enterBackGround {
  // ゲーム中はリセット
  flagCountStop = YES;
  
  if(flagRestart){
    [self newGame];
    flagRestart = NO;
  }
}

// フォアグラウンドから立ち上がった時の処理
-(void)becomeActive {
  // flag初期化
  //flagRestart = NO;
  flagCountStop = NO;
}

@end




