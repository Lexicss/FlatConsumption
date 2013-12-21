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
    [self addDate:@"16.10.2008" kitHot:9 kitCold:5 batHot:23 batCold:37 energy:2050];
    [self addDate:@"14.11.2008" kitHot:9 kitCold:5 batHot:23 batCold:37 energy:2100];
    [self addDate:@"15.12.2008" kitHot:11 kitCold:5 batHot:28 batCold:42 energy:2150];
    [self addDate:@"20.01.2009" kitHot:12 kitCold:6 batHot:31 batCold:44 energy:2200];
    
    [self addDate:@"4.02.2009" kitHot:13 kitCold:6 batHot:32 batCold:46 energy:2220];
    [self addDate:@"16.03.2009" kitHot:14 kitCold:6 batHot:34 batCold:49 energy:2290];
    [self addDate:@"7.04.2009" kitHot:15 kitCold:6 batHot:35 batCold:50 energy:2310];
    [self addDate:@"1.05.2009" kitHot:15 kitCold:6 batHot:36 batCold:52 energy:2345];
    [self addDate:@"1.06.2009" kitHot:16 kitCold:7 batHot:36 batCold:58 energy:2393];
    [self addDate:@"1.07.2009" kitHot:16 kitCold:7 batHot:37 batCold:62 energy:2439];
    [self addDate:@"3.08.2009" kitHot:17 kitCold:7 batHot:39 batCold:66 energy:2504];
    [self addDate:@"1.09.2009" kitHot:17 kitCold:7 batHot:39 batCold:69 energy:2562];
    [self addDate:@"1.10.2009" kitHot:18 kitCold:7 batHot:41 batCold:72 energy:2614];
    [self addDate:@"1.11.2009" kitHot:19 kitCold:7 batHot:44 batCold:78 energy:2678];
    [self addDate:@"1.12.2009" kitHot:21 kitCold:8 batHot:46 batCold:83 energy:2749];
    [self addChangedDate:@"1.01.2010" kitHot:22 kitCold:8 batHot:48 batCold:88 energy:4409 from:2799 to:4395];
    
    [self addDate:@"1.02.2010" kitHot:22 kitCold:8 batHot:48 batCold:88 energy:4409];
    [self addDate:@"1.03.2010" kitHot:22 kitCold:8 batHot:48 batCold:89 energy:4449];
    [self addDate:@"1.04.2010" kitHot:22 kitCold:8 batHot:51 batCold:96 energy:4593];
    [self addDate:@"3.05.2010" kitHot:23 kitCold:8 batHot:52 batCold:101 energy:4664];
    [self addDate:@"3.06.2010" kitHot:23 kitCold:9 batHot:52 batCold:108 energy:4736];
    [self addDate:@"1.07.2010" kitHot:23 kitCold:9 batHot:56 batCold:115 energy:4805];
    [self addDate:@"1.08.2010" kitHot:24 kitCold:9 batHot:57 batCold:118 energy:4901];
    [self addDate:@"1.09.2010" kitHot:24 kitCold:9 batHot:58 batCold:120 energy:4970];
    [self addDate:@"1.10.2010" kitHot:24 kitCold:9 batHot:59 batCold:123 energy:5034];
    [self addDate:@"1.11.2010" kitHot:25 kitCold:9 batHot:61 batCold:126 energy:5131];
    [self addDate:@"1.12.2010" kitHot:25 kitCold:9 batHot:62 batCold:131 energy:5200];
    [self addDate:@"3.01.2011" kitHot:26 kitCold:9 batHot:64 batCold:135 energy:5201];
    
    
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
    [monthPayment setEnergyCountChanged:@NO];
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
}

- (void)addChangedDate:(NSString *)date
                kitHot:(NSInteger)kitHot
               kitCold:(NSInteger)kitCold
                batHot:(NSInteger)batHot
               batCold: (NSInteger)batCold
                energy:(NSInteger)energy
                  from:(NSInteger)from
                    to:(NSInteger)to {
    MonthPayment *monthPayment = [NSEntityDescription insertNewObjectForEntityForName:[API entityName]
                                                               inManagedObjectContext:_managedObjectContext];
    [monthPayment setDate:[API dateFromString:date]];
    [monthPayment setHotKitchenWaterCount:[NSNumber numberWithInt:kitHot]];
    [monthPayment setColdKitchenWaterCount:[NSNumber numberWithInt:kitCold]];
    [monthPayment setHotBathWaterCount:[NSNumber numberWithInt:batHot]];
    [monthPayment setColdKitchenWaterCount:[NSNumber numberWithInt:batCold]];
    [monthPayment setEnergyCount:[NSNumber numberWithInt:energy]];
    [monthPayment setEnergyCountChanged:@YES];
    [monthPayment setEnergyCountOld:[NSNumber numberWithInt:from]];
    [monthPayment setEnergyCountNew:[NSNumber numberWithInt:to]];
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
}
@end
