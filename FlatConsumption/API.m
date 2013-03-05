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

@implementation API

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

@end
