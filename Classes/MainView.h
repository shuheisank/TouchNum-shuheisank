#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Vibration.h"

#import "Free.h"
#import "SettingsViewController.h"
#import "ReplayController.h"
#import "NSArray+Addition.h"
#import "AdWebViewController.h"
#import "SimpleAlert.h"
#import "GraphAlert.h"
#import "GraphView.h" // グラフを描画するクラス

#import "RankingData.h"
#import "AdManager.h"

//------------------------------------------------------------------------------
// Social設定
#import "Social/Social.h"
#import <Twitter/TWTweetComposeViewController.h>
//------------------------------------------------------------------------------
#define kTekunodoWebURL  @"http://tekunodo.jp/"

#define PANEL_COL          5
#define PANEL_ROW          5
#define PANEL_MAX          (PANEL_COL * PANEL_ROW)

#define RANKING_PRIVATE_MAX      100
#define RANKING_TOTAL_MAX      200
#define RANKING_DAILY_MAX      200

#define RANKING_LINE_MAX      200    // サーバーとの連携必要(ReplayController.hのkReplayServerRankingAddrを使用)

#define RANKING_LINE_HEIGHT      25

//#define RANKING_UPLOAD_REFERENCE  5.0f  // 〜ver 3.10
#define RANKING_UPLOAD_REFERENCE  6.0f  // ver 3.11〜
//#define RANKING_UPLOAD_REFERENCE  15.0f  // Debug

#define SEC_TIME_OVER        600
//#define SEC_TIME_OVER        30    // Debug

// Game Center category
#ifdef FREE_VERSION
// Free版
#define GAME_CENTER_PLAY_COUNT  @"2"
#define GAME_CENTER_PLAY_SCORE  @"3"
#else
// 有料版
#define GAME_CENTER_PLAY_COUNT  @"grp.countid2"
#define GAME_CENTER_PLAY_SCORE  @"grp.scoreid3"
#endif


#define   RankLabelRect   CGRectMake(0.0f, 0.0f, 40.0f, 25.0f)
#define   TimeLabelRect   CGRectMake(38.0f, 0.0f, 55.0f, 25.0f)
#define   NameLabelRect   CGRectMake(115.0f, 0.0f, 143.0f, 25.0f)
#define   ReplayBtnRect   CGRectMake(-9.0f, 0.0f, 256.0f, 25.0f)
#define   DeleteBtnRect   CGRectMake(-17.0f, 0.0f-2, 200.0f, 30.0f)
#define   DelRankLabelRect   CGRectMake(0.0f+20, 0.0f, 40.0f, 25.0f)
#define   DelTimeLabelRect   CGRectMake(38.0f+20, 0.0f, 55.0f, 25.0f)
#define   DelNameLabelRect   CGRectMake(115.0f+20, 0.0f, 143.0f, 25.0f)
#define   DelReplayBtnRect   CGRectMake(-9.0f+20, 0.0f, 256.0f, 25.0f)
#define   DelDeleteBtnRect   CGRectMake(-5.0f, 0.0f-2, 200.0f, 30.0f)


typedef enum {
  kReplayType_Private = 0,
  kReplayType_Total,
  kReplayType_Daily
} ReplayType;

typedef enum {
  MYAD_TOP = 0,
  MYAD_GAME,
  MYAD_MAX,
} MYADTYPE;

typedef enum {
  SA_MV_JUMP_TO_TEKUNODO = 0,
  SA_MV_CONFIRM_REPLAY,
  SA_MV_CONFIRM_REPLAY_POST,
  SA_MV_SETTING_TWITTER,
  SA_MV_TIME_OVER,
  
  SA_MV_ERROR_DOWNLOAD_REPLAY,
  SA_MV_ERROR_TIMEOUT,
  SA_MV_ERROR_CONNECTION_LOST,
  
  SA_MV_MAX
} SIMPLE_ALERT_TYPE_MAIN_VIEW;

typedef enum {
  ALERT_TYPE_DELETE_PRIVATE_RANKING_DATUM = 100
} ALERT_TYPE;


@class Reachability;
@class MainViewController;

