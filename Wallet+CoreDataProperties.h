//
//  Wallet+CoreDataProperties.h
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Wallet.h"

NS_ASSUME_NONNULL_BEGIN

@interface Wallet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *walletID;
@property (nullable, nonatomic, retain) NSString *walletType;
@property (nullable, nonatomic, retain) NSString *amountString;
@property (nullable, nonatomic, retain) id amount;
@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSDate *policyEndDate;
@property (nullable, nonatomic, retain) NSDate *policyStartDate;

@end

NS_ASSUME_NONNULL_END
