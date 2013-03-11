//
//  FCStat.m
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/11/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCStat.h"

@implementation FCStat

- (id)initWithYear:(NSInteger)year withValue:(NSInteger)value withKey:(NSString *)key {
    self = [super init];
    if (self) {
        self.yearNumber = [NSNumber numberWithInt:year];
        self.valueNumber = [NSNumber numberWithInt:value];
        self.name = key;
    }
    return self;
}

@end