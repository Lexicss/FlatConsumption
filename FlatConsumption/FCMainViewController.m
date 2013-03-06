//
//  FCMainViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMainViewController.h"

@interface FCMainViewController ()

@end

@implementation FCMainViewController

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
	NSLog(@"We have %d objects", [API monthPayments].count);
    NSArray *payments = [API monthPayments];
    
    self.hotKitchenLabel.text = [self textForKey:@"hotKitchenWaterCount" withArray:payments];
    self.coldKitchenLabel.text = [self textForKey:@"coldKitchenWaterCount" withArray:payments];
    self.hotBathLabel.text = [self textForKey:@"hotBathWaterCount" withArray:payments];
    self.coldBathLabel.text = [self textForKey:@"coldBathWaterCount" withArray:payments];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Im nain are %d objects", [[API monthPayments] count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)indexOfMaxConsumptionForKey:(NSString *)key withArray:(NSArray *)array {
    
    //find the maximum hot Kitchen
    NSInteger maxHotDelta = 0;
    NSInteger index = 0;
    for (NSInteger i = 1; i < [array count]; i++) {
        NSInteger delta = [self deltaForKey:key withIndex:i inArray:array];
        if (delta > maxHotDelta) {
            index = i;
            maxHotDelta = delta;
        }
    }
    return index;
}

- (NSInteger)deltaForKey:(NSString *)key withIndex:(NSInteger)index inArray:(NSArray *)array {
    MonthPayment *previousPayment = array[index-1];
    MonthPayment *currentPayment = array[index];
    NSInteger curValue = [[currentPayment valueForKey:key] integerValue];
    NSInteger prevValue = [[previousPayment valueForKey:key] integerValue];
    return curValue - prevValue;
}

- (NSString *)textForKey:(NSString *)key withArray:(NSArray *)array {
    NSInteger index = [self indexOfMaxConsumptionForKey:key withArray:array];
    NSString *resultText;
    if (index > 0) {
        MonthPayment *prev = array[index - 1];
        MonthPayment *cur = array[index];
        NSInteger delta = [self deltaForKey:key withIndex:index inArray:array];
        resultText = [NSString stringWithFormat:@"From %@ to %@ - %d", [self stringFromDate:prev.date], [self stringFromDate:cur.date], delta];
    } else {
        resultText = @"";
    }
    
    return resultText;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateComponents *components = [API sharedComponentsForDate:date];
    return [NSString stringWithFormat:@"%d.%d.%d", components.day, components.month, components.year];
}

@end
