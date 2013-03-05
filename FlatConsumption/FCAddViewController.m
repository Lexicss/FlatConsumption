//
//  FCAddViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCAddViewController.h"

#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 3

@interface FCAddViewController ()
@property (strong, nonatomic) NSSet *fieldsSet;
@property (unsafe_unretained, nonatomic) BOOL shoulSelectDate;


@end

@implementation FCAddViewController
@synthesize pickerInputView = _pickerInputView;
@synthesize selectedDate = _selectedDate;
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setShoulSelectDate:NO];
    self.pickerInputView = [[UIDatePicker alloc] init];
    [self.pickerInputView setDatePickerMode:UIDatePickerModeDate];
    
    [self.dateTextField setInputView:self.pickerInputView];
    [self.dateTextField setDelegate:self];
    
    self.fieldsSet = [NSSet setWithObjects:
                      self.hotKichenTextField,
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([self.dateTextField isFirstResponder] && [touch view] != self.dateTextField) {
        [self.dateTextField resignFirstResponder];
        [self putDate];
    }
    
    for (UITextField *field in self.fieldsSet) {
        if ([field isFirstResponder] && [touch view] != field) {
            [field resignFirstResponder];
            break;
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Textfield Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == self.dateTextField) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
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

- (IBAction)save:(id)sender {
    
    if (![self areAllFullFilled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not all fields completed"
                                                        message:@"Please fullfill necessary fields"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MonthPayment *monthPayment = [NSEntityDescription insertNewObjectForEntityForName:[API entityName]
                                                               inManagedObjectContext:self.managedObjectContext];
    monthPayment.date = [self.pickerInputView date];
    monthPayment.hotKichenWaterCount = [NSNumber numberWithInt:[[self.hotKichenTextField text] integerValue]];
    monthPayment.coldKitchenWaterCount = [NSNumber numberWithInt:[[self.coldKitchenTextField text] integerValue]];
    
    monthPayment.hotBathWaterCount = [NSNumber numberWithInt:[[self.hotBathTextField text] integerValue]];
    monthPayment.coldBathWaterCount = [NSNumber numberWithInt:[[self.coldBathTextField text] integerValue]];
    
    monthPayment.energyCount = [NSNumber numberWithInt:[[self.energyTextField text] integerValue]];
    monthPayment.energyCountChanged = [NSNumber numberWithBool:[self.energySwitch isOn]];
    
    if ([self.energySwitch isOn]) {
        monthPayment.energyCountOld = [NSNumber numberWithInt:[[self.energyFromTextField text] integerValue]];
        monthPayment.energyCountNew = [NSNumber numberWithInt:[[self.energyToTextField text] integerValue]];
    }
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
    
    if (saveError) {
        NSLog(@"save error: %@", [saveError localizedDescription]);
        return;
    }
    
    [self.delegate theSaveButtonOnAddWasTapped:self];
}

#pragma mark - Custom

- (void)putDate {
    self.selectedDate = [self.pickerInputView date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateTextField setText:[formatter stringFromDate:self.selectedDate]];
    [self setShoulSelectDate:NO];
}

- (BOOL)areAllFullFilled {
    if ([self.dateTextField.text isEqualToString:@""])
        return NO;
    for (UITextField *field in self.fieldsSet) {
        if ([field.text isEqualToString:@""]) {
            if (![self.energySwitch isOn] && ((field == self.energyFromTextField) || (field == self.energyToTextField))) {
                continue;
            }
            return NO;
        }
    }
    return YES;
}

@end
