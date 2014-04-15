//
//  GroupChatViewController.h
//  GroupIn
//
//  Created by Zheng Yong on 3/30/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"

@interface GroupChatViewController : UIViewController

- (void)setRawData:(NSData *)rawData
              user:(NSString *)username
          password:(NSString *)password
             group:(NSString *)groupname
          passcode:(NSString *)passcode;

@end
