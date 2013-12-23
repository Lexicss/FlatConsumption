//
//  FCMainViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMainViewController.h"

#define SECTIONS_COUNT 5

static const BOOL kIncludeCurrentYear = YES;

@interface FCMainViewController ()
@property(strong, nonatomic) NSArray *fullArray;

@property(strong, nonatomic) NSArray *hotKitchenIndexes;
@property(strong, nonatomic) NSArray *coldKitchenIndexes;
@property(strong, nonatomic) NSArray *hotBathIndexes;
@property(strong, nonatomic) NSArray *coldBathIndexes;
@property(strong, nonatomic) NSArray *energyIndexes;
@property(strong, nonatomic) NSArray *allWaterIndexes;

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
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone]; // iOS 7 specific
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *payments = [API monthPayments];
    self.hotKitchenIndexes = [self indexesOfMaxConsumptionForKey:kHotKitchenKey withArray:payments];
    self.coldKitchenIndexes = [self indexesOfMaxConsumptionForKey:kColdKitchenKey withArray:payments];
    self.hotBathIndexes = [self indexesOfMaxConsumptionForKey:kHotBathKey withArray:payments];
    self.coldBathIndexes = [self indexesOfMaxConsumptionForKey:kColdBathKey withArray:payments];
    self.energyIndexes = [self indexesOfMaxConsumptionForKey:kEnergyKey withArray:payments];
    self.allWaterIndexes = [self indexesOfMaxConsumptionForKey:kAllWater withArray:payments];
    
    NSArray *hotKitchenArray = [self calcAnnualForKey:kHotKitchenKey];
    NSArray *coldKitchenArray = [self calcAnnualForKey:kColdKitchenKey];
    NSArray *hotBathArray = [self calcAnnualForKey:kHotBathKey];
    NSArray *coldBathArray = [self calcAnnualForKey:kColdBathKey];
    NSArray *energyArray = [self calcAnnualForKey:kEnergyKey];
    
    
    NSArray *allArray = @[hotKitchenArray, coldKitchenArray, hotBathArray, coldBathArray, energyArray];
    [self setFullArray:allArray];
    
    [self.tableView setDataSource:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.tableView setDataSource:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Keys

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
        case 5:
            return @"allWaterIndexes";
            
        default:
            return @"";
    }
}

- (NSString *)keyOfWaterCountNum:(NSInteger)num {
    switch (num) {
        case 0:
            return kHotKitchenKey;
        case 1:
            return kColdKitchenKey;
        case 2:
            return kHotBathKey;
        case 3:
            return kColdBathKey;
        case 4:
            return kEnergyKey;
        case 5:
            return kAllWater;
            
        default:
            return @"";
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTIONS_COUNT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [API nameOfNum:section];
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

#pragma mark - Custom

- (NSArray *)calcAnnualForKey:(NSString *)key {
    NSArray *workArray;
    if (IsAscending) {
        workArray = [API monthPayments];
    } else {
        workArray = [[API monthPayments] reverseArray];
    }
    
    if ([workArray count] == 0) {
        return [NSArray array];
    }
    
    MonthPayment *thePayment = [workArray objectAtIndex:0];
    NSInteger tempAmount = 0;
    NSInteger startYear = [self yearAtIndex:0 inArray:workArray];
    NSInteger startValue;
    
    if ([key isEqualToString:kAllWater]) {
        startValue = [self allWaterForMonth:thePayment];
    } else {
        startValue = [[thePayment valueForKey:key] integerValue];
    }

    NSInteger currentValue = startValue;
    NSMutableArray *yearArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < [workArray count]; i++) {
        NSInteger currentYear = [self yearAtIndex:i inArray:workArray];

        if ([key isEqualToString:kEnergyKey]) {
            thePayment = [workArray objectAtIndex:i];
            if ([thePayment.energyCountChanged boolValue]) {
                tempAmount += [thePayment.energyCountOld integerValue] - startValue;
                startValue = [thePayment.energyCountNew integerValue];
                
                NSLog(@"old value - %d, new value - %d",[thePayment.energyCountOld integerValue], [thePayment.energyCountNew integerValue] );
            }
        }

        BOOL includeCurrentYear = kIncludeCurrentYear && i == workArray.count - 1;
        if (currentYear > startYear || includeCurrentYear) {
            MonthPayment *thisPayment = [workArray objectAtIndex:i];
            currentValue = [[thisPayment valueForKey:key] integerValue] - startValue + tempAmount;
            FCStat *stat = [[FCStat alloc] initWithYear:startYear withValue:currentValue withKey:key];
            [yearArray addObject:stat];
            startYear = currentYear;
            startValue = [[thisPayment valueForKey:key] integerValue];
            tempAmount = 0;
        }
    }
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
    NSMutableArray *maxIndexesArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 1; i < [array count]; i++) {
        NSInteger delta = [self deltaForKey:key withIndex:i inArray:array];
        if (delta == maxHotDelta) {
            [maxIndexesArray addObject:[NSNumber numberWithInt:i]];
        } else if (delta > maxHotDelta) {
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
    
    if ([key isEqualToString:kAllWater]) {
        
    }
    
    NSInteger curValue;
    NSInteger prevValue;
    
    if ([key isEqualToString:kAllWater]) {
        curValue = [self allWaterForMonth:currentPayment];
        prevValue = [self allWaterForMonth:previousPayment];
    } else {
       curValue = [[currentPayment valueForKey:key] integerValue];
       prevValue = [[previousPayment valueForKey:key] integerValue];
    }
    
    if ([key isEqualToString:kEnergyKey] && [[currentPayment energyCountChanged] boolValue]) {
        NSInteger afterChange = curValue - [[currentPayment energyCountNew] integerValue];
        NSInteger beforeChange = [[currentPayment energyCountOld] integerValue] - prevValue;
        NSLog(@"on counter changed %@ consumption is: %d", [currentPayment date] ,afterChange + beforeChange);
        return afterChange + beforeChange;
    } else {
        return curValue - prevValue;
    }
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

- (NSInteger)allWaterForMonth:(MonthPayment *)payment {
   NSInteger amount =  [payment.hotBathWaterCount integerValue] + [payment.coldBathWaterCount integerValue] +
    [payment.hotKitchenWaterCount integerValue] + [payment.coldKitchenWaterCount integerValue];
    NSLog(@"Water count for month: %d", amount);
    
    return amount;
}

@end
