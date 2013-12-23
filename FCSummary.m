//
//  FCSummary.m
//  FlatConsumption
//
//  Created by Lexicss on 23.12.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCSummary.h"

@implementation FCSummary

- (id)initWithMonthPayment:(MonthPayment *)mp
        andPreviousPayment:(MonthPayment *)previousMp{
    self = [super init];
    
    if (self) {
        NSInteger hk = [mp.hotKitchenWaterCount integerValue] - [previousMp.hotKitchenWaterCount integerValue];
        NSInteger ck = [mp.coldKitchenWaterCount integerValue] - [previousMp.coldKitchenWaterCount integerValue];
        NSInteger hb = [mp.hotBathWaterCount integerValue] - [previousMp.hotBathWaterCount integerValue];
        NSInteger cb = [mp.coldBathWaterCount integerValue] - [previousMp.coldBathWaterCount integerValue];
        NSInteger e;
        
        if ([mp.energyCountChanged boolValue]) {
            e = [mp.energyCountOld integerValue] - [previousMp.energyCount integerValue];
            e += [mp.energyCount integerValue] - [mp.energyCountNew integerValue];
        } else {
            e = [mp.energyCount integerValue] - [previousMp.energyCount integerValue];
        }
        
        _fullWater = hk + ck + hb + cb;
        _hotWater = hk + hb;
        _coldWater = ck + cb;
        _kitchenWater = hk + ck;
        _bathWater = hb + cb;
        _energy = e;
        
        _coldBathWater = cb;
        _hotBathWater = hb;
    }
    
    return self;
}

@end
