//
//  RankingData.m
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/19.
//

#import "RankingData.h"

@implementation RankingData
@synthesize playerName,rankingDict;
@synthesize flagInternetAccess;

-(id)init{
  self = [super init];
  if(self!=nil){

    [self loadLocalRankingData];
    [self loadWorldRankingData];
  }
  return self;
}

-(void)loadLocalRankingData{
  LOG();
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString    *filepath     = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"scoredata.ddd"];
  NSArray *tmpArray  = [[NSArray alloc] initWithContentsOfFile:filepath];
  
  if([tmpArray objectAtIndex:0] == NULL){
    LOG(@"Could not Open File");
    [self initData];
  }else{
    playerName = [tmpArray objectAtIndex:0];
    
    for(int i = 0; i < RANKING_PRIVATE_MAX ; i++) {
      privateRankingName[i]  = [tmpArray objectAtIndex:(i * 28 + 1)];
      privateRankingScore[i]  = [[tmpArray objectAtIndex:(i * 28 + 2)] doubleValue];
      
      for(int j = 0; j < 25; j ++) {
        privateRankingReplay[i].replay[j] = [[tmpArray objectAtIndex:(i * 28 + (j + 3))] doubleValue];
      }
      privateRankingReplay[i].stage  = [[tmpArray objectAtIndex:(i * 28 + 28)] intValue];
    }
  }
}

-(void)loadWorldRankingData{
  
  if(!self.flagInternetAccess)return;
  
  //未送信データがあったらここで送る
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"unsentdata.dat"];
  NSDictionary  *dict  = [NSDictionary dictionaryWithContentsOfFile:filePath];
  
  NSString *name_ = [dict objectForKey:@"playerName"];
  double time_ = [[dict objectForKey:@"playerScore"] doubleValue];
  
  LOG(@"UnsentDict: %@", dict);
  LOG(@"%@:%f",name_,time_);
  
  [self sendTime:time_ username:name_];
  
}


-(void)initData{
  playerName = @"Player";
  for(int i = 0; i < RANKING_PRIVATE_MAX; i++) {
    privateRankingScore[i]  = 9999.99;
    privateRankingName[i]  = @"";
    
    for(int j = 0; j < 25; j++) {
      privateRankingReplay[i].replay[j] = -1.0;
    }
    privateRankingReplay[i].stage  = 0;
  }
}


-(int)privateRankWithInsertName:(NSString*)name_ time:(double)time_ replay:(double*)replay_ stage:(time_t)stage_{
  LOG(@"***** %@ : %f",name_,time_);
  
  privateRankingName[RANKING_PRIVATE_MAX]    = name_;
  privateRankingScore[RANKING_PRIVATE_MAX]  = time_;
  int rankNow = RANKING_PRIVATE_MAX;
  
  // リプレイデータの保存
  for(int i = 0; i < 25; i ++) {
    [self pPrivateReplayAt:RANKING_PRIVATE_MAX]->replay[i] = replay_[i];
  }
  [self pPrivateReplayAt:RANKING_PRIVATE_MAX]->stage = stage_;
  
  // sort
  for(int i = RANKING_PRIVATE_MAX - 1; i >= 0; i--) {
    if(privateRankingScore[i + 1] < privateRankingScore[i]) {
      rankNow--;
      
      double tmp_score        = privateRankingScore[i];
      privateRankingScore[i]      = privateRankingScore[i + 1];
      privateRankingScore[i + 1]    = tmp_score;
      
      NSString *tmp_name        = privateRankingName[i];
      privateRankingName[i]      = privateRankingName[i + 1];
      privateRankingName[i + 1]    = tmp_name;
      
      REPLAY_DATA replayData_ = privateRankingReplay[i];
      privateRankingReplay[i] = privateRankingReplay[i+1];
      privateRankingReplay[i+1] = replayData_;
    }
  }
  
  [self sendTime:time_ username:name_];
  [self createUnsentDataWithWithName:name_ Replay:replay_ stage:stage_];
  
  return rankNow;
}

