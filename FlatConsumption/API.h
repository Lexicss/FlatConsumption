//
//  API.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>

static BOOL IsAscending = NO;

static NSString *kHotKitchenKey= @"hotKitchenWaterCount";
static NSString *kColdKitchenKey = @"coldKitchenWaterCount";
static NSString *kHotBathKey = @"hotBathWaterCount";
static NSString *kColdBathKey = @"coldBathWaterCount";
static NSString *kEnergyKey = @"energyCount";
static NSString *kAllWater = @"allWater";

@interface API : NSObject

+ (NSString *) entityName;
+ (void) showStandartAlertWithName:(NSString *)name description:(NSString *)description;

+ (NSArray *)monthPayments;
+ (void)setMonthPayments:(NSArray *)amonthPayments;
+ (NSDateComponents *)sharedComponentsForDate:(NSDate *)date;
+ (NSString *)stringWithZeroOfInt:(NSInteger)value;
+ (NSString *)nameOfNum:(NSInteger)num;
+ (NSFetchedResultsController *)fetchedResultsControllerWithContext:(NSManagedObjectContext *) context;

+ (void)debugView:(UIView *)view withColor:(UIColor *)color;
+ (NSDate *)dateFromString:(NSString *)string;

@end
