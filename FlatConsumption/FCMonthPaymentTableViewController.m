//
//  FCMonthPaymentTableViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMonthPaymentTableViewController.h"

#define DATE_FONT [UIFont fontWithName:@"Baskerville-BoldItalic" size:17]
#define ENERGY_FONT [UIFont fontWithName:@"MarkerFelt-Thin" size:22]

static BOOL IsAscending = YES;

@implementation FCMonthPaymentTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedMonthPayment = _selectedMonthPayment;

- (void)setupFetchedResultsController {
    NSString *entityName = [API entityName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                     ascending:IsAscending
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self performFetch];
    [API setMonthPayments:self.fetchedResultsController.fetchedObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Month Cell";
    
    FCCell *cell = (FCCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[FCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.dateLabel.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:17];
    }
    
    MonthPayment *mp = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterMediumStyle];
    
    NSDateComponents *components = [API sharedComponentsForDate:mp.date];
    NSString *dateText = [NSString stringWithFormat:@"%d.%@.%d",[components day], [API stringWithZeroOfInt:[components month]], [components year]];
    
    if (cell.dateLabel.font != DATE_FONT) {
        [cell.dateLabel setFont:DATE_FONT];
    }
    cell.dateLabel.text = dateText;
    cell.hotKitchenLabel.text = [mp.hotKitchenWaterCount stringValue];
    cell.coldKitchenLabel.text = [mp.coldKitchenWaterCount stringValue];
    cell.hotBathLabel.text = [mp.hotBathWaterCount stringValue];
    cell.coldBathLabel.text = [mp.coldBathWaterCount stringValue];
    
    if (cell.energyLabel.font != ENERGY_FONT) {
        [cell.energyLabel setFont:ENERGY_FONT];
    }
    cell.energyLabel.text = [mp.energyCount stringValue];
    
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
            if (IsAscending) {
                addVC.lastMonthPayment = [recodrs lastObject];
            } else {
                addVC.lastMonthPayment = recodrs[0];
            }
            
        } else {
            addVC.lastMonthPayment = nil;
        }
    } else if ([segue.identifier isEqualToString:@"Edit Payment Segue"]) {
        FCEditViewController *editVC = segue.destinationViewController;
        editVC.delegate = self;
        editVC.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MonthPayment *selectedPayment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        editVC.monthPayment = selectedPayment;
    }
}

#pragma mark - AddMonthPayment Delegate

- (void)theSaveButtonOnAddWasTapped:(FCAddViewController *)controller {
    NSLog(@"objects are: %d", [self.fetchedResultsController.fetchedObjects count]);
    [API setMonthPayments:self.fetchedResultsController.fetchedObjects];
    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)theSaveButtonOnEditWasTapped:(FCEditViewController *)controller {
    [API setMonthPayments:self.fetchedResultsController.fetchedObjects];
    [controller.navigationController popViewControllerAnimated:YES];
}

@end
