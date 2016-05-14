//
//  Wallet.m
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "Wallet.h"

@implementation Wallet

@synthesize amount;

// Insert code here to add functionality to your managed object subclass


- (NSDecimalNumber*)amount {
    return [NSDecimalNumber decimalNumberWithString:self.amountString];
}

@end
