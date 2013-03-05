//
//  FCAddViewController.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthPayment.h"
#import "API.h"

@class FCAddViewController;
@protocol AddMonthPaymentDelegate <NSObject>

- (void)theSaveButtonOnAddWasTapped:(FCAddViewController *)controller;

@end

@interface FCAddViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) UIDatePicker *pickerInputView;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UITextField *hotKichenTextField;
@property (weak, nonatomic) IBOutlet UITextField *coldKitchenTextField;
@property (weak, nonatomic) IBOutlet UITextField *hotBathTextField;
@property (weak, nonatomic) IBOutlet UITextField *coldBathTextField;
@property (strong, nonatomic) IBOutlet UITextField *energyTextField;
@property (strong, nonatomic) IBOutlet UISwitch *energySwitch;
@property (strong, nonatomic) IBOutlet UITextField *energyFromTextField;
@property (strong, nonatomic) IBOutlet UITextField *energyToTextField;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (unsafe_unretained, nonatomic) id <AddMonthPaymentDelegate> delegate;
@property (strong, nonatomic) MonthPayment *lastMonthPayment;
@property (strong, nonatomic) IBOutlet UILabel *lastDate;
@property (strong, nonatomic) IBOutlet UILabel *lastHotKichenLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastColdKichenLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastHotBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastColdBathLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastEnergyLabel;

- (IBAction)save:(id)sender;
@end
