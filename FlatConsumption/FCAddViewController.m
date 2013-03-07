//
//  FCAddViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCAddViewController.h"

#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 6
#define LAST @"last %@"

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216 + 64;

@interface FCAddViewController ()
@property (strong, nonatomic) NSSet *fieldsSet;
@property (unsafe_unretained, nonatomic) BOOL shoulSelectDate;
@property (strong, nonatomic) UITextField *focusedField;


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
    
    if (self.lastMonthPayment) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        self.lastDate.text = [NSString stringWithFormat:LAST, [formatter stringFromDate:self.lastMonthPayment.date]];
        self.lastHotKichenLabel.text = [NSString stringWithFormat:LAST, self.lastMonthPayment.hotKitchenWaterCount];
        self.lastColdKichenLabel.text = [NSString stringWithFormat:LAST, self.lastMonthPayment.coldKitchenWaterCount];
        self.lastHotBathLabel.text = [NSString stringWithFormat:LAST, self.lastMonthPayment.hotBathWaterCount];
        self.lastColdBathLabel.text = [NSString stringWithFormat:LAST, self.lastMonthPayment.coldBathWaterCount];
        self.lastEnergyLabel.text = [NSString stringWithFormat:LAST, self.lastMonthPayment.energyCount];
    }
    self.scrollView.delegate = self;
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
            [self calcDeltaForField:field];
            break;
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.focusedField resignFirstResponder];
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
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    CGFloat overlap = textField.frame.origin.y + textField.frame.size.height + PORTRAIT_KEYBOARD_HEIGHT - fullScreen.size.height;
    if (overlap > 0) {
        [self.scrollView setContentOffset:CGPointMake(0, overlap)];
    } else {
        [self.scrollView setContentOffset:CGPointZero];
    }
    
    if (textField == self.dateTextField) {
        [self setShoulSelectDate:YES];
    } else {
        if (self.shoulSelectDate) {
            [self putDate];
        }
    }
    self.focusedField = textField;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([self.fieldsSet containsObject:textField] && ![textField isEmpty]) {
        [self calcDeltaForField:textField];
    }
}


#pragma mark - Actions

- (void)valueChanged:(UISwitch *)theSwitch {
    [self.energyFromTextField setEnabled:[theSwitch isOn]];
    [self.energyToTextField setEnabled:[theSwitch isOn]];
}

- (IBAction)save:(id)sender {
    
    if (![self areAllFullFilled]) {
        [API showStandartAlertWithName:@"Not all fields completed"
                           description:@"Please fullfill necessary fields"];
        return;
    }
    
    MonthPayment *monthPayment = [NSEntityDescription insertNewObjectForEntityForName:[API entityName]
                                                               inManagedObjectContext:self.managedObjectContext];
    monthPayment.date = [self.pickerInputView date];
    monthPayment.hotKitchenWaterCount = [NSNumber numberWithInt:[[self.hotKitchenTextField text] integerValue]];
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
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:self.lastMonthPayment.date toDate:self.pickerInputView.date options:0];
    if ([components day] == 0) {
        [API showStandartAlertWithName:@"Wrong date" description:@"You chose the same last date"];
        return;
    } else if ([components day] < 0) {
        [API showStandartAlertWithName:@"Wrong date" description:@"You chose previous date then last"];
        return;
    }
    
    self.selectedDate = [self.pickerInputView date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *initialText = [formatter stringFromDate:self.selectedDate];
    [self.dateTextField setText:initialText];
    [self setShoulSelectDate:NO];
    
    initialText = [formatter stringFromDate:self.lastMonthPayment.date];
    [self.lastDate setText:[NSString stringWithFormat:@"%@ (%d days)",initialText,[components day]]];
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

- (void)calcDeltaForField:(UITextField *)field {
    if ([field isEmpty]) {
        return;
    }
    NSString *initialText;
    if ([field isEqual:self.hotKitchenTextField]) {
        initialText = [NSString stringWithFormat:LAST, self.lastMonthPayment.hotKitchenWaterCount];
        NSInteger last = [self.lastMonthPayment.hotKitchenWaterCount integerValue];
        NSInteger current = [[self.hotKitchenTextField text] integerValue];
        self.lastHotKichenLabel.text = [NSString stringWithFormat:@"%@ (%d)",initialText, (current - last)];
    } else if ([field isEqual:self.coldKitchenTextField]) {
        initialText = [NSString stringWithFormat:LAST, self.lastMonthPayment.coldKitchenWaterCount];
        NSInteger last = [self.lastMonthPayment.coldKitchenWaterCount integerValue];
        NSInteger current = [[self.coldKitchenTextField text] integerValue];
        self.lastColdKichenLabel.text = [NSString stringWithFormat:@"%@ (%d)",initialText, (current - last)];
    } else if ([field isEqual:self.hotBathTextField]) {
        initialText = [NSString stringWithFormat:LAST, self.lastMonthPayment.hotBathWaterCount];
        NSInteger last = [self.lastMonthPayment.hotBathWaterCount integerValue];
        NSInteger current = [[self.hotBathTextField text] integerValue];
        self.lastHotBathLabel.text = [NSString stringWithFormat:@"%@ (%d)",initialText, (current - last)];
    } else if ([field isEqual:self.coldBathTextField]) {
        initialText = [NSString stringWithFormat:LAST, self.lastMonthPayment.coldBathWaterCount];
        NSInteger last = [self.lastMonthPayment.coldBathWaterCount integerValue];
        NSInteger current = [[self.coldBathTextField text] integerValue];
        self.lastColdBathLabel.text = [NSString stringWithFormat:@"%@ (%d)",initialText, (current - last)];
    } else if ([field isEqual:self.energyTextField]) {
        initialText = [NSString stringWithFormat:LAST, self.lastMonthPayment.energyCount];
        NSInteger last = [self.lastMonthPayment.energyCount integerValue];
        NSInteger current = [[self.energyTextField text] integerValue];
        self.lastEnergyLabel.text = [NSString stringWithFormat:@"%@ (%d)",initialText, (current - last)];
    }
}

@end
