//
//  MyGroupViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 3/30/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "MyGroupViewController.h"
#import "GroupChatViewController.h"

@interface MyGroupViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* groups;
@property (strong, nonatomic) NSString* groupname;
@property (strong, nonatomic) NSString* passcode;
@property (strong, nonatomic) NSData* rawData;

@end

@implementation MyGroupViewController

@synthesize groupname = _groupname;
@synthesize passcode = _passcode;
@synthesize groups = _groups;
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/mygroup"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    self.groups = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"My groups";
    [self loadTableData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview
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
    //NSLog(@"%@", self.groups);
    NSDictionary* dic = [self.groups objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic valueForKey:@"groupname"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.groupname = [[self.groups objectAtIndex:indexPath.row] valueForKey:@"groupname"];
    self.passcode =[[self.groups objectAtIndex:indexPath.row] valueForKey:@"passcode"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/retrievemessage"]];
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
        NSLog(@"%@", responseString);
        [self performSegueWithIdentifier:@"fromMyGroupToChat" sender:self];
    }

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[segue.destinationViewController setRawData:self.rawData user:self.username password:self.password group:self.groupname passcode:self.passcode];
}


@end
