//
//  ReplayController.m
//  ReplaySample
//
//  Created by  on 11/12/13.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReplayController.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+Addition.h"
#import "MultipartPostHelper.h"
#import "JSON.h"
//#import "ASIHTTPRequest.h"	[DEL] 2012/08/31 Yoichi Onodera　※クラスヘッダーで定義済み

MultipartPostHelper *postHelper = nil;
NSMutableData *receivedData = nil;

@interface ReplayController (Private)
- (NSString *)encodeName:(NSString *)name;
//- (BOOL)syncConnectRequest:(NSString *)param;
- (void)calcCheckSumForReplayData:(NSData *)file buffer:(uint8_t *)buff;
//- (double)calcCheckSumForScore:(double)score;
- (NSDictionary *)parseJson:(NSData *)data;
- (void)uploadReplayData:(NSString *)verifier uploadFileName:(NSString *)uploadFileName sessionID:(NSString*)sessionId_;
@end

@implementation ReplayController
//@synthesize uniqueIdentifier = _uniqueIdentifier;
@synthesize username         = _username;
@synthesize sum              = _sum;
@synthesize score            = _score;
@synthesize replayData       = _replayData;
@synthesize delegate         = _delegate;

// ==============================================================================================================================
#pragma mark - init/dealloc methods

- (id)init {
    self = [super init];
    if (self) {

//      self.uniqueIdentifier = [self getUserID];
		
//    NSLog(@" Create Identifier id=%@", self.uniqueIdentifier);
    }
    return self;
}

- (id)initWithUsername:(NSString *)username {
    self = [super init];
	
    if (self) {
        self.username = [self encodeName:username];
		
//      self.uniqueIdentifier = [self getUserID];
		
//    LOG(@"***** uniqueIdentifier:%@",self.uniqueIdentifier);
    }
    
    return self;
}

//// UserIDを取得
//- (NSString*)getUserID{
//LOG();
//
//  if(![[NSUserDefaults standardUserDefaults]objectForKey:@"USER_ID"]){
//    // 初回起動
//    [[NSUserDefaults standardUserDefaults]setObject:[TKND uniqueID] forKey:@"USER_ID"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//  }
//  
//  NSString *result = [[NSUserDefaults standardUserDefaults]objectForKey:@"USER_ID"];
//  
//  return result;
//}

- (void)dealloc {
    self.replayData=nil;
    self.username=nil;
//    self.uniqueIdentifier=nil;
}


// ==============================================================================================================================
#pragma mark - Utility methods

/**
 * データの為のチェックサム計算
 */
- (void)calcCheckSumForReplayData:(NSData *)file buffer:(uint8_t *)buff {
    const uint8_t* data = [file bytes];
    
    int length = (int)[file length];
    unsigned int checksum = 0;
    
    for (int i = 0; i < length; i++) {
        checksum += (int)data[i];
    }

    buff[0] = (checksum >> 8) & 0x00ff;
    buff[1] = checksum & 0x00ff;
//    return buff;
}

///**
// * スコアの為のチェックサム計算
// */
//- (double)calcCheckSumForScore:(double)score {
//    double sum = fmod(score, 1);
//    sum = floor((sum) * 10000) / 10000;
//    
//    for (int i = 0; i < 13; i++) {
//        sum = 3.782 * (sum) * (1 - sum);
//        sum = floor(sum * 10000) / 10000;
//    }
//    
//    return sum;
//}

/**
 * URLエンコードして返す
 */
- (NSString *)encodeName:(NSString *)name {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                               NULL, 
                                                               (CFStringRef)name, 
                                                               NULL, 
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8
                                                               ));
}

/**
 * JSONをパースしてNSDictionaryにして返す
 */
- (NSDictionary *)parseJson:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:str];
    return dic;
}

/**
 * 5桁以下を切り下げてNSStringで返す
 */
- (NSString*)floorScoreToString:(float)score_ {
    int tmp = (int)(score_ * 100000);
    float tmpScore = (double)tmp / 100000;
   return [NSString stringWithFormat:@"%.5f", tmpScore];
}

