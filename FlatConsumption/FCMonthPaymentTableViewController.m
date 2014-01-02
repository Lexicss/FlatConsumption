//
//  FCMonthPaymentTableViewController.m
//  FlatConsumption
//
//  Created by Lexicss on 03.03.13.
//  Copyright (c) 2013 Lexicss. All rights reserved.
//

#import "FCMonthPaymentTableViewController.h"
#import "FCAppDelegate.h"
#import "FCSummary.h"

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

#pragma mark - VC lifecycle

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
    
    NSIndexPath *previousIndexPath = [API previousIndexPathOf:indexPath
                                                    withCount:[self.fetchedResultsController.fetchedObjects count]];
    
    MonthPayment *mp = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MonthPayment *previousMp = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
    
    FCSummary *sum = [[FCSummary alloc] initWithMonthPayment:mp
                                          andPreviousPayment:previousMp];
    NSLog(@"HOT BATH: %d, COLD BATH: %d", [sum hotBathWater], [sum coldBathWater]);
    
    
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
        
        NSInteger count = [self.fetchedResultsController.fetchedObjects count];
        NSIndexPath *previousIndexPath = [API previousIndexPathOf:indexPath
                                                        withCount:count];

        MonthPayment *previousMonthPayment = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
        
        editVC.monthPayment = selectedPayment;
        editVC.previousMonthPayment = previousMonthPayment;
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
    
    [self addDate:@"4.02.2008" kitHot:5 kitCold:2 batHot:11 batCold:18 energy:1320];
    [self addDate:@"21.03.2008" kitHot:5 kitCold:2 batHot:13 batCold:23 energy:1440];
    [self addDate:@"24.04.2008" kitHot:6 kitCold:2 batHot:15 batCold:25 energy:1560];
    [self addDate:@"12.05.2008" kitHot:7 kitCold:3 batHot:16 batCold:26 energy:1680];
    [self addDate:@"11.06.2008" kitHot:7 kitCold:3 batHot:17 batCold:29 energy:1800];
    [self addDate:@"30.08.2008" kitHot:8 kitCold:4 batHot:19 batCold:34 energy:1920];
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
    
    [self addDate:@"1.02.2011" kitHot:27 kitCold:9 batHot:65 batCold:138 energy:5270];
    [self addDate:@"1.03.2011" kitHot:27 kitCold:9 batHot:67 batCold:140 energy:5340];
    [self addDate:@"1.04.2011" kitHot:27 kitCold:9 batHot:68 batCold:143 energy:5410];
    [self addDate:@"1.05.2011" kitHot:28 kitCold:10 batHot:69 batCold:147 energy:5480];
    [self addDate:@"1.06.2011" kitHot:28 kitCold:10 batHot:70 batCold:150 energy:5550];
    [self addDate:@"4.07.2011" kitHot:28 kitCold:10 batHot:71 batCold:152 energy:5620];
    [self addChangedDate:@"1.08.2011" kitHot:29 kitCold:10 batHot:72 batCold:155 energy:4500 from:5620 to:4444];
    [self addDate:@"1.09.2011" kitHot:29 kitCold:10 batHot:74 batCold:160 energy:4561];
    [self addDate:@"1.10.2011" kitHot:29 kitCold:10 batHot:76 batCold:165 energy:4683];
    [self addDate:@"2.11.2011" kitHot:30 kitCold:11 batHot:78 batCold:170 energy:4818];
    [self addDate:@"1.12.2011" kitHot:30 kitCold:11 batHot:79 batCold:174 energy:4945];
    [self addDate:@"2.01.2012" kitHot:31 kitCold:11 batHot:82 batCold:179 energy:5051];
    
    [self addDate:@"13.02.2012" kitHot:32 kitCold:12 batHot:85 batCold:184 energy:5188];
    [self addDate:@"1.03.2012" kitHot:32 kitCold:12 batHot:87 batCold:187 energy:5244];
    [self addDate:@"7.04.2012" kitHot:33 kitCold:12 batHot:90 batCold:192 energy:5367];
    [self addDate:@"3.05.2012" kitHot:33 kitCold:12 batHot:92 batCold:197 energy:5460];
    [self addDate:@"4.06.2012" kitHot:34 kitCold:12 batHot:94 batCold:204 energy:5572];
    [self addDate:@"3.07.2012" kitHot:34 kitCold:12 batHot:96 batCold:209 energy:5660];
    [self addDate:@"6.08.2012" kitHot:34 kitCold:12 batHot:98 batCold:216 energy:5794];
    [self addDate:@"8.09.2012" kitHot:35 kitCold:14 batHot:100 batCold:221 energy:5923];
    [self addDate:@"1.10.2012" kitHot:35 kitCold:14 batHot:102 batCold:225 energy:6010];
    [self addDate:@"4.11.2012" kitHot:36 kitCold:14 batHot:105 batCold:230 energy:6124];
    [self addDate:@"1.12.2012" kitHot:37 kitCold:14 batHot:107 batCold:234 energy:6210];
    [self addDate:@"2.01.2013" kitHot:38 kitCold:15 batHot:110 batCold:239 energy:6313];
    
    [self addDate:@"3.02.2013" kitHot:38 kitCold:15 batHot:112 batCold:244 energy:6450];
    [self addDate:@"2.03.2013" kitHot:39 kitCold:15 batHot:114 batCold:248 energy:6534];
    [self addDate:@"1.04.2013" kitHot:39 kitCold:15 batHot:116 batCold:253 energy:6636];
    [self addDate:@"1.05.2013" kitHot:40 kitCold:15 batHot:118 batCold:258 energy:6745];
    [self addDate:@"1.06.2013" kitHot:40 kitCold:16 batHot:120 batCold:262 energy:6868];
    [self addDate:@"2.07.2013" kitHot:41 kitCold:17 batHot:121 batCold:267 energy:6980];
    [self addDate:@"1.08.2013" kitHot:41 kitCold:17 batHot:123 batCold:272 energy:7079];
    [self addDate:@"1.09.2013" kitHot:42 kitCold:18 batHot:125 batCold:276 energy:7184];
    [self addDate:@"5.10.2013" kitHot:42 kitCold:18 batHot:128 batCold:281 energy:7288];
    [self addDate:@"1.11.2013" kitHot:42 kitCold:18 batHot:130 batCold:284 energy:7383];
    [self addDate:@"1.12.2013" kitHot:43 kitCold:19 batHot:132 batCold:289 energy:7496];
    
    
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(suspendedRefresh:)
                                   userInfo:nil
                                    repeats:NO];
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
    [monthPayment setColdBathWaterCount:[NSNumber numberWithInt:batCold]];
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
    [monthPayment setColdBathWaterCount:[NSNumber numberWithInt:batCold]];
    [monthPayment setEnergyCount:[NSNumber numberWithInt:energy]];
    [monthPayment setEnergyCountChanged:@YES];
    [monthPayment setEnergyCountOld:[NSNumber numberWithInt:from]];
    [monthPayment setEnergyCountNew:[NSNumber numberWithInt:to]];
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
}

// I`am writing this comment

- (void)suspendedRefresh:(id)sender {
    [self.tableView reloadData];
}
@end
