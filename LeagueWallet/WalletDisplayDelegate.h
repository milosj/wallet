//
//  WalletDisplayInfo.h
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletDisplayDelegate : NSObject

+ (UIColor*)colourForWalletType:(NSString*)walletType;
+ (NSString*)titleForWalletType:(NSString*)walletType;
+ (NSDateFormatter*)humanReadableDateTimeFormatter;
+ (NSNumberFormatter*)currencyFormatter;

@end