// ==============================================================================================================================
#pragma mark - upload methods
//
//- (BOOL)sendScore:(double)score username:(NSString *)username withData:(NSMutableArray *)array {
//
//    NSAssert(array != nil, @"replay data required");
//    //LOG(@"***** sendScore:1 flag:%f",flag);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"replaytmp.dat"];
//    [array writeToFile:path atomically:YES];
//
//    //self.replayData = [NSKeyedArchiver archivedDataWithRootObject:array];
//    self.replayData = [NSData dataWithContentsOfFile:path];
//    self.username = [self encodeName:username];
//    //self.username = username;
//    self.score = score;
//    self.sum   = [self calcCheckSumForScore:score];
////    NSString *sendingString = [NSString stringWithFormat:@"id=%@", self.uniqueIdentifier];
//
//    NSLog(@"post body :  %@", self.username);
//
//  BOOL flagResendData = NO; // Repost用
//    return [self syncConnectRequest:sendingString flag:(BOOL*)flagResendData]; // Repost用に追加
//}

//----------------------------------------
// Repost Replay Data
//----------------------------------------
//- (BOOL)repostScore:(double)score username:(NSString *)username withData:(NSMutableArray *)array flagResendData:(BOOL*)flagResendData {
//
//  BOOL flag = flagResendData;
//  LOG(@"***** Repost Replat Data flag:%d",flag);
//
//  NSAssert(array != nil, @"replay data required");
//    //LOG(@"***** sendScore:1 flag:%f",flag);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"replaytmp.dat"];
//    [array writeToFile:path atomically:YES];
//
//    //self.replayData = [NSKeyedArchiver archivedDataWithRootObject:array];
//    self.replayData = [NSData dataWithContentsOfFile:path];
//    self.username = [self encodeName:username];
//    //self.username = username;
//    self.score = score;
//    self.sum   = [self calcCheckSumForScore:score];
////    NSString *sendingString = [NSString stringWithFormat:@"id=%@", self.uniqueIdentifier];
//
//    NSLog(@"post body :  %@", self.username);
//
//    return [self syncConnectRequest:sendingString flag:(BOOL*)flagResendData];
//}
//----------------------------------------
//
//- (BOOL)sendScore:(double)score username:(NSString *)username flagResendData:(BOOL*)flagResendData{
//
//  // スコアしか送らないとき
//    //-------------------------------------
//    // 通常PostとRepostとの分岐
//    //-------------------------------------
//    BOOL flag = flagResendData;
//    NSString *str;
//    if(!flag){
//        // 通常処理
//        LOG(@"***** Nomal_Send Only Score:%d",flag);
//        str = kRankingServerAddr;
//    } else {
//        // Repost処理
//        LOG(@"***** Repost Only Score:%d",flag);
//        str = kRankingServerAddr;
//    }
//    //-------------------------------------
//
//    self.username = [self encodeName:username];
//    //self.username = username;
//    self.score = score;
//    self.sum   = [self calcCheckSumForScore:score];
//
////    NSString *sendingString = [NSString stringWithFormat:@"id=%@", self.uniqueIdentifier];
//
//  NSLog(@"%@",sendingString);
//
//    return [self syncConnectRequest:sendingString url:str];
//}

