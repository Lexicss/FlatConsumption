//
//  FCAddViewController.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCAddViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) UIDatePicker *pickerInputView;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UITextField *hotKichenTextField;
@property (weak, nonatomic) IBOutlet UITextField *coldKitchenTextField;
@property (weak, nonatomic) IBOutlet UITextField *hotBathTextField;
@property (weak, nonatomic) IBOutlet UITextField *coldBathTextField;

@end
