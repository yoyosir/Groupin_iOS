//
//  MyAnnotation.h
//  GroupIn
//
//  Created by Zheng Yong on 2/26/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>
@property (nonatomic) BOOL draggable;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subTitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end