-(void)deletePrivateRankingAt:(int)index_{
  LOG(@"%d",index_);
  
  LOG(@"=== 未処理 ===");
  
  // デリートした順位以下を繰り上げる
  for (int i =  index_; i < RANKING_PRIVATE_MAX-1; i++) {
    privateRankingName[i] = privateRankingName[i+1];            // playerName
    privateRankingScore[i] = privateRankingScore[i+1];          // score
    privateRankingReplay[i] = privateRankingReplay[i+1];
  }
  
  // 100位のデータの初期化
  privateRankingName[RANKING_PRIVATE_MAX-1] = @"";
  privateRankingScore[RANKING_PRIVATE_MAX-1] = 9999.99; // Scoreの初期化値
  
  
  [self savePrivateRanking];
}


-(void)savePrivateRanking{
  LOG();
  
  //ファイルパスを指定
  NSArray *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filepath  = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"scoredata.ddd"];
  
  NSMutableArray *tmpArray = [NSMutableArray array];
  [tmpArray addObject: playerName];
  LOG(@"あとで、タイムが大きすぎるものは保存しないようにしたほうがいいのでは？");
  for(int i = 0; i < RANKING_PRIVATE_MAX; i ++) {
    [tmpArray addObject:privateRankingName[i]];
    [tmpArray addObject:[NSNumber numberWithDouble:privateRankingScore[i]]];
    for(int j = 0; j < 25; j ++) {
      [tmpArray addObject:[NSNumber numberWithDouble:[self pPrivateReplayAt:i]->replay[j]]];
    }
    [tmpArray addObject:[NSNumber numberWithLong:[self pPrivateReplayAt:i]->stage]];
  }
  [tmpArray writeToFile:filepath atomically:NO];

}

-(void)sendTime:(double)time_ username:(NSString *)name_{
  LOG(@"********* %@:%f",name_,time_);

  if(!self.flagInternetAccess)return;

  if(name_ == NULL)time_=0;
  
  NSURL *url;
  if(time_>0){
    
    NSString *str_ = [NSString stringWithFormat:@"%@%1.3f",[self escapeStringWithString:name_],time_];
    url =[NSURL URLWithString:[NSString stringWithFormat:@"%@?mode=top200&name=%@&time=%1.3f&sum=%d",kRankingServer,[self escapeStringWithString:name_],time_,[self sumWithString:str_]]];
  }else{
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?mode=top200",kRankingServer]];
  }
  ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
  request.delegate = self;
  [request startSynchronous];
}

-(void)resendBestTime{
  LOG(@"%@:%f",privateRankingName[0],privateRankingScore[0]);
  [self sendTime:privateRankingScore[0] username:privateRankingName[0]];
}


#pragma mark -

-(int)sumWithString:(NSString*)string_{
  int sum =0;
  for (int i=0; i<[string_ length]; i++) {
    sum = (sum + [[NSNumber numberWithUnsignedChar:[string_ characterAtIndex:i]] intValue])%65535;
//    LOG(@"%d",[[NSNumber numberWithUnsignedChar:[string_ characterAtIndex:i]] intValue]);
  }
  LOG(@"%@ sum:%d",string_,sum);
  return sum;
}


//- (NSString *)decodeNameString:(NSString *)urlString {
//  return (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
//                                                                                                NULL,
//                                                                                                (CFStringRef) urlString,
//                                                                                                CFSTR(""),
//                                                                                                kCFStringEncodingUTF8
//                                                                                                ));
//}
//
//- (NSString *)encodeNameString:(NSString *)name {
//
//  return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
//                                                                               NULL,
//                                                                               (CFStringRef)name,
//                                                                               NULL,
//                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                                               kCFStringEncodingUTF8
//                                                                               ));
//}

-(NSString*)escapeStringWithString:(NSString*)URLString
{
  //Reserved characters defined by RFC 3986
  NSString *genDelims = @":/?#[]@";
  NSString *subDelims = @"!$&'()*+,;=";
  NSString *reservedCharacters = [NSString stringWithFormat:@"%@%@",
                                  genDelims,
                                  subDelims];
  //URLQueryAllowedCharacterSetからRFC 3986で予約されている文字を除いたもののみエスケープしない
  NSMutableCharacterSet * allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
  [allowedCharacterSet removeCharactersInString:reservedCharacters];
  return [URLString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet] ? : URLString;
  
}
-(NSString*)decodeStringWithString:(NSString*)URLString{
  return [URLString stringByRemovingPercentEncoding];
}


#pragma mark -

-(void)setPlayerName:(NSString *)playerName_{
  playerName = playerName_;
  
  //保存
  LOG();
  [self savePrivateRanking];
}


