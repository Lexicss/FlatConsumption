//
//  FCSummary.h
//  FlatConsumption
//
//  Created by Lexicss on 23.12.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthPayment.h"

@interface FCSummary : NSObject

@property(nonatomic, readonly) NSInteger fullWater;
@property(nonatomic, readonly) NSInteger hotWater;
@property(nonatomic, readonly) NSInteger coldWater;
@property(nonatomic, readonly) NSInteger kitchenWater;
@property(nonatomic, readonly) NSInteger bathWater;
@property(nonatomic, readonly) NSInteger energy;


- (id)initWithMonthPayment:(MonthPayment *)mp
        andPreviousPayment:(MonthPayment *)previousMp;

@end
