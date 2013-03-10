//
//  FCMonthPaymentTableViewController.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "MonthPayment.h"
#import "API.h"
#import "FCAddViewController.h"
#import "FCCell.h"
#import "FCEditViewController.h"

@interface FCMonthPaymentTableViewController : CoreDataTableViewController <AddMonthPaymentDelegate, EditMonthPaymentDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MonthPayment *selectedMonthPayment;

@end
