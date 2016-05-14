//
//  WalletManager.h
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Wallet;

@interface WalletManager : NSObject

+ (void)walletDataWithCompletionBlock:(nullable void (^) (NSArray<Wallet*>* _Nullable results))completionHandler;
+ (NSArray<Wallet*>*)wallets;

@end
