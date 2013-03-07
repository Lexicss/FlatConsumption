//
//  UITextField+UIFieldAttr.m
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/7/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "UITextField+UIFieldAttr.h"

@implementation UITextField (UIFieldAttr)

- (BOOL) isEmpty {
    return [self.text isEqualToString:@""];
}

@end
