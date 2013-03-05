//
//  MonthPayment.h
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/5/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MonthPayment : NSManagedObject

@property (nonatomic, retain) NSNumber * coldBathWaterCount;
@property (nonatomic, retain) NSNumber * coldKitchenWaterCount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * energyCount;
@property (nonatomic, retain) NSNumber * energyCountChanged;
@property (nonatomic, retain) NSNumber * energyCountNew;
@property (nonatomic, retain) NSNumber * energyCountOld;
@property (nonatomic, retain) NSNumber * hotBathWaterCount;
@property (nonatomic, retain) NSNumber * hotKitchenWaterCount;

@end
