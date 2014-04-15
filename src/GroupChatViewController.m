//
//  GroupChatViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 3/30/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "GroupChatViewController.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "UIBubbleTableViewDataSource.h"

@interface GroupChatViewController () <UIBubbleTableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (strong, nonatomic) NSMutableArray* bubbleData;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* groupname;
@property (strong, nonatomic) NSString* passcode;
@end

@implementation GroupChatViewController

@synthesize bubbleData = _bubbleData;
@synthesize username = _username;
@synthesize password = _password;
@synthesize groupname = _groupname;
@synthesize passcode = _passcode;

- (void)setRawData:(NSData *)rawData
              user:(NSString *)username
          password:(NSString *)password
             group:(NSString *)groupname
          passcode:(NSString *)passcode
{
    self.username = username;
    self.password = password;
    self.groupname = groupname;
    self.passcode = passcode;
	NSArray* array = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:nil];
    self.bubbleData = [[NSMutableArray alloc] init];
    for (NSDictionary* dic in array)
    {
        NSBubbleData *heyBubble;
        NSLog(@"%@", [dic valueForKey:@"content"]);
        if ([[dic valueForKey:@"username"] isEqualToString:self.username])
        {
            heyBubble = [NSBubbleData dataWithText:[dic valueForKey:@"content"] date:[NSDate dateWithTimeIntervalSince1970:[[dic valueForKey:@"time"] doubleValue] / 1000] type:BubbleTypeMine];
        }
        else
        {
            heyBubble = [NSBubbleData dataWithText:[dic valueForKey:@"content"] date:[NSDate dateWithTimeIntervalSince1970:[[dic valueForKey:@"time"] doubleValue] / 1000] type:BubbleTypeSomeoneElse];
        }
        if ([[dic valueForKey:@"username"] isEqualToString:@"yoyosir1"])
        {
            heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
        }
        else
        {
            heyBubble.avatar = [UIImage imageNamed:@"avatar2.png"];
        }
        [self.bubbleData addObject:heyBubble];
    }
}

- (void)updateTableDataWithResponse:(NSData*)response
{
    [self setRawData:response user:self.username password:self.password group:self.groupname passcode:self.passcode];
    [self.bubbleTable reloadData];
}

- (void)updateData
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
        [self performSelectorOnMainThread:@selector(updateTableDataWithResponse:) withObject:responseData waitUntilDone:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)selectPhoto
{
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
    /*
    NSData* imageData = UIImagePNGRepresentation([UIImage imageNamed:@"avatar1.png"]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/uploadimage"]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:@"1.0" forKey:@"ver"];
    [_params setObject:@"en" forKey:@"lan"];
    //[_params setObject:[NSString stringWithFormat:@"%@", self.username] forKey:@"username"];
    //[_params setObject:[NSString stringWithFormat:@"%@", self.groupname] forKey:@"groupname"];
    //[_params setObject:[NSString stringWithFormat:@"%@", @"hi"] forKey:@"title"];
    //NSData* data = [NSJSONSerialization dataWithJSONObject:_params options:NSJSONWritingPrettyPrinted error:nil];

    
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //[body appendData:data];
    
    NSString* FileParamConstant = @"file";
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"avatar1.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseString);
     */
    // set URL
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.groupname;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(selectPhoto)];
    self.bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    self.bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    self.bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    
    [self.bubbleTable reloadData];
    
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    //[self updateData];
    [NSThread detachNewThreadSelector:@selector(backgroupUpdate) toTarget:self withObject:nil];
    
}

- (void)backgroupUpdate
{
    while (true)
    {
        [self updateData];
        [NSThread sleepForTimeInterval:2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [self.bubbleData objectAtIndex:row];
}

#pragma mark - UIImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSBubbleData* sayBubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [self.bubbleData addObject:sayBubble];
    if ([self.username isEqualToString:@"yoyosir1"])
    {
        sayBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    }
    [self.bubbleTable reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = self.textInputView.frame;
        frame.origin.y -= kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.bubbleTable.frame;
        frame.size.height -= kbSize.height;
        self.bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = self.textInputView.frame;
        frame.origin.y += kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.bubbleTable.frame;
        frame.size.height += kbSize.height;
        self.bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions

- (IBAction)sayPressed:(id)sender
{
    self.bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    /*
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:self.textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [self.bubbleData addObject:sayBubble];
    [self.bubbleTable reloadData];
    */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/sendmessage"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    [dic setValue:self.passcode forKey:@"passcode"];
    [dic setValue:self.groupname forKey:@"groupname"];
    [dic setValue:self.textField.text forKey:@"content"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];

    
    self.textField.text = @"";
    [self.textField resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
