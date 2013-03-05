//
//  FCMonthPaymentTableViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMonthPaymentTableViewController.h"

@implementation FCMonthPaymentTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedMonthPayment = _selectedMonthPayment;

- (void)setupFetchedResultsController {
    NSString *entityName = [API entityName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Month Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MonthPayment *mp = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *dateText = [NSString stringWithFormat:@"%@, ",[f stringFromDate:mp.date]];;
    cell.textLabel.text = [NSString stringWithFormat:@"Kithen:%@;%@ Bath:%@;%@ Enr:%@",
                           mp.hotKichenWaterCount,
                           mp.coldKitchenWaterCount,
                           mp.hotBathWaterCount,
                           mp.coldBathWaterCount,
                           mp.energyCount];
    cell.detailTextLabel.text = dateText;
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%d records", [self.fetchedResultsController.fetchedObjects count]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Add Payment Segue"]) {
        FCAddViewController *addVC = segue.destinationViewController;
        addVC.delegate = self;
        addVC.managedObjectContext = self.managedObjectContext;
        
        NSArray *recodrs = [self.fetchedResultsController fetchedObjects];
        if ([recodrs count] > 0) {
            addVC.lastMonthPayment = [recodrs lastObject];
        } else {
            addVC.lastMonthPayment = nil;
        }
    }
}

#pragma mark - AddMonthPayment Delegate

- (void)theSaveButtonOnAddWasTapped:(FCAddViewController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

@end
