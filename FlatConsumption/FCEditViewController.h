//
//  FCEditViewController.h
//  FlatConsumption
//
//  Created by Lexicss on 10.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthPayment.h"
#import "API.h"
#import "UITextField+UIFieldAttr.h"

@class FCEditViewController;
@protocol EditMonthPaymentDelegate <NSObject>

- (void)theSaveButtonOnEditWasTapped:(FCEditViewController *)controller;

@end

@interface FCEditViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UITextField *hotKitchenTextField;
@property (strong, nonatomic) IBOutlet UITextField *coldKitchenTextField;
@property (strong, nonatomic) IBOutlet UITextField *hotBathTextField;
@property (strong, nonatomic) IBOutlet UITextField *coldBathTextField;
@property (strong, nonatomic) IBOutlet UISwitch *energySwitch;
@property (strong, nonatomic) IBOutlet UITextField *energyFromTextField;
@property (strong, nonatomic) IBOutlet UITextField *energyToTextField;
@property (strong, nonatomic) UIDatePicker *pickerInputView;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) IBOutlet UITextField *energyTextField;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (unsafe_unretained, nonatomic) id <EditMonthPaymentDelegate> delegate;
@property (strong, nonatomic) MonthPayment *monthPayment;

- (IBAction)save:(id)sender;
@end
