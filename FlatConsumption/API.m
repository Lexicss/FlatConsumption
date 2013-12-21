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
static NSFetchedResultsController *fetchedResultsController;


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

+ (NSString *)nameOfNum:(NSInteger)num {
    switch (num) {
        case 0:
            return @"Hot Water on Kitchen";
        case 1:
            return @"Cold Water on Kitchen";
        case 2:
            return @"Hot Water on Bath";
        case 3:
            return @"Cold Water on Bath";
        case 4:
            return @"Energy";
            
        default:
            return @"";
    }
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithContext:(NSManagedObjectContext *)context {
    if (fetchedResultsController == nil) {
        NSString *entityName = [self entityName];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                  ascending:IsAscending
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:context
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        
        
    }
    return fetchedResultsController;
}

+ (void)debugView:(UIView *)view withColor:(UIColor *)color {
    UIColor *debugColor;
    
    if (color) {
        debugColor = color;
    } else {
        color = [UIColor redColor];
    }
    
    [view.layer setBorderColor:[debugColor CGColor]];
    [view.layer setBorderWidth:1];
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

@end
