//
//  YIWXCondition.h
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>
//#import <MTLJSONAdapter.h>

// 1 The MJTJSONSerializing protocol tells Mantle serializer that this object has instuctions on how to map JSON to ObjC properties
@interface YIWXCondition : MTLModel <MTLJSONSerializing>

// 2 Weather data properties, we will only use a couple, but its nice to have access to all of them!
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

// 3 helper method to map weather condition to image files
- (NSString *)imageName;

@end
