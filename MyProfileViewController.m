//
//  MyProfileViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 2/23/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MyProfileTableView.h"

@interface MyProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet MyProfileTableView *tableView;

@end

@implementation MyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileTableCell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Username:";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Gender:";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Region";
    }
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
