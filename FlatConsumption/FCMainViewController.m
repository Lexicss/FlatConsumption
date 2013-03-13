//
//  FCMainViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMainViewController.h"

static const BOOL kIncludeCurrentYear = NO;

@interface FCMainViewController ()
@property(strong, nonatomic) NSArray *fullArray;

@property(strong, nonatomic) NSArray *hotKitchenIndexes;
@property(strong, nonatomic) NSArray *coldKitchenIndexes;
@property(strong, nonatomic) NSArray *hotBathIndexes;
@property(strong, nonatomic) NSArray *coldBathIndexes;
@property(strong, nonatomic) NSArray *energyIndexes;

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

    self.hotKitchenIndexes = [self indexesOfMaxConsumptionForKey:@"hotKitchenWaterCount" withArray:payments];
    self.coldKitchenIndexes = [self indexesOfMaxConsumptionForKey:@"coldKitchenWaterCount" withArray:payments];
    self.hotBathIndexes = [self indexesOfMaxConsumptionForKey:@"hotBathWaterCount" withArray:payments];
    self.coldBathIndexes = [self indexesOfMaxConsumptionForKey:@"coldBathWaterCount" withArray:payments];
    self.energyIndexes = [self indexesOfMaxConsumptionForKey:@"energyCount" withArray:payments];
    
    NSArray *hotKitchenArray = [self calcAnnualForKey:@"hotKitchenWaterCount"];
    NSArray *coldKitchenArray = [self calcAnnualForKey:@"coldKitchenWaterCount"];
    NSArray *hotBathArray = [self calcAnnualForKey:@"hotBathWaterCount"];
    NSArray *coldBathArray = [self calcAnnualForKey:@"coldBathWaterCount"];
    
    NSArray *energyArray = [self calcAnnualForKey:@"energyCount"];
    
    NSArray *allArray = @[hotKitchenArray, coldKitchenArray, hotBathArray, coldBathArray, energyArray];
    [self setFullArray:allArray];
    
    [self.tableView setDataSource:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.tableView setDataSource:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)keyOfIndexesNum:(NSInteger)num {
    switch (num) {
        case 0:
            return @"hotKitchenIndexes";
        case 1:
            return @"coldKitchenIndexes";
        case 2:
            return @"hotBathIndexes";
        case 3:
            return @"coldBathIndexes";
        case 4:
            return @"energyIndexes";
            
        default:
            return @"";
    }
}

- (NSString *)keyOfWaterCountNum:(NSInteger)num {
    switch (num) {
        case 0:
            return @"hotKitchenWaterCount";
        case 1:
            return @"coldKitchenWaterCount";
        case 2:
            return @"hotBathWaterCount";
        case 3:
            return @"coldBathWaterCount";
        case 4:
            return @"energyCount";
            
        default:
            return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyOfIndexesNum:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self keyOfIndexesNum:section];
    return [[self valueForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Hot Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *waterCountKey = [self keyOfWaterCountNum:indexPath.section];
    NSString *indexKey = [self keyOfIndexesNum:indexPath.section];
    NSArray *indexArray = [self valueForKey:indexKey];
    NSInteger index = [((NSNumber *)indexArray[indexPath.row]) integerValue];
    NSString *dateText = [self textForKey:waterCountKey withArray:[API monthPayments] andIndex:index];
    cell.textLabel.text = dateText;
    
    return cell;
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

- (NSArray *)indexesOfMaxConsumptionForKey:(NSString *)key withArray:(NSArray *)array {
    NSInteger maxHotDelta = 0;
    //NSInteger index = 0;
    NSMutableArray *maxIndexesArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 1; i < [array count]; i++) {
        NSInteger delta = [self deltaForKey:key withIndex:i inArray:array];
        if (delta == maxHotDelta) {
            //index = i;
            [maxIndexesArray addObject:[NSNumber numberWithInt:i]];
        } else if (delta > maxHotDelta) {
            //index = i;
            [maxIndexesArray removeAllObjects];
            [maxIndexesArray addObject:[NSNumber numberWithInt:i]];
            maxHotDelta = delta;
        }
    }
    
    return maxIndexesArray;
}

- (NSInteger)deltaForKey:(NSString *)key withIndex:(NSInteger)index inArray:(NSArray *)array {
    MonthPayment *previousPayment;
    MonthPayment *currentPayment;
    
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


- (NSString *)textForKey:(NSString *)key withArray:(NSArray *)array andIndex:(NSInteger)selectedIndex {
    NSString *resultText;
    if (index > 0) {
        MonthPayment *prev;
        MonthPayment *cur; 
        if (IsAscending) {
            prev = array[selectedIndex - 1];
            cur = array[selectedIndex];
        } else {
            prev = array[selectedIndex];
            cur = array[selectedIndex - 1];
        }
        
        NSInteger delta = [self deltaForKey:key withIndex:selectedIndex inArray:array];
        resultText = [NSString stringWithFormat:@"%@ to %@-%d", [self stringFromDate:prev.date], [self stringFromDate:cur.date], delta];
    } else {
        resultText = @"";
    }
    
    return resultText;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateComponents *components = [API sharedComponentsForDate:date];
    return [NSString stringWithFormat:@"%d.%d.%d", components.day, components.month, components.year];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"Stat Segue"]) {
        FCStatTableViewController *statTVC = segue.destinationViewController;
        [statTVC setStatArray:self.fullArray];
    }
}

@end
