//
//  ViewGroupsViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 3/29/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "ViewGroupsViewController.h"
#import "GroupChatViewController.h"

@interface ViewGroupsViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSData *rawData;
@property (strong, nonatomic) NSString *groupname;
@property (strong, nonatomic) NSString *passcode;
@property (strong, nonatomic) UIAlertView* createGroupAlert;


@end

@implementation ViewGroupsViewController

@synthesize groups = _groups;
@synthesize rawData = _rawData;
@synthesize groupname = _groupname;
@synthesize passcode = _passcode;
@synthesize createGroupAlert = _createGroupAlert;
@synthesize username = _username;
@synthesize password = _password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadTableData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/searchgroup"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    self.groups = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    
    
    NSLog(@"%@,Done", self.groups);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTableData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/createuser"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    [dic setValue:self.username forKey:@"nickname"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"data:%@\n", [[NSString alloc] initWithData:data encoding:4]);
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"create user respond:%@", responseString);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createGroup)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)createGroup
{
    self.createGroupAlert = [[UIAlertView alloc] initWithTitle:@"Create Group" message:@"Enter group name and passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    [self.createGroupAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[self.createGroupAlert textFieldAtIndex:0] setPlaceholder:@"Group name"];
    [[self.createGroupAlert textFieldAtIndex:1] setPlaceholder:@"Passcode"];
    [self.createGroupAlert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupMember";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSLog(@"%@", self.groups);
    NSDictionary* dic = [self.groups objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic valueForKey:@"groupname"];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Passcode" message:@"Enter passcode:" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"OK", nil];
    self.groupname = [[self.groups objectAtIndex:indexPath.row] valueForKey:@"groupname"];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;

    [alertView show];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma alert view

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.createGroupAlert)
    {
        if (buttonIndex == 1)
        {
            self.groupname = [alertView textFieldAtIndex:0].text;
            self.passcode = [alertView textFieldAtIndex:1].text;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/creategroup"]];
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            [dic setValue:self.username forKey:@"username"];
            [dic setValue:self.password forKey:@"password"];
            [dic setValue:self.groupname forKey:@"groupname"];
            [dic setValue:self.passcode forKey:@"passcode"];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSHTTPURLResponse* urlResponse = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"create group respond:%@", responseString);
            [self enterGroup];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            self.passcode = [alertView textFieldAtIndex:0].text;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/joingroup"]];
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            [dic setValue:self.username forKey:@"username"];
            [dic setValue:self.password forKey:@"password"];
            [dic setValue:self.groupname forKey:@"groupname"];
            [dic setValue:self.passcode forKey:@"passcode"];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSHTTPURLResponse* urlResponse = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"join group:%@", responseString);
            [self enterGroup];
        }
    }
}

-(void)enterGroup
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/retrievemessage"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    [dic setValue:self.groupname forKey:@"groupname"];
    [dic setValue:self.passcode forKey:@"passcode"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    if ([responseString isEqualToString:@"invalid passcode"] || [responseString isEqualToString:@"denied"])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Denied" message:responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        self.rawData = responseData;
        [self performSegueWithIdentifier:@"segueToChat" sender:self];
    }
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setRawData:self.rawData user:self.username password:self.password group:self.groupname passcode:self.passcode];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
