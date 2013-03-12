//
//  FCMainViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMainViewController.h"

static const BOOL kIncludeCurrentYear = YES;

@interface FCMainViewController ()
@property(strong, nonatomic) NSArray *fullArray;

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
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Im nain are %d objects", [[API monthPayments] count]);
    NSArray *payments = [API monthPayments];
    
    self.hotKitchenLabel.text = [self textForKey:@"hotKitchenWaterCount" withArray:payments];
    self.coldKitchenLabel.text = [self textForKey:@"coldKitchenWaterCount" withArray:payments];
    self.hotBathLabel.text = [self textForKey:@"hotBathWaterCount" withArray:payments];
    self.coldBathLabel.text = [self textForKey:@"coldBathWaterCount" withArray:payments];
    self.energyLabel.text = [self textForKey:@"energyCount" withArray:payments];
    
    NSArray *hotKitchenArray = [self calcAnnualForKey:@"hotKitchenWaterCount"];
    NSArray *coldKitchenArray = [self calcAnnualForKey:@"coldKitchenWaterCount"];
    NSArray *hotBathArray = [self calcAnnualForKey:@"hotBathWaterCount"];
    NSArray *coldBathArray = [self calcAnnualForKey:@"coldBathWaterCount"];
    
    NSArray *energyArray = [self calcAnnualForKey:@"energyCount"];
    
    NSArray *allArray = @[hotKitchenArray, coldKitchenArray, hotBathArray, coldBathArray, energyArray];
    [self setFullArray:allArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSArray *)calcAnnualForKey:(NSString *)key {
    NSArray *workArray;
    if (IsAscending) {
        workArray = [API monthPayments];
    } else {
        workArray = [[API monthPayments] reverseArray];
    }
    
    MonthPayment *thePayment = [workArray objectAtIndex:0];
    NSInteger tempAmount = 0;
    NSInteger startYear = [self yearAtIndex:0 inArray:workArray];
    NSInteger startValue = [[thePayment valueForKey:key] integerValue];
    NSInteger currentValue = startValue;
    NSMutableArray *yearArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < [workArray count]; i++) {
        NSInteger currentYear = [self yearAtIndex:i inArray:workArray];

        if ([key isEqualToString:@"energyCount"]) {
            thePayment = [workArray objectAtIndex:i];
            if ([thePayment.energyCount boolValue]) {
                tempAmount += [thePayment.energyCountOld integerValue] - startValue;
                startValue = [thePayment.energyCountNew integerValue];
            }
        }

        BOOL includeCurrentYear = kIncludeCurrentYear && i == workArray.count - 1;
        if (currentYear > startYear || includeCurrentYear) {
            MonthPayment *thisPayment = [workArray objectAtIndex:i];
            currentValue = [[thisPayment valueForKey:key] integerValue] - startValue + tempAmount;
            NSLog(@"For %d the amount %@ consists of = %d%@", startYear, key,currentValue,includeCurrentYear?@"(not completed)":@"");
            FCStat *stat = [[FCStat alloc] initWithYear:startYear withValue:currentValue withKey:key];
            [yearArray addObject:stat];
            startYear = currentYear;
            startValue = [[thisPayment valueForKey:key] integerValue];
            tempAmount = 0;
        }
    }
    NSLog(@"--------");
    return yearArray;
}


- (NSInteger)yearAtIndex:(NSInteger)index inArray:(NSArray *)array {
    if (index < 0 || index > [array count] - 1)
        return -1;
    MonthPayment *mp = [array objectAtIndex:index];
    NSDateComponents *components = [API sharedComponentsForDate:mp.date];
    return [components year];
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
    MonthPayment *previousPayment; //= array[index-1];
    MonthPayment *currentPayment; //= array[index];
    
    if (IsAscending) {
        previousPayment = array[index - 1];
        currentPayment = array[index];
    } else {
        previousPayment = array[index];
        currentPayment = array[index - 1];
    }
    
    NSInteger curValue = [[currentPayment valueForKey:key] integerValue];
    NSInteger prevValue = [[previousPayment valueForKey:key] integerValue];
    return curValue - prevValue;
}

- (NSString *)textForKey:(NSString *)key withArray:(NSArray *)array {
    NSInteger index = [self indexOfMaxConsumptionForKey:key withArray:array];
    NSString *resultText;
    if (index > 0) {
        MonthPayment *prev; //= array[index - 1];
        MonthPayment *cur; //= array[index];
        if (IsAscending) {
            prev = array[index - 1];
            cur = array[index];
        } else {
            prev = array[index];
            cur = array[index - 1];
        }
        
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

- (IBAction)listButtonClicked:(id)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"Stat Segue"]) {
        FCStatTableViewController *statTVC = segue.destinationViewController;
        [statTVC setStatArray:self.fullArray];
    }
}

@end
