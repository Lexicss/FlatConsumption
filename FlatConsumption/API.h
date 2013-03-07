//
//  API.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface API : NSObject

+ (NSString *) entityName;
+ (void) showStandartAlertWithName:(NSString *)name description:(NSString *)description;

+ (NSArray *)monthPayments;
+ (void)setMonthPayments:(NSArray *)amonthPayments;
+ (NSDateComponents *)sharedComponentsForDate:(NSDate *)date;
+ (NSString *)stringWithZeroOfInt:(NSInteger)value;

@end