- (BOOL)syncConnectRequest:(NSString *)param flag:(BOOL*)flagResendData{

  LOG(@"ポストまわり作るまでのデバッグ中、とりあえず全部NO返しちゃう");
  return NO;
  
//  
//  //----------------------------------------
//  // Repost用 (flag=1だとRepost)
//    //----------------------------------------
//  BOOL flag = flagResendData;
//  
//  // 通常PostとRepostとの分岐
//  NSString *str;
//  if(!flag){
//    // 通常Post @"%@/con", kReplayServer
//    str = kReplayServerConnectAddr;
//    LOG(@"***** syncConnectRequest:Send_Nomal flag:%d",flag);
//  } else {
//    // Repost
//    str = kReplayServerConnectAddr_Repost; // Repost用
//    LOG(@"***** syncConnectRequest:Repost flag:%d",flag);
//  }
//  //----------------------------------------
//  
//    NSURL *url = [NSURL URLWithString:str]; // 
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    
//    [request setHTTPMethod:@"POST"];
//    NSLog(@"%@",param);
//    NSLog(@"%@",[param dataUsingEncoding:NSUTF8StringEncoding]);
//    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
//    NSError *error = nil;
//    NSURLResponse *response = nil;
//    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    
//    NSDictionary *dic = [self parseJson:receiveData];
//
//    if ([[dic objectForKey:@"status"] isEqualToString:@"success"]) {
//        return YES;
//    } else if ([dic objectForKey:@"session"]) {
//        
//        uint8_t buff[2];
//        [self calcCheckSumForReplayData:self.replayData buffer:buff];
//
//        NSString *sendData = [NSString stringWithFormat:@"%@ %@ %02x%02x %@", self.uniqueIdentifier, [dic objectForKey:@"session"], buff[0], buff[1], kSecretKey];
//        NSLog(@"verifier: %@", sendData);
//        sendData = [sendData sha1];
//        NSLog(@"verifier: %@", sendData);
//        
//        // ファイルの名前をつける
//        NSDate *date = [NSDate date];
//        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//        [fmt setDateFormat:@"yyyyMMddHHmmss"];
//        NSString *dateString = [fmt stringFromDate:date];
//        
//    // upload_Replaydata
//        //[self uploadReplayData:sendData uploadFileName:[NSString stringWithFormat:@"%@%@", self.uniqueIdentifier, dateString] sessionID:[dic objectForKey:@"session"]];
//    
//    // Repostにも対応メソッド flagを追加
//    [self uploadReplayData:sendData uploadFileName:[NSString stringWithFormat:@"%@%@", self.uniqueIdentifier, dateString] sessionID:[dic objectForKey:@"session"] flag:(BOOL*)flagResendData];
//    
//        return YES;
//    }
//    
//    NSLog(@"failed to send score (or udid)");
//    return NO;
}

//
//- (BOOL)syncConnectRequest:(NSString *)param url:(NSString*)url_ {
//
//  LOG(@"ポストまわり作るまでのデバッグ中、とりあえず全部NO返しちゃう");
//  return NO;
//
//  //スコアしか送らないとき リプレイデータ送信時は通らず
//  LOG(@"***** syncConnectRequest　%@ %@",url_,param);
//    NSURL *url = [NSURL URLWithString:kReplayServerConnectAddr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
//    NSError *error = nil;
//    NSURLResponse *response = nil;
//    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//
//    NSDictionary *dic = [self parseJson:receiveData];
//
//    if ([dic objectForKey:@"session"]) {
//        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url_]];
//        [request setPostValue:self.username forKey:@"name"];
//        [request setPostValue:[self floorScoreToString:self.score] forKey:@"time"];
//        [request setPostValue:[NSString stringWithFormat:@"%f",self.sum] forKey:@"sum"];
////        [request setPostValue:self.uniqueIdentifier forKey:@"udid"];
//        [request setPostValue:[dic objectForKey:@"session"] forKey:@"sessionId"];
//        [request setDelegate:self];
//        [request startAsynchronous];
//
//        return YES;
//    }
//
//  NSLog(@"%@",dic);
//
//    NSLog(@"failed to send score (or udid)");
//    return NO;
//}


