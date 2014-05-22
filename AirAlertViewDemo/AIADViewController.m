//
//  AIADViewController.m
//  AirAlertViewDemo
//
//  Created by Oleg Lobachev on 20.05.14.
//  Copyright (c) 2014 aironik. All rights reserved.
//

#import "AIADViewController.h"

#import <AirAlertView/AirAlertView.h>


@interface AIADViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) AIAModalView *modalView;

@end


@implementation AIADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Current text";
    }
    return @"Actions";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (indexPath.section == 0) {
        result.textLabel.text = self.text;
    }
    else {
        switch (indexPath.row) {
            case 0:
                result.textLabel.text = @"AIAAlertView";
                break;
            case 1:
                result.textLabel.text = @"AIAModalView";
                break;
        }
    }
    return result;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (indexPath.section != 0) {
        switch (indexPath.row) {
            case 0:
                [self showAlert];
                break;
            case 1:
                [self showModalView];
                break;
                
            default:
                break;
        }
    }
}

- (void)showAlert {
    AIAAlertView *alertView = [[AIAAlertView alloc] initWithTitle:@"Update text" message:@"You can update text. Choose new value."];

    __weak typeof(self) weakSelf = self;
    [alertView addButtonWithTitle:@"1" actionBlock:^{
        weakSelf.text = @"1";
        [weakSelf.tableView reloadData];
    }];

    [alertView addButtonWithTitle:@"2" actionBlock:^{
        weakSelf.text = @"2";
        [weakSelf.tableView reloadData];
    }];

    [alertView addCancelButtonWithTitle:@"Clear" actionBlock:^{
        weakSelf.text = nil;
        [weakSelf.tableView reloadData];
    }];

    [alertView show];
}

- (void)showModalView {
    self.modalView = [[AIAModalView alloc] init];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 300., 210.)];
    
    for (NSInteger idx = 0; idx < 3; ++idx) {
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionButton addTarget:self action:@selector(changeText:) forControlEvents:UIControlEventTouchUpInside];
        [actionButton setTitle:[NSString stringWithFormat:@"%d", idx + 3] forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        actionButton.frame = CGRectMake(0., idx * 70., 300., 70.);
        [contentView addSubview:actionButton];
    }
    self.modalView.contentView = contentView;
    self.modalView.hideOnTapOutside = YES;
    [self.modalView show];
}

- (IBAction)changeText:(UIButton *)sender {
    self.text = sender.currentTitle;
    [self.tableView reloadData];
    [self.modalView dismiss];
}


@end
