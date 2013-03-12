//
//  FCMainViewController.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "MonthPayment.h"
#import "FCStatTableViewController.h"
#import "NSArray+Reverse.h"

@interface FCMainViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *hotKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldBathLabel;
@property (strong, nonatomic) IBOutlet UIButton *listButton;
@property (strong, nonatomic) IBOutlet UILabel *energyLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)listButtonClicked:(id)sender;
@end
