//
//  DataViewController.m
//  LeagueWallet
//
//  Created by Milos Jovanovic on 2016-05-13.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "DataViewController.h"
#import "Wallet.h"
#import "WalletDisplayDelegate.h"

@interface DataViewController ()

@property (weak, nonatomic) IBOutlet UILabel *accountType;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UIView *cardView;


@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.cardView.layer.cornerRadius = 25.0f;
    self.cardView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.cardView.layer.borderWidth = 1.0f;
    if (self.dataObject) {
        [self updateWithData:self.dataObject];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

- (void)updateWithData:(Wallet*)data {
    if (self.isViewLoaded) {
        self.accountType.text = [WalletDisplayDelegate titleForWalletType:data.walletType];
        self.cardView.backgroundColor = [WalletDisplayDelegate colourForWalletType:data.walletType];
        self.balance.text = [[WalletDisplayDelegate currencyFormatter] stringFromNumber:data.amount];
        self.startDate.text = [[WalletDisplayDelegate humanReadableDateTimeFormatter] stringFromDate:data.policyStartDate];
        self.endDate.text = [[WalletDisplayDelegate humanReadableDateTimeFormatter] stringFromDate:data.policyEndDate];
        
        
    }
}

- (void)setDataObject:(Wallet *)dataObject {
    _dataObject = dataObject;
    [self updateWithData:self.dataObject];
}


@end