@interface MainView : UIView
<
UIAlertViewDelegate,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
ReplayControllerDelegate
> {
  int            gameState;  //ゲームの状態
  int            gameReplay; //リプレイ中か否か
  int            nextNumber, nextEnemyNumber;
  int            btnNumberValue[25];
  NSDate          *startDate;
  NSTimer          *gameTimer;
  
  BOOL          flagInternetAccess;
  BOOL                    flagEdit; // エディットボタンフラグ
  
  // 効果音
  UInt32          _soundClick;
  UInt32          _se[4];
  UInt32          _seFinished[4];
  UInt32          _soundBGM;
  UInt32          _seBuzzer;
  UInt32          _seCount[4];
  UInt32          _soundSelect;
  
  int            replayTag;
  double          playerScore;
  NSString        *playerName;
  int            rankNow;
  BOOL          flagDataIsUploaded;
  double          finishedTime;
  
  RankingData *rankingData;
  
  BOOL          pageIsWeekly;
  UIScrollView      *rankView;
  NSString        *rankURL;

  // nameFormAlert ------------------
  UIButton *btnReward;
  UIButton *btnStart;
  UIButton *btnChallenge;
  UIButton *btnRanking;

  // ranking ----------------------
  UIView  *rankingLineView[RANKING_LINE_MAX + 1];
  UILabel *rankingRankLabel[RANKING_LINE_MAX + 1];
  UILabel *rankingNameLabel[RANKING_LINE_MAX + 1];
  UILabel *rankingTimeLabel[RANKING_LINE_MAX + 1];
  UIButton  *btnReplay[RANKING_LINE_MAX + 1]; // リプレイ用のボタン
  UIButton  *btnDeleteKey[RANKING_LINE_MAX + 1]; // 削除用のボタン
  UILabel *connectionFailedLabel;

  
  //--------------------------------------------------------------------------
  BOOL          flagInternetConnection;
  BOOL          flagArert;
  
  // transform
  //--------------------------------------------------------------------------
  CGAffineTransform    transform[4];
  
  //  UIImageView        *panelImage[7];
  //--------------------------------------------------------------------------
  IBOutlet UIView      *colorSelectView;
  IBOutlet UIButton    *btnColor0;
  IBOutlet UIButton    *btnColor1;
  IBOutlet UIButton    *btnColor2;
  IBOutlet UIButton    *btnColor3;
  IBOutlet UIButton    *btnColor4;
  IBOutlet UIButton    *btnColor5;
  IBOutlet UIButton    *btnColor6;
  
  //--------------------------------------------------------------------------
  UITextField        *textFieldName;
  
  //--------------------------------------------------------------------------
  //2014/03/02 レベルアップモード追加での実装
  IBOutlet UIView *challengeInfoViewOwner;
  IBOutlet UIView *challengeInfoView;
  IBOutlet UIPickerView *challengePickerView;
  IBOutlet UILabel *selectedLevelLabel;
  IBOutlet UILabel *selectedInfoLabel;
  IBOutlet UIImageView *selectedPanelImage;
  
  IBOutlet UIView *challengeFailedViewOwner;
  IBOutlet UIView *challengeFailedView;
  IBOutlet UIButton *challengeFailedMoreBtn;
  IBOutlet UIButton *challengeFailedRetryBtn;
  IBOutlet UIView *adfuriView_Failed;
  IBOutlet UIView *challengeFinishViewOwner;
  IBOutlet UIView *challengeFinishView;
  IBOutlet UILabel *challengeFinishLabel;
  IBOutlet UIButton *challengeFinishMoreBtn;
  IBOutlet UIButton *challengeFinishRetryBtn;
  IBOutlet UIButton *challengeFinishNextBtn;
  IBOutlet UIImageView *challengeFinishStar_1;
  IBOutlet UIImageView *challengeFinishStar_2;
  IBOutlet UIImageView *challengeFinishStar_3;
  IBOutlet UIView *adfuriView_Finish;
  
  int gameChallenge; //チャレンジモードフラグ
  int selectedLevel;
  int gameLevel;
  int panel_color;
  int start_panel;
  int end_panel;
  float limit_time;
  int starNum;
  NSArray *achievementArr;
  
  //--------------------------------------------------------------------------
  UIImageView        *counterNumber[3];
  IBOutlet UIView      *numbersView;
  IBOutlet UILabel    *lblTimeCounter;
  IBOutlet UILabel    *lblNextNumber;
  IBOutlet UILabel    *lblEnemyNextNumber;
  IBOutlet UIButton    *btnNumber0;
  IBOutlet UIButton    *btnNumber1;
  IBOutlet UIButton    *btnNumber2;
  IBOutlet UIButton    *btnNumber3;
  IBOutlet UIButton    *btnNumber4;
  IBOutlet UIButton    *btnNumber5;
  IBOutlet UIButton    *btnNumber6;
  IBOutlet UIButton    *btnNumber7;
  IBOutlet UIButton    *btnNumber8;
  IBOutlet UIButton    *btnNumber9;
  IBOutlet UIButton    *btnNumber10;
  IBOutlet UIButton    *btnNumber11;
  IBOutlet UIButton    *btnNumber12;
  IBOutlet UIButton    *btnNumber13;
  IBOutlet UIButton    *btnNumber14;
  IBOutlet UIButton    *btnNumber15;
  IBOutlet UIButton    *btnNumber16;
  IBOutlet UIButton    *btnNumber17;
  IBOutlet UIButton    *btnNumber18;
  IBOutlet UIButton    *btnNumber19;
  IBOutlet UIButton    *btnNumber20;
  IBOutlet UIButton    *btnNumber21;
  IBOutlet UIButton    *btnNumber22;
  IBOutlet UIButton    *btnNumber23;
  IBOutlet UIButton    *btnNumber24;
  
  //--------------------------------------------------------------------------
  IBOutlet UIView      *titleView;
  IBOutlet UITextField  *textFieldPlayerName;
  IBOutlet UIView      *indicatorView;
  
  
  //--------------------------------------------------------------------------
  IBOutlet UIView      *rankingView;
  IBOutlet UILabel    *lblRank1;
  IBOutlet UILabel    *lblRank2;
  IBOutlet UILabel    *lblRank3;
  IBOutlet UILabel    *lblRank4;
  IBOutlet UILabel    *lblRank5;
  IBOutlet UILabel    *lblRank6;
  IBOutlet UILabel    *lblRank7;
  IBOutlet UILabel    *lblRank8;
  IBOutlet UILabel    *lblRank9;
  IBOutlet UILabel    *lblRank10;
  
  //--------------------------------------------------------------------------
  IBOutlet UIView      *nameEntryView;
  IBOutlet UIView      *gameModeView;
  IBOutlet UILabel    *gameModeLabel;
  
  
  IBOutlet UIView      *rankingAlView;
  IBOutlet UIView      *rankingAlViewOwner;
  int            rankingPage;
  IBOutlet UIButton    *btnRankPrivate;
  IBOutlet UIButton    *btnRankTotal;
  IBOutlet UIButton    *btnRankWeekly;
  IBOutlet UIButton       *btnEdit;
  
  IBOutlet UILabel    *lblRankingMessage;
  IBOutlet UIImageView  *rankingBackImageView;
  
  //--------------------------------------------------------------------------
  int            isPosted;
  
  // 統計情報
  //--------------------------------------------------------------------------
  int            totalPlay;
  NSDate          *sinceDate;
  int            dailyPlay;
  NSDate          *latestDate;
  IBOutlet UILabel    *lblStats;
  IBOutlet UILabel    *lblStats2;
  IBOutlet UIImageView  *foot;
  
  // Battle Mode
  //--------------------------------------------------------------------------
  int            battleOK, enemy_battleOK;
  double          battleScore, enemyBattleScore;
  NSInteger        battleState;
  NSInteger        peerStatus;
  int            win, waitFirst;
  UIView          *waitingView;
  UILabel          *waitingLabel, *infoLabel;
  
  //--------------------------------------------------------------------------
  double          replay[25];
  int            replaybtn[25];
  int            replayNumber;
  time_t          stage; // 乱数保存
  float          replayAlpha;
  float          replayAlphaAdd;
  
  //--------------------------------------------------------------------------
  int            finishOnce;
  
  //--------------------------------------------------------------------------
  unsigned int      gameUniqueID;
  int            gamePacketNumber;
  int            lastPacketTime;
  NSString        *gamePeerId;
  NSDate          *timeoutDate;
  
  // キャッシュ
  //--------------------------------------------------------------------------
  UIImage          *panel2IMG;
  
  //--------------------------------------------------------------------------
  IBOutlet UIImageView  *nameEntryImageView;
  
  // 設定関連
  //--------------------------------------------------------------------------
  IBOutlet SettingsViewController      *settingsViewController;
  
  //--------------------------------------------------------------------------
  IBOutlet AdWebViewController      *adWebViewController;
  
  //--------------------------------------------------------------------------
  IBOutlet UIToolbar            *toolBar;
  IBOutlet UIBarButtonItem        *newBarButtonItem;
  IBOutlet UIButton            *tekunodoButton;
  
  //--------------------------------------------------------------------------
  ReplayController            *replayController;
  NSMutableArray              *replayDataArray;
  ReplayType                replayType;
  
  //  startupInfoView
  //--------------------------------------------------------------------------
  IBOutlet UIView              *startupInfoView;
  IBOutlet UIView              *startupInfoViewBG;
  IBOutlet UIButton            *startupInfoButtonNo;
  IBOutlet UIButton            *startupInfoButtonYes;
  IBOutlet UILabel            *startupInfoLabelTitle;
  IBOutlet UILabel            *startupInfoLabelMessage;
  IBOutlet UIButton            *startupInfoButton_MoreGames;
  
  
  //--------------------------------------------------------------------------
  IBOutlet UIView              *footerView;
  
  //--------------------------------------------------------------------------
  UIView                  *coverView;
  
  //  4インチ対応(幅と高さ、中心点)
  //--------------------------------------------------------------------------
  CGSize                  screenSize;
  CGPoint                  screenCenter;
  
  SimpleAlert                *simpleAlert[SA_MV_MAX];
  
  //--------------------------------------------------------------------------
  // ver3.16 BackGround Activeの処理
  BOOL                                    flagRestart;     // 再起動フラグ
  //--------------------------------------------------------------------------
  // ver3.18 Repost機能設置
  BOOL                                    flagCountStop;
  BOOL                                    flagResendData;  // ランキング再送信フラグ
  
  UIProgressView                          *progressView;
  UIAlertView                             *alertView_Post;
  UIAlertView                             *alertView_finishiRepost;
  int                                      repostedTimes;  // Repostした回数
  int                                      n;
  
  //--------------------------------------------------------------------------
  // ver3.20 twitter framework 導入
  BOOL                                    flagTwitterSwitch;
  //--------------------------------------------------------------------------
  // ver3.21 Score Graph作成
  GraphAlert                              *graphAlert;
  UIView                                  *backAlertView;
  // adfurikunInterstitial Btn
  UIButton                                *adfurikunInterstitialBtnTop;
  UIButton                                *adfurikunInterstitialBtnRanking;
  //--------------------------------------------------------------------------
  // ver3.22 Total,DailyでGraph表示機能追加
  NSMutableArray                          *replayDataTmpArr;  // ランキングから取得したリプレイデータ
  NSMutableArray                          *totalShowedNumArr; // リプレイされたトータル順位の配列
  NSMutableArray                          *dailyShowedNumArr;
  
  NSMutableArray                          *totalGraphBtnArr;
  NSMutableArray                          *dailyGraphBtnArr;
  BOOL                                    resultFalseData;
  //--------------------------------------------------------------------------
  
  GraphView                               *graphViewClass;
  UIView                                  *alertView;
  UIImageView                             *alertBG;
  UIView                                  *graphView;
  UILabel                                 *finishiMes;
  UILabel                                 *finishiTitle;
  UIButton                                *alertBtn_Replay;
  UIButton                                *alertBtn_Repost;
  UIButton                                *alertBtn_Cancel;
  
  UIButton *btnBattleMode;
  
#ifdef DEBUG
  UILabel                  *debugLabel;
  NSTimer                  *debugTimer;
#endif
}

