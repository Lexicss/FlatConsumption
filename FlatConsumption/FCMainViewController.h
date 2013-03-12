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

@interface FCMainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *hotKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldBathLabel;
@property (strong, nonatomic) IBOutlet UIButton *listButton;
- (IBAction)listButtonClicked:(id)sender;
@end
