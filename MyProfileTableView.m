//
//  MyProfileTableView.m
//  GroupIn
//
//  Created by Zheng Yong on 2/23/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "MyProfileTableView.h"

@implementation MyProfileTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileTableCell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Username:";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Gender:";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Region:";
    }
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
