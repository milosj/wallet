//
//  WalletDisplayInfo.m
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

@import UIKit;
#import "WalletDisplayDelegate.h"

@implementation WalletDisplayDelegate


+ (UIColor*)colourForWalletType:(NSString*)walletType {
//ideally this would be replaced with lookup json
    if ([walletType isEqualToString:@"personal_spending_account"]) {
        return [UIColor blueColor];
    } else if ([walletType isEqualToString:@"health_spending_account"]) {
        return [UIColor redColor];
    }
    return nil;
}

+ (NSString*)titleForWalletType:(NSString*)walletType {
    if ([walletType isEqualToString:@"personal_spending_account"]) {
        return @"WELLNESS ACCOUNT";
    } else if ([walletType isEqualToString:@"health_spending_account"]) {
        return @"HEALTH ACCOUNT";
    }
    return nil;
}

+ (NSDateFormatter*)humanReadableDateTimeFormatter {
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceMark;
    dispatch_once(&onceMark, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMM dd YYYY";
        NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_ca"];
        dateFormatter.locale = locale;
    });
    return dateFormatter;
}
+ (NSNumberFormatter*)currencyFormatter {
    static NSNumberFormatter* currencyFormatter;
    static dispatch_once_t onceMark;
    dispatch_once(&onceMark, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_ca"];
        currencyFormatter.locale = locale;
    });
    return currencyFormatter;
}

@end
