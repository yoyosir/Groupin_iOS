//
//  MyAnnotation.m
//  GroupIn
//
//  Created by Zheng Yong on 2/26/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "MyAnnotation.h"


@interface MyAnnotation()
@property(nonatomic) CLLocationCoordinate2D coordinate;

@end
@implementation MyAnnotation
@synthesize coordinate = _coordinate;
@synthesize draggable = _draggable;
@synthesize title = _title;
@synthesize subTitle = _subTitle;


-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    _coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

@end