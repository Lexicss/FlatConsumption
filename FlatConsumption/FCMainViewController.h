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

@interface FCMainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *hotKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldBathLabel;
@end
