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
#import <MobileCoreServices/MobileCoreServices.h>

@interface GroupInViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) UIAlertView* failAlert;
@end

@implementation GroupInViewController

@synthesize username = _username;
@synthesize password = _password;
@synthesize failAlert = _failAlert;

- (void)userImageClicked
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"Choose image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Photo", @"From library", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose image" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"From library", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    CGSize size;
    size.width = 100;
    size.height = 100;
    image = [GroupInViewController imageWithImage:image scaledToSize:size];
    self.imageView.image = image;
    NSData* imageData = UIImagePNGRepresentation(image);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1-dot-groupintemp.appspot.com/groupin/uploadavatar"]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:self.username forKey:@"username"];
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
    
    NSString* FileParamConstant = @"photo";
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"avatar1.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //[body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
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
    NSLog(@"response:%@", responseString);
}

//load user image
- (void)UesrImageClicked
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.failAlert)
    {
        [self showLoginAlert];
    }
    else
    {
        if (buttonIndex == 0)
        {
            self.username = [alertView textFieldAtIndex:0].text;
            self.password = [alertView textFieldAtIndex:1].text;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/login"]];
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            [dic setValue:self.username forKey:@"username"];
            [dic setValue:self.password forKey:@"password"];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSHTTPURLResponse* urlResponse = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            if (![responseString isEqualToString:@"success"])
            {
                self.failAlert = [[UIAlertView alloc] initWithTitle:@"Invalid username or password" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [self.failAlert show];
            }
        }
        else
        {
            self.username = [alertView textFieldAtIndex:0].text;
            self.password = [alertView textFieldAtIndex:1].text;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/createuser"]];
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            [dic setValue:self.username forKey:@"username"];
            [dic setValue:self.password forKey:@"password"];
            [dic setValue:self.username forKey:@"nickname"];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSHTTPURLResponse* urlResponse = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            if (![responseString isEqualToString:@"success"])
            {
                self.failAlert = [[UIAlertView alloc] initWithTitle:@"Username exists" message:responseString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [self.failAlert show];
            }
        }
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/getavatar"]];
        NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
        [dic setValue:self.username forKey:@"username"];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        NSHTTPURLResponse* urlResponse = nil;
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
        //NSLog(@"%@", responseData);
        if ([responseData length] < 100)
        {
            self.imageView.image = [UIImage imageNamed:@"missingAvatar.png"];
        }
        else
        {
            self.imageView.image = [[UIImage alloc] initWithData:responseData];
        }
        //NSLog(@"%f, %f", self.imageView.image.size.width, self.imageView.image.size.height);
    }
}

- (void)showLoginAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter group name and passcode" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Login", @"Signup", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"username"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"password"];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showLoginAlert];
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:self action:@selector(showLoginAlert)]];
    [self.navigationItem setTitle:@"GroupIn"];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"avatar" style:UIBarButtonItemStyleBordered target:self action:@selector(setting)]];
}

- (void)setting
{
	[self userImageClicked];
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
