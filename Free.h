/*
 *  Free.h
 *  TouchNumber
 *
 *  Created by 鈴木 健太郎 on 10/02/01.
 *  Copyright 2010 （株）テクノード. All rights reserved.
 *
 */
//------------------------------------------------------------------------------
//	UPDATE	:	12/10/18	Yoichi Onodera		テスト用のADWHIRL_KEY_TOP、ADWHIRL_KEY_MAINを追加
//				12/12/21	Yoichi Onodera		AdWhirl関連定義削除
//				YY/MM/DD	Name				Comment
//

//------------------------------------------------------------------------------
#define FREE_VERSION		// 定義されていれば無料。さもなければ有料
// 有料にする場合は、GameCenter group_leaderIDを書き換える(TouchNumber_Prefix.pch)
//#define ALPHABET_ON		//定義されていれば、アルファベットモードに。
//------------------------------------------------------------------------------


#ifdef FREE_VERSION
#define FREE_FLAG	1
#else
#define FREE_FLAG	0
#endif


#ifdef ALPHABET_ON

#define ALPHABET_FLAG				1
#define TWITTER_CONSUMER_KEY		@"Wzmhyyq7FMEsUYHT6qjwA"
#define TWITTER_CONSUMER_SECRET		@"AYB3KZcBhWrP2VIKy5sAFZWFiTxnYeNLhGYDc9WPnk"
#define TWITTER_MESSAGE				@"Touch the Alphabets : %@ sets a personal best time of %3.3f sec!! #TtA26 -- http://bit.ly/ttA26"

#else

#define ALPHABET_FLAG		0

#define TWITTER_CONSUMER_KEY		@"Hl7PX1Z21gnY0g53nHvleg"
#define TWITTER_CONSUMER_SECRET		@"IPhDnebiRR0l8VpCUUvMgXiGVEi5n4FIM8wv8TPQQ8"
#define TWITTER_MESSAGE				@"Touch the Numbers : %@ sets a personal best time of %3.3f sec!! #TtN25 -- http://bit.ly/ttnrank"
#define TWITTER_MESSAGE2			@"Touch the Numbers : %@ : %@ sets a personal best time of %3.3f sec!! #TtN25 -- http://bit.ly/ttnrank"

#endif