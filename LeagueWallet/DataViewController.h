//
//  DataViewController.h
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Wallet;

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) Wallet* dataObject;

@end

