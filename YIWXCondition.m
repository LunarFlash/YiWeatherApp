//
//  YIWXCondition.m
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIWXCondition.h"
#define MPS_TO_MPH 2.23694f

@implementation YIWXCondition

+ (NSDictionary *) imageMap
{
    // 1 Create a static NSDictionary since every instance if YIWXCondition will use the same data mapper
    static NSDictionary *_imageMap = nil;
    if (!_imageMap) {
        //  2 Map the condition codes to an image file (e.g. "01d" to "weather-clear.pgn")
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

// 3 Declare public message to get an image name
- (NSString *)imageName
{
    return [YIWXCondition imageMap][self.icon];
}

#pragma mark MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // dictionary key is YIWXCOndition's property name, dictionary value is keypath from the JSON
    // Sample return http://api.openweathermap.org/data/2.5/weather?lat=37.785834&lon=-122.406417&units=imperial
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

#pragma mark Mantle Transformers
+(NSValueTransformer *)dateJSONTransformer
{
    // return a MTLValueTransformer using blocks to transform values to and from Objective-C properties
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
     } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

// Only need to detail how to convert betwn Unix time and NSDate once, just reuse - dateJSONTransformer for sunrise/sunset
+ (NSValueTransformer *)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+(NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}



@end
