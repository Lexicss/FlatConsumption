//
//  FCEditViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 10.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCEditViewController.h"

#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 6

@interface FCEditViewController ()
@property (strong, nonatomic) NSSet *fieldsSet;
@property (unsafe_unretained, nonatomic) BOOL shoulSelectDate;
@property (strong, nonatomic) UITextField *focusedField;

@end

@implementation FCEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setShoulSelectDate:NO];
    self.pickerInputView = [[UIDatePicker alloc] init];
    [self.pickerInputView setDatePickerMode:UIDatePickerModeDate];
    
    [self.dateTextField setInputView:self.pickerInputView];
    [self.dateTextField setDelegate:self];
    
    self.fieldsSet = [NSSet setWithObjects:
                      self.hotKitchenTextField,
                      self.coldKitchenTextField,
                      self.hotBathTextField,
                      self.coldBathTextField,
                      self.energyTextField,
                      self.energyFromTextField,
                      self.energyToTextField, nil];
    
    for (UITextField *field in self.fieldsSet) {
        [field setDelegate:self];
        [field setKeyboardType:UIKeyboardTypeNumberPad];
    }
    
    [self.energySwitch addTarget:self
                          action:@selector(valueChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    if (self.monthPayment) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [self setSelectedDate:self.monthPayment.date];
        [self.pickerInputView setDate:self.monthPayment.date];
        self.dateTextField.text = [formatter stringFromDate:self.monthPayment.date];
        self.hotKitchenTextField.text = [self.monthPayment.hotKitchenWaterCount stringValue];
        self.coldKitchenTextField.text = [self.monthPayment.coldKitchenWaterCount stringValue];
        self.hotBathTextField.text = [self.monthPayment.hotBathWaterCount stringValue];
        self.coldBathTextField.text = [self.monthPayment.coldBathWaterCount stringValue];
        self.energyTextField.text = [self.monthPayment.energyCount stringValue];
        [self.energySwitch setOn:[self.monthPayment.energyCountChanged boolValue]];
        if ([self.energySwitch isOn]) {
            self.energyFromTextField.text = [self.monthPayment.energyCountOld stringValue];
            self.energyToTextField.text = [self.monthPayment.energyCountNew stringValue];
        } else {
            [self.energyFromTextField setText:@""];
            [self.energyToTextField setText:@""];
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerTapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.dateTextField) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setFocusedField:textField];
    if (textField == self.dateTextField) {
        [self setShoulSelectDate:YES];
    } else {
        if (self.shoulSelectDate) {
            [self putDate];
        }
    }
}

#pragma mark - Actions

- (void)valueChanged:(UISwitch *)theSwitch {
    [self.energyFromTextField setEnabled:[theSwitch isOn]];
    [self.energyToTextField setEnabled:[theSwitch isOn]];
}

- (void)controllerTapped:(id)sender {
    [self.focusedField resignFirstResponder];
}

- (IBAction)save:(id)sender {
    if (![self areAllFullFilled]) {
        [API showStandartAlertWithName:@"Not all fields completed"
                           description:@"Please fullfill necessary fields"];
        return;
    }
   [self putDate];
    self.monthPayment.date = [self selectedDate];
    self.monthPayment.hotKitchenWaterCount = [NSNumber numberWithInt:[self.hotKitchenTextField.text integerValue]];
    self.monthPayment.coldKitchenWaterCount = [NSNumber numberWithInt:[self.coldKitchenTextField.text integerValue]];
    self.monthPayment.hotBathWaterCount = [NSNumber numberWithInt:[self.hotBathTextField.text integerValue]];
    self.monthPayment.coldBathWaterCount = [NSNumber numberWithInt:[self.coldBathTextField.text integerValue]];
    self.monthPayment.energyCount = [NSNumber numberWithInt:[self.energyTextField.text integerValue]];
    self.monthPayment.energyCountChanged = [NSNumber numberWithBool:[self.energySwitch isOn]];
    if ([self.energySwitch isOn]) {
        self.monthPayment.energyCountOld = [NSNumber numberWithInt:[self.energyFromTextField.text integerValue]];
        self.monthPayment.energyCountNew = [NSNumber numberWithInt:[self.energyToTextField.text integerValue]];
    }
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
    if (saveError) {
        NSLog(@"save error: %@", [saveError localizedDescription]);
        return;
    }
    [self.delegate theSaveButtonOnEditWasTapped:self];
    
}

#pragma mark - Custom

- (void)putDate {
    
    self.selectedDate = [self.pickerInputView date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *initialText = [formatter stringFromDate:self.selectedDate];
    [self.dateTextField setText:initialText];
    [self setShoulSelectDate:NO];
}

- (BOOL)areAllFullFilled {
    if ([self.dateTextField isEmpty])
        return NO;
    for (UITextField *field in self.fieldsSet) {
        if ([field isEmpty]) {
            if (![self.energySwitch isOn] && ((field == self.energyFromTextField) || (field == self.energyToTextField))) {
                continue;
            }
            return NO;
        }
    }
    return YES;
}


@end
