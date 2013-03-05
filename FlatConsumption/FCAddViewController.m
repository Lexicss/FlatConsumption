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


@end

@implementation FCAddViewController
@synthesize pickerInputView = _pickerInputView;
@synthesize selectedDate = _selectedDate;

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
	// Do any additional setup after loading the view.
    self.pickerInputView = [[UIDatePicker alloc] init];
    [self.pickerInputView setDatePickerMode:UIDatePickerModeDate];
    
    [self.dateTextField setInputView:self.pickerInputView];
    [self.dateTextField setDelegate:self];
    [self.hotKichenTextField setDelegate:self];
    [self.hotKichenTextField setKeyboardType:UIKeyboardTypeNumberPad];
    
    self.fieldsSet = [NSSet setWithObjects:self.dateTextField, self.hotKichenTextField, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([self.dateTextField isFirstResponder] && ![self.fieldsSet containsObject:[touch view]]) {
        [self.dateTextField resignFirstResponder];
        
        self.selectedDate = [self.pickerInputView date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateTextField setText:[formatter stringFromDate:self.selectedDate]];
    }
    
    if ([self.hotKichenTextField isFirstResponder] && [touch view] != self.hotKichenTextField ) {
        [self.hotKichenTextField resignFirstResponder];
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

@end
