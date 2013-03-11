//
//  FCStat.h
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/11/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCStat : NSObject

@property(strong, nonatomic) NSNumber *yearNumber;
@property(strong, nonatomic) NSNumber *valueNumber;
@property(strong, nonatomic) NSString *name;

- (id)initWithYear:(NSInteger)year withValue:(NSInteger)value withKey:(NSString *)key;

@end
