//
//  RankingData.h
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/19.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


NS_ASSUME_NONNULL_BEGIN

#define RANKING_PRIVATE_MAX      100
#define RANKING_TOTAL_MAX      200
#define RANKING_DAILY_MAX      200
#define kRankingServer  @"http://tekunodo.jp/ranking/ttnRanking330.php"

//#define kRankingServer  @"http://tekunodo.jp/ranking/ttnRanking330.php?mode=top200"

typedef struct REPLAY_DATA {
  double replay[25];
  time_t stage;
} REPLAY_DATA;
//
//typedef NS_ENUM(NSInteger,RequestTag) {
//  RequestTagTop =0,
//  RequestTagPostOnly =1
//} ;

@interface RankingData : NSObject <ASIHTTPRequestDelegate>
{
  NSString        *playerName;
  
  // Localランキング(Private)
  NSString        *privateRankingName[RANKING_PRIVATE_MAX + 1];
  double          privateRankingScore[RANKING_PRIVATE_MAX + 1];
  REPLAY_DATA     privateRankingReplay[RANKING_PRIVATE_MAX + 1];
  
  BOOL flagInternetAccess;
}
@property(nonatomic) NSString *playerName;
@property(nonatomic) NSDictionary *rankingDict;
@property(nonatomic) BOOL flagInternetAccess;

-(void)loadWorldRankingData;

-(NSArray*) totalRankingArray;
-(NSArray*) dailyRankingArray;

-(NSString*) privateNameAt:(int)i;
-(double) privateScoreAt:(int)i;
-(REPLAY_DATA) privateReplayAt:(int)i;
-(REPLAY_DATA*) pPrivateReplayAt:(int)i;

-(NSString*) totalNameAt:(int)i;
-(double) totalTimeAt:(int)i;
-(BOOL) totalReplayFlagAt:(int)i;

-(NSString*) dailyNameAt:(int)i;
-(double) dailyTimeAt:(int)i;
-(BOOL) dailyReplayFlagAt:(int)i;

-(int)privateRankWithInsertName:(NSString*)name_ time:(double)time_ replay:(double*)replay_ stage:(time_t)stage_;
-(void)deletePrivateRankingAt:(int)index_;
-(void)savePrivateRanking;
-(void)sendTime:(double)time_ username:(NSString *)name_;
-(void)resendBestTime;


@end

NS_ASSUME_NONNULL_END