-(NSArray*) totalRankingArray{
  NSArray *result = nil;
  if(self.rankingDict != nil){
    result = [self.rankingDict objectForKey:@"Total"];
  }
  return result;
}

-(NSArray*) dailyRankingArray{
  NSArray *result = nil;
  if(self.rankingDict != nil){
    result = [self.rankingDict objectForKey:@"Daily"];
  }
  return result;
}

#pragma mark -

-(NSString*) privateNameAt:(int)i{
  return privateRankingName[i];
}
-(double)privateScoreAt:(int)i{
  return privateRankingScore[i];
}
-(REPLAY_DATA) privateReplayAt:(int)i{
  return privateRankingReplay[i];
}

-(REPLAY_DATA*) pPrivateReplayAt:(int)i{
  return &privateRankingReplay[i];
}


-(NSString*) totalNameAt:(int)i{
  if(i+1>self.totalRankingArray.count) return @"";
  return [[self.totalRankingArray objectAtIndex:i] objectAtIndex:0];
}
-(double) totalTimeAt:(int)i{
  if(i+1>self.totalRankingArray.count) return 9999.999;
  return [[[self.totalRankingArray objectAtIndex:i] objectAtIndex:1] doubleValue];
}
-(BOOL) totalReplayFlagAt:(int)i{
  if(i+1>self.totalRankingArray.count) return NO;
  return [[[self.totalRankingArray objectAtIndex:i] objectAtIndex:2] boolValue];
}

-(NSString*) dailyNameAt:(int)i{
  if(i+1>self.dailyRankingArray.count) return @"";
  return [[self.dailyRankingArray objectAtIndex:i] objectAtIndex:0];
}
-(double) dailyTimeAt:(int)i{
  if(i+1>self.dailyRankingArray.count) return 9999.999;
  return [[[self.dailyRankingArray objectAtIndex:i] objectAtIndex:1] doubleValue];
}
-(BOOL) dailyReplayFlagAt:(int)i{
  if(i+1>self.dailyRankingArray.count) return NO;
  return [[[self.dailyRankingArray objectAtIndex:i] objectAtIndex:2] boolValue];
}



#pragma mark - ASIHTTPRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request{
  LOG(@"url:%@",[request url]);
//  LOG(@"response:%@",[request responseString]);
  
  if([request responseString]!=NULL){
    NSData *data_ = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSPropertyListFormat fmt;
    self.rankingDict = [NSPropertyListSerialization propertyListWithData:data_ options:NSPropertyListImmutable format:&fmt error:&err];
    
//    LOG(@"%@",self.rankingDict);
    
    if(!self.rankingDict){
      LOG(@"Error:%@",err);
    }
    
    LOG(@"Debug:%@",[self.rankingDict objectForKey:@"Debug"]);
    LOG(@"Debug2:%@",[self.rankingDict objectForKey:@"Debug2"]);
    [self removeUnsentData];
  }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
  LOG(@"url:%@",[request url]);
  LOG(@"%@",[[request error] localizedDescription]);
}

#pragma mark -
-(void)removeUnsentData{
  LOG();
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"unsentdata.dat"];
  [[NSMutableDictionary dictionary] writeToFile:filePath atomically:YES];
}

-(void)createUnsentDataWithWithName:(NSString*)name_ Replay:(double*)replay_ stage:(time_t)stage_{
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"unsentdata.dat"];
  
  NSMutableArray *tmpArray_ = [NSMutableArray array];
  [tmpArray_ addObject:name_];
  [tmpArray_ addObject:[NSNumber numberWithDouble:replay_[24]]];
  for (int i=0; i<25; i++) {
    [tmpArray_ addObject:[NSNumber numberWithDouble:replay_[i]]];
  }
  [tmpArray_ addObject:[NSNumber numberWithInt:(int)stage_]];
  
//  LOG(@"%@",tmpArray_);
  
  NSMutableDictionary  *dictionary = [
                                      NSMutableDictionary
                                      dictionaryWithObjectsAndKeys:name_,
                                      @"playerName",
                                      [NSString stringWithFormat:@"%f", replay_[24]],
                                      @"playerScore",
                                      tmpArray_,
                                      @"replayData",
                                      nil
                                      ];
  [dictionary writeToFile:filePath atomically:YES];
  
  LOG(@"%@",dictionary);
}

@end

