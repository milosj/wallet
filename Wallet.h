//
//  Wallet.h
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Wallet : NSManagedObject


@property (readonly, nonatomic) NSDecimalNumber* amount;

@end

NS_ASSUME_NONNULL_END

#import "Wallet+CoreDataProperties.h"
