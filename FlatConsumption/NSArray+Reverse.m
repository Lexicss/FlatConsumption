//
//  NSArray+Reverse.m
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/12/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reverseArray {
    NSUInteger count = [self count];
    NSMutableArray *revArray = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        [revArray addObject:[self objectAtIndex:count - i - 1]];
    }
    return (NSArray *)revArray;
}

@end
