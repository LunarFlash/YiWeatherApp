//
//  YIWXManager.h
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//  Follow Singleton design pattern http://www.raywenderlich.com/46988/ios-design-patterns
//  After finding the location, we fetches the appropriate weather data.

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "YIWXCondition.h"

// We are not importing YIWXForecast, because we will always use YIWXCondition as the forecast class. YIWXForecast class only exists to help Mantle transofrm JSON to obj-c

@interface YIWXManager : NSObject <CLLocationManagerDelegate>

// Use instancetype instead of YIWXManager so subclasses will return the appropriate type - key for Singleton design pattern
+ (instancetype)sharedManager;

// These properties will store our data, since YIWXManager is a Singleton, these properties will be accessible anywhere. Set public properties to readonly as only the manager should ever change these values privately.
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) YIWXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// Starts or refreshes the entire location and weather finding process
- (void)findCurrentLocation;


@end
