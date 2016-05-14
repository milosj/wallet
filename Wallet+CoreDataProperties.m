//
//  Wallet+CoreDataProperties.m
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Wallet+CoreDataProperties.h"

@implementation Wallet (CoreDataProperties)

@dynamic walletID;
@dynamic walletType;
@dynamic amountString;
@dynamic amount;
@dynamic currency;
@dynamic policyEndDate;
@dynamic policyStartDate;
@dynamic order;

@end
