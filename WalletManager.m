//
//  WalletManager.m
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "WalletManager.h"
#import "CoreDataUtils.h"
#import "Wallet.h"

#define kWalletEndPointUrlString @"https://gist.githubusercontent.com/Shanjeef/3562ebc5ea794a945f723de71de1c3ed/raw/25da03b403ffa860dd68a9bfc84f562262ee5ca5/walletEndpoint"
#define kMaxRetries 5
#define kWalletEntity @"Wallet"

@implementation WalletManager

+ (void)walletDataWithCompletionBlock:(nullable void (^) (NSArray<Wallet*>* _Nullable results))completionHandler {
    static int retryCount;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retryCount = 0;
    });
    
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:kWalletEndPointUrlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL retry = YES;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSInteger statusCode = [httpResponse statusCode];
            
            if (statusCode != 200) {
                NSLog(@"downloadStreamItemsForFeed HTTP status code: %ld", (long)statusCode);
            }
        }
        
        
        if (!error) {
            if (data) {
                NSError* err;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                
                if (json && !err) {
                    retry = NO;
                    retryCount = 0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [WalletManager parseWalletData:json];
                        completionHandler([WalletManager wallets]);
                    });
                } else {
                    NSLog(@"Error %@", err);
                }
            } else {
                NSLog(@"Error %@", error);
            }
        }
        
        if (retry && retryCount < kMaxRetries) {
            retryCount++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WalletManager walletDataWithCompletionBlock:completionHandler];
            });
        } else {
            //handle no data case
            completionHandler(nil);
        }
        
        
    }];
    
    [WalletManager deleteWalletsInContext:[CoreDataUtils managedObjectContext]];
    [dataTask resume];
}

+ (void)parseWalletData:(NSDictionary* _Nonnull)walletData {
    
    NSManagedObjectContext *context = [CoreDataUtils managedObjectContext];
    
    NSArray* allWallets = ((NSDictionary*)walletData[@"info"])[@"cards"];
    int index = 0;
    for (NSDictionary* singleWalletJsonData in allWallets) {
        @try {
            Wallet* wallet = [WalletManager walletFromData:singleWalletJsonData inContext:context];
            if (wallet) {
                wallet.order = [NSNumber numberWithInt:index];
            }
            index++;
        } @catch (NSException* ex) {
            
        }
    }
    [CoreDataUtils saveContext:context];

}

+ (Wallet*)walletFromData:(NSDictionary* _Nonnull)jsonData inContext:(NSManagedObjectContext* _Nonnull)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kWalletEntity inManagedObjectContext:context];
    Wallet* wallet = [[Wallet alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    NSNumber* walletId = jsonData[@"id"];
    if (walletId) {
        
        wallet.walletID = walletId;
        
        //shouldn't really be passed around as a generic
        NSNumber* amountNumber = jsonData[@"amount"];
        
        NSString* amountString = [amountNumber stringValue];
        NSString* walletType = jsonData[@"type"];
        NSString* currency = jsonData[@"currency"];
        NSString* policyStartDateString = jsonData[@"policy_start_date"];
        NSString* policyEndDateString = jsonData[@"policy_end_date"];
        
        @try {
        
            wallet.amountString = amountString;
            wallet.walletType = walletType;
            wallet.currency = currency;
            wallet.policyStartDate = [[WalletManager sharedDateTimeFormatter] dateFromString:policyStartDateString];
            wallet.policyEndDate = [[WalletManager sharedDateTimeFormatter] dateFromString:policyEndDateString];
            
        } @catch (NSException* ex) {
            return nil;
        } @finally {
            return wallet;
        }
    }
    return nil;
}

+ (NSDateFormatter*)sharedDateTimeFormatter {
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceMark;
    dispatch_once(&onceMark, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_ca"];
        dateFormatter.locale = locale;
    });
    return dateFormatter;
}

+ (NSFetchedResultsController*)walletsWithTypes:(NSArray<NSString*>* _Nonnull)walletTypes inContext:(NSManagedObjectContext* _Nonnull)context {
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kWalletEntity];
    NSSortDescriptor *typeSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES selector:nil];
    request.sortDescriptors = @[typeSort];

    NSMutableArray* predicates = [NSMutableArray new];
    for (NSString* walletType in walletTypes) {
        NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"walletType == %@", walletType];
        [predicates addObject:typePredicate];
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: predicates];
    request.predicate = compoundPredicate;
    
    NSFetchedResultsController *contrller =  [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    return contrller;
}

+ (NSArray<Wallet*>*)wallets {
    
    NSFetchedResultsController* controller = [WalletManager walletsWithTypes:@[@"health_spending_account", @"personal_spending_account"] inContext:[CoreDataUtils managedObjectContext]];
    NSError* error;
    if ([controller performFetch:&error]) {
        if (error) {
            return  nil;
        } else {
            return controller.fetchedObjects;
        }
    }
    return nil;
}

+ (void)deleteWalletsInContext:(NSManagedObjectContext*)context
{
    
    NSFetchRequest *allWallets = [[NSFetchRequest alloc] init];
    [allWallets setEntity:[NSEntityDescription entityForName:kWalletEntity inManagedObjectContext:context]];
    
    
    NSError *error = nil;
    NSArray *wallets= [context executeFetchRequest:allWallets error:&error];
    
    //error handling goes here
    for (NSManagedObject *wallet in wallets) {
        [context deleteObject:wallet];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}

@end
