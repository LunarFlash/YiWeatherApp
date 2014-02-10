//
//  YIDailyForecast.m
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIWXDailyForecast.h"

@implementation YIWXDailyForecast

// The daily forecast data returned from the API has a slightly different structure vs current conditions
+ (NSDictionary *) JSONKeyPathsByPropertyKey
{
    // Get YIWXCondition's map and create a mutable copy of it
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    // Change the max and min key maps for daily forecast
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    return paths;
}

@end