- (void)uploadReplayData:(NSString *)verifier uploadFileName:(NSString *)uploadFileName sessionID:(NSString*)sessionId_ flag:(BOOL*)flagResendData{
	
	// リプレイデータの送信
    LOG(@"***** uploadReplayData");
	
    // パラメータの準備(string)
    NSArray *stringKeys = [[NSArray alloc] initWithObjects:@"upload", @"verifier", @"uploadFileName", @"time", @"name", @"sum", @"sessionId", nil];
    NSArray *stringValues = [[NSArray alloc] initWithObjects:@"replaydata", verifier, uploadFileName, [self floorScoreToString:self.score], self.username, [NSString stringWithFormat:@"%f", self.sum], sessionId_, nil];
    NSDictionary *stringDict = [[NSDictionary alloc] initWithObjects:stringValues forKeys:stringKeys];
    NSLog(@"%@",stringDict);
    
    // パラメータの準備(binary)
	NSArray *binaryKeys = [[NSArray alloc] initWithObjects:@"data", @"orgName", @"postName", nil];
	NSArray *binaryValues = [[NSArray alloc] initWithObjects:self.replayData, @"replaydata.dat", @"replaydata", nil];
	NSDictionary *binaryDict = [[NSDictionary alloc] initWithObjects:binaryValues forKeys:binaryKeys];
    
	//----------------------------------------
	// Repost用 flag=1だとRepost
	BOOL flag = flagResendData;
	//----------------------------------------
	// 通常PostとRepostとの分岐
	NSString *str;
	if(!flag){
		// 通常Post @"%@/upload", kReplayServer
		str = kReplayServerUploadAddr;
		LOG(@"***** uploadReplayData:Send_Nomal flag:%d",flag);
	} else {
		// Repost
		str = kReplayServerUploadAddr_Repost; // 後でRepost用に修正
		LOG(@"***** uploadReplayData:Repost flag:%d",flag);
	}
	//----------------------------------------
	
	NSArray *binaries = [[NSArray alloc] initWithObjects:binaryDict, nil]; 
    // 準備したパラメータをセット
	postHelper = [[MultipartPostHelper alloc] initWithURL:str];
	[postHelper setBinaryValues:binaries];
	[postHelper setStringValues:stringDict];
    
    
    // 送信
    receivedData = [[NSMutableData alloc] initWithData:[NSData data]];
    [postHelper sendWithDelegate:self];
}

// ==============================================================================================================================
#pragma mark - download methods

- (void)downloadReplayData:(NSString *)name time:(double)time type:(DownloadType)type delegate:(id<ReplayControllerDelegate>)delegate {
    // ダウンロードリプレイデータ
    self.delegate = delegate;

    NSString *param = [NSString stringWithFormat:@"%@?name=%@&time=%.5f&type=%d", kReplayServerDownloadAddr, [self encodeName:name], time, type];
    NSLog(@"%@", param);
    NSURL *url = [NSURL URLWithString:param];        
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:url];

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(finishDownloadingReplayFile:)]) {
        [self.delegate finishDownloadingReplayFile:array];
    }
}

// グラフ描画用にデータを取得
- (NSMutableArray *)replayGraphDataArray:(NSString *)name time:(double)time type:(DownloadType)type tag:(int)tag {
LOG();
	// 引数tagはRanking
	
	NSString *param = [NSString stringWithFormat:@"%@?name=%@&time=%.5f&type=%d", kReplayServerDownloadAddr, [self encodeName:name], time, type];
    NSLog(@"%@", param);
    NSURL *url = [NSURL URLWithString:param];
	
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:url];
	
	
	return array;
}

// ==============================================================================================================================
#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __func__);
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
    NSLog(@"%s", __func__);
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    
    receivedData = nil;
    NSLog(@"Connection failed! Error: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    
  NSLog(@"Succeeded! Received %lu bytes of data", (unsigned long)[receivedData length]);

    NSDictionary *dic = [self parseJson:receivedData];
    if ([[dic objectForKey:@"status"] isEqualToString:@"success"]) {
        NSLog(@"success!");
    } else {
        NSLog(@"error...");
    }
	NSLog(@"***** [dic objectForKey:@status:%@]",[dic objectForKey:@"status"]);

    
    receivedData = nil;
    
    
    postHelper = nil;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - ASIHTTPRequestDelegate methods

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    NSLog(@"response : %@", responseString);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:responseString];
    NSLog(@"status : %@", [dic objectForKey:@"status"]);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@", error);
}

@end