@property (nonatomic, copy)    NSDate          *startDate;
@property (nonatomic, strong)  IBOutlet UITextField  *textFieldPlayerName;
@property (nonatomic, strong)  NSMutableArray      *replayDataArray;
//@property (nonatomic, strong)   id< GAITracker >        tracker;    // google analytics


//// アドフリくん(広告切替)
//@property (nonatomic, weak)  AdfurikunView      *adfurikunView;
//
////ver3.24 アドフリくん(Wall)
//@property (nonatomic, weak) AdfurikunPopupView       *adfurikunPopupView;

- (IBAction)tapBtn0;
- (IBAction)tapBtn1;
- (IBAction)tapBtn2;
- (IBAction)tapBtn3;
- (IBAction)tapBtn4;
- (IBAction)tapBtn5;
- (IBAction)tapBtn6;
- (IBAction)tapBtn7;
- (IBAction)tapBtn8;
- (IBAction)tapBtn9;
- (IBAction)tapBtn10;
- (IBAction)tapBtn11;
- (IBAction)tapBtn12;
- (IBAction)tapBtn13;
- (IBAction)tapBtn14;
- (IBAction)tapBtn15;
- (IBAction)tapBtn16;
- (IBAction)tapBtn17;
- (IBAction)tapBtn18;
- (IBAction)tapBtn19;
- (IBAction)tapBtn20;
- (IBAction)tapBtn21;
- (IBAction)tapBtn22;
- (IBAction)tapBtn23;
- (IBAction)tapBtn24;

- (IBAction)changeColor:(UIButton*)sender;

- (IBAction)newGame;
- (void)newGame2;
- (IBAction)newGameFromRanking;

- (void)showWorldRankingAlert;

- (void)finished;
- (void)timeOver;
- (void)updateLblNext;

- (void)loadStats;
- (void)saveStats;

- (void)numberTouched:(UIButton*)sender num:(int)btn;

- (void)setButton:(UIButton*)sender num:(int)btn;

- (void)showRankView;
- (void)showNameFormAlert;


//==============================================================================
- (IBAction)touchStartGame;
- (IBAction)touchWebRanking;
- (IBAction)changeRankingPage:(UIButton*)sender;
- (IBAction)showURL:(id) sender;
- (void)startGame;


// 設定関連
- (void)openSettingsView;
- (IBAction)hideSettingsView;

//- (void)postRankingOrSave;

- (IBAction)backFromAdWebView:(id)sender;

- (void)showAdWebView;
- (void)hideAdWebView;
//==============================================================================
// Background activetion
-(void)enterBackGround;
-(void)becomeActive;


@end

