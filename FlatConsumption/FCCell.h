//
//  FCCell.h
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/5/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@interface FCCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *coldKitchenLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotBathLabel;

@property (strong, nonatomic) IBOutlet UILabel *coldBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *energyLabel;

@end
