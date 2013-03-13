//
//  API.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "API.h"

static const NSString *kEntityName = @"MonthPayment";
static NSArray *monthPayments;
static NSCalendar *calendar;


@implementation API

+ (void)initialize {
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
}

+ (NSString *) entityName {
    return [kEntityName copy];
}

+ (void) showStandartAlertWithName:(NSString *)name description:(NSString *)description {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:name
                                                    message:description
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (NSArray *)monthPayments {
    return monthPayments;
}

+ (void)setMonthPayments:(NSArray *)amonthPayments {
    if (monthPayments != amonthPayments) {
        monthPayments = amonthPayments;
    }
}

+ (NSDateComponents *)sharedComponentsForDate:(NSDate *)date {
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit |
                                                         NSMonthCalendarUnit |
                                                         NSDayCalendarUnit |
                                                         NSWeekdayCalendarUnit
                                                         ) fromDate:date];
    return components;
}

+ (NSString *)stringWithZeroOfInt:(NSInteger)value {
    if (value < 10) {
        return [NSString stringWithFormat:@"0%d",value];
    } else {
        return [NSString stringWithFormat:@"%d", value];
    }
}

@end
