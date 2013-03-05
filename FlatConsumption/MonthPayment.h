//
//  MonthPayment.h
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MonthPayment : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * hotKichenWaterCount;
@property (nonatomic, retain) NSNumber * coldKitchenWaterCount;
@property (nonatomic, retain) NSNumber * hotBathWaterCount;
@property (nonatomic, retain) NSNumber * coldBathWaterCount;
@property (nonatomic, retain) NSNumber * energyCount;
@property (nonatomic, retain) NSNumber * energyCountChanged;
@property (nonatomic, retain) NSNumber * energyCountOld;
@property (nonatomic, retain) NSNumber * energyCountNew;

@end
