//
//  FCStatTableViewController.h
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/11/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthPayment.h"
#import "FCStat.h"

@interface FCStatTableViewController : UITableViewController {
    NSArray *statArray_;
}
@property(strong, nonatomic) NSArray *statArray;

@end
