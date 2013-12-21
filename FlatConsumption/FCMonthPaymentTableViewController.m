//
//  FCMonthPaymentTableViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMonthPaymentTableViewController.h"
#import "FCAppDelegate.h"

#define DATE_FONT [UIFont fontWithName:@"Baskerville-BoldItalic" size:17]
#define ENERGY_FONT [UIFont fontWithName:@"MarkerFelt-Thin" size:22]

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface FCMonthPaymentTableViewController ()<UIAlertViewDelegate> {
    BOOL _restoreMode;
}

@end

@implementation FCMonthPaymentTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedMonthPayment = _selectedMonthPayment;

- (void)setupFetchedResultsController {
    self.fetchedResultsController = [API fetchedResultsControllerWithContext:self.managedObjectContext];
    [self performFetch];
    [API setMonthPayments:self.fetchedResultsController.fetchedObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _restoreMode = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupFetchedResultsController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

#pragma mark - TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Month Cell";
    
    FCCell *cell = (FCCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[FCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.dateLabel.font = DATE_FONT;
    }
    
    MonthPayment *mp = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateComponents *components = [API sharedComponentsForDate:mp.date];
    NSString *dateText = [NSString stringWithFormat:@"%d.%@.%d",[components day],
                          [API stringWithZeroOfInt:[components month]], [components year]];
    
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

#pragma mark - Segue

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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
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

- (IBAction)restoreButtonClicked:(id)sender {
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore base"
                                                        message:@"Are you sure that you want to restore database"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Restore", nil];
        [alert show];
    } else {
        [self restoreBase];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"button index: %d", buttonIndex);
    
    if (buttonIndex) { // if not Cancel clicked
        [self restoreBase];
    }
}

- (void)resetBase {
    //FCAppDelegate *appDelegate =  (FCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *allObjects = [self.fetchedResultsController fetchedObjects];
    
    for (MonthPayment *payment in allObjects) {
        [self.managedObjectContext deleteObject:payment];
    }
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
}

- (void)restoreBase {
    [self resetBase];
    
    [self addDate:@"7.05.2007"
           kitHot:0
          kitCold:0
           batHot:0
          batCold:0
           energy:500];
    [self addDate:@"20.06.2007" kitHot:0 kitCold:0 batHot:0 batCold:2 energy:550];
    [self addDate:@"16.07.2007" kitHot:1 kitCold:1 batHot:1 batCold:4 energy:600];
    [self addDate:@"13.08.2007" kitHot:1 kitCold:1 batHot:3 batCold:6 energy:690];
    [self addDate:@"16.09.2007" kitHot:1 kitCold:1 batHot:3 batCold:6 energy:790];
    [self addDate:@"15.10.2007" kitHot:2 kitCold:1 batHot:4 batCold:8 energy:900];
    [self addDate:@"16.11.2007" kitHot:3 kitCold:1 batHot:5 batCold:11 energy:1000];
    [self addDate:@"17.12.2007" kitHot:4 kitCold:2 batHot:8 batCold:15 energy:1100];
    [self addDate:@"21.01.2008" kitHot:4 kitCold:2 batHot:10 batCold:17 energy:1200];
    
    [self addDate:@"4.02.2008" kitHot:5 kitCold:2 batHot:11 batCold:18 energy:1300];
    [self addDate:@"21.03.2008" kitHot:5 kitCold:2 batHot:13 batCold:23 energy:1400];
    [self addDate:@"24.04.2008" kitHot:6 kitCold:2 batHot:15 batCold:25 energy:1500];
    [self addDate:@"12.05.2008" kitHot:7 kitCold:3 batHot:16 batCold:26 energy:1600];
    [self addDate:@"11.06.2008" kitHot:7 kitCold:3 batHot:17 batCold:29 energy:1700];
    [self addDate:@"30.08.2008" kitHot:8 kitCold:4 batHot:19 batCold:34 energy:1950];
    [self addDate:@"12.09.2008" kitHot:8 kitCold:4 batHot:20 batCold:34 energy:2000];
    [self addDate:@"16.10.2008" kitHot:9 kitCold:5 batHot:23 batCold:37 energy:2100];
    [self addDate:@"14.11.2008" kitHot:9 kitCold:5 batHot:23 batCold:37 energy:2200];
    [self addDate:@"15.12.2008" kitHot:11 kitCold:5 batHot:28 batCold:42 energy:2300];
    [self addDate:@"20.01.2009" kitHot:12 kitCold:6 batHot:31 batCold:44 energy:2450];
    
    [self.tableView reloadData];
}

- (void)addDate:(NSString *)date
         kitHot:(NSInteger)kitHot
        kitCold:(NSInteger)kitCold
         batHot:(NSInteger)batHot
        batCold: (NSInteger)batCold
         energy:(NSInteger)energy {
    MonthPayment *monthPayment = [NSEntityDescription insertNewObjectForEntityForName:[API entityName]
                                                               inManagedObjectContext:_managedObjectContext];
    [monthPayment setDate:[API dateFromString:date]];
    [monthPayment setHotKitchenWaterCount:[NSNumber numberWithInt:kitHot]];
    [monthPayment setColdKitchenWaterCount:[NSNumber numberWithInt:kitCold]];
    [monthPayment setHotBathWaterCount:[NSNumber numberWithInt:batHot]];
    [monthPayment setColdKitchenWaterCount:[NSNumber numberWithInt:batCold]];
    [monthPayment setEnergyCount:[NSNumber numberWithInt:energy]];
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
}
@end
