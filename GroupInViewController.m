//
//  GroupInViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 2/23/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "GroupInViewController.h"
#import "ViewGroupsViewController.h"
#import "GTMHTTPFetcher.h"
#import "GTLGroupinuserendpointCollectionResponseGroupInUser.h"
#import "GTLGroupinuserendpoint.h"

@interface GroupInViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;
@end

@implementation GroupInViewController

@synthesize username = _username;
@synthesize password = _password;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"GroupIn"];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(setting)]];
    self.username = @"yoyosir1";
    self.password = @"111";
    if ([self.username isEqualToString:@"yoyosir1"])
    {
        self.imageView.image = [UIImage imageNamed:@"avatar1.png"];
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"missingAvatar.png"];
    }
    static GTLServiceGroupinuserendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceGroupinuserendpoint alloc] init];
        service.retryEnabled = YES;
    }
    
    GTLGroupinuserendpointGroupInUser* user = [GTLGroupinuserendpointGroupInUser alloc];
    [user setUsername:@"yoyosir1"];
    [user setPassword:@"111111"];
    [user setNickname:@"yoyosir1"];
    GTLQueryGroupinuserendpoint* queryCreateUser = [GTLQueryGroupinuserendpoint queryForInsertGroupInUserWithObject:user];
    [service executeQuery:queryCreateUser completionHandler:^(GTLServiceTicket *ticket, GTLGroupinuserendpointGroupInUser *object, NSError *error) {
        NSLog(@"query complete");
        NSLog(@"%@", object);
        // Do something with items.
    }];
    NSLog(@"view did load");
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setting
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewGroupsViewController* controller = segue.destinationViewController;
    controller.username = self.username;
    controller.password = self.password;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
