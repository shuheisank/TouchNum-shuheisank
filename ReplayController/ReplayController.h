#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TKND.h"

#define kReplayServer             @"http://118.151.179.20:8845"		// 本番
//#define kReplayServer             @"http://118.151.179.20:9845"		//sandbox

//---------------------------------------------
#define kReplayServerConnectAddr        [NSString stringWithFormat:@"%@/con", kReplayServer]
//Repost
#define kReplayServerConnectAddr_Repost [NSString stringWithFormat:@"%@/con_Repost",kReplayServer]  
//---------------------------------------------
#define kReplayServerScoreAddr          [NSString stringWithFormat:@"%@/score", kReplayServer]
//Repost
#define kReplayServerScoreAddr_Repost   [NSString stringWithFormat:@"%@/score_Repost", kReplayServer]
//---------------------------------------------
#define kReplayServerUploadAddr         [NSString stringWithFormat:@"%@/upload", kReplayServer]
//Repost
#define kReplayServerUploadAddr_Repost  [NSString stringWithFormat:@"%@/upload_Repost", kReplayServer]
//---------------------------------------------

//#define kReplayServerRankingAddr  [NSString stringWithFormat:@"%@/ranking", kReplayServer]	// 〜ver 3.10
#define kReplayServerRankingAddr  [NSString stringWithFormat:@"%@/ranking2", kReplayServer]		// ver 3.11〜
#define kReplayServerDownloadAddr [NSString stringWithFormat:@"%@/download", kReplayServer]

#define kSecretKey               @"5678replaysecret1234"



#define kRankingServerAddr  @"http://tekunodo.jp/ranking/ttnRanking330.php?mode=top200"




typedef enum {
    kDownloadType_Total = 0,
    kDownloadType_Daily,
} DownloadType;

@protocol ReplayControllerDelegate;

@interface ReplayController : NSObject {
//    NSString *_uniqueIdentifier;
    NSString *_username;
    double _score;
    double _sum;
    NSData *_replayData;
    
    id<ReplayControllerDelegate> __weak _delegate;
}

@property (nonatomic, strong) NSString *username;
//@property (nonatomic, strong) NSString *uniqueIdentifier;
@property (nonatomic, assign) double score;
@property (nonatomic, assign) double sum;
@property (nonatomic, strong) NSData *replayData;
@property (weak) id<ReplayControllerDelegate> delegate;

- (id)initWithUsername:(NSString *)username;
// Scoreのみ送信時
//- (BOOL)sendScore:(double)score username:(NSString *)username;
//- (BOOL)sendScore:(double)score username:(NSString *)username flagResendData:(BOOL*)flagResendData;
//
//- (BOOL)sendScore:(double)score username:(NSString *)username withData:(NSMutableArray *)array;
// Repost用メソッド
//- (BOOL)repostScore:(double)score username:(NSString *)username withData:(NSMutableArray *)array flagResendData:(BOOL*)flagResendData;

//- (void)downloadReplayData:(NSString *)name time:(double)time delegate:(id<ReplayControllerDelegate>)delegate;
- (void)downloadReplayData:(NSString *)name time:(double)time type:(DownloadType)type delegate:(id<ReplayControllerDelegate>)delegate;
- (NSMutableArray *)replayGraphDataArray:(NSString *)name time:(double)time type:(DownloadType)type tag:(int)tag;

//- (BOOL)syncConnectRequest:(NSString *)param url:(NSString*)url_;
@end

@protocol ReplayControllerDelegate <NSObject>
- (void)finishDownloadingReplayFile:(NSMutableArray *)array;
@end
