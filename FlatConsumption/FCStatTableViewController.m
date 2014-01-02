//
//  FCStatTableViewController.m
//  FlatConsumption
//
//  Created by Aliaksei_Maiorau on 3/11/13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCStatTableViewController.h"

@interface FCStatTableViewController ()

@end

@implementation FCStatTableViewController
@synthesize statArray = statArray_;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"Array has %d objects", [self.statArray count]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [statArray_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *monthArray = statArray_[section];
    return [monthArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [API nameOfNum:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Statistic Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *currentArray = [statArray_ objectAtIndex:indexPath.section];
    NSString *yearString;
    
    NSArray *maxIndexes = [self maxIndexesInArray:currentArray];
    NSArray *minIndexes = [self minIndexesInArray:currentArray];
    
    if ([maxIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        yearString = [NSString stringWithFormat:@"%@ - max",
                      [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue]];
        cell.textLabel.textColor = [UIColor redColor];
    } else if ([minIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        yearString = [NSString stringWithFormat:@"%@ - min",
                      [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue]];
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        yearString = [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue];
        cell.textLabel.textColor = [UIColor blackColor];
    }    
    
//    if ([self maxIndexInArray:currentArray] == indexPath.row) {
//        yearString = [NSString stringWithFormat:@"%@ - max",
//                      [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue]];
//        cell.textLabel.textColor = [UIColor redColor];
//    } else if ([self minIndexInArray:currentArray] == indexPath.row) {
//        yearString = [NSString stringWithFormat:@"%@ - min",
//                      [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue]];
//        cell.textLabel.textColor = [UIColor greenColor];
//    } else {
//        yearString = [((FCStat *)[currentArray objectAtIndex:indexPath.row]).yearNumber stringValue];
//        cell.textLabel.textColor = [UIColor blackColor];
//    }
    
    NSString *valueString = [((FCStat *)[currentArray objectAtIndex:indexPath.row]).valueNumber stringValue];
                             
    cell.textLabel.text = yearString;
    cell.detailTextLabel.text = valueString;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - calculate min & max

- (NSInteger)minIndexInArray:(NSArray *)statArray {
    NSInteger minValue = [[(FCStat *)statArray[0] valueNumber] integerValue];
    NSInteger minIndex = 0;
    
    for (NSInteger i = 1; i < [statArray count]; i++) {
        NSInteger value = 0;
        
        if (value < minValue) {
            minValue = value;
            minIndex = i;
        }
    }
    return minIndex;
}

- (NSInteger)maxIndexInArray:(NSArray *)statArray {
    NSInteger maxValue = [[(FCStat *)statArray[0] valueNumber] integerValue];
    NSInteger maxIndex = 0;
    
    for (NSInteger i = 1; i < [statArray count]; i++) {
        NSInteger value = [((FCStat *)statArray[i]).valueNumber integerValue];
        
        if (value > maxValue) {
            maxValue = value;
            maxIndex = i;
        }
    }
    return maxIndex;
}

- (NSArray *)minIndexesInArray:(NSArray *)statArray {
    NSMutableArray *indexes = [NSMutableArray array];
    NSInteger minValue = [[(FCStat *)statArray[0] valueNumber] integerValue];
    NSInteger minIndex = 0;
    [indexes addObject:[NSNumber numberWithInt:minIndex]];
    
    for (NSInteger i = 1; i < [statArray count]; i++) {
        NSInteger value = [((FCStat *)statArray[i]).valueNumber integerValue];
        
        if (value < minValue) {
            minValue = value;
            minIndex = i;
            [indexes removeAllObjects];
            [indexes addObject:[NSNumber numberWithInt:minIndex]];
        } else if (value == minIndex) {
            [indexes addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return [NSArray arrayWithArray:indexes];
}

- (NSArray *)maxIndexesInArray:(NSArray *)statArray {
    NSMutableArray *indexes = [NSMutableArray array];
    NSInteger maxValue = [[(FCStat *)statArray[0] valueNumber] integerValue];
    NSInteger maxIndex = 0;
    [indexes addObject:[NSNumber numberWithInt:maxIndex]];
    
    for (NSInteger i = 1; i < [statArray count]; i++) {
        NSInteger value = [((FCStat *)statArray[i]).valueNumber integerValue];
        
        if (value > maxValue) {
            maxValue = value;
            maxIndex = i;
            [indexes removeAllObjects];
            [indexes addObject:[NSNumber numberWithInt:maxIndex]];
        } else if (value == maxValue) {
            [indexes addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return [NSArray arrayWithArray:indexes];
}

@end
