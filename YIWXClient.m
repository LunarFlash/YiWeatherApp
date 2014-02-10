//
//  YIWXClient.m
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIWXClient.h"
#import "YIWXCondition.h"
#import "YIWXDailyForecast.h"

@interface YIWXClient ()

@property (nonatomic, strong) NSURLSession *session;

@end


@implementation YIWXClient


- (id) init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

// For more information about reactive cocoa, check this post http://www.teehanlax.com/blog/getting-started-with-reactivecocoa/
// This method is going to power our other fetch methods
- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@", url.absoluteString);
    
    
    // returns signal, will not execute until this signal is subscribed to. fetchJSONFromURL: creates an object for other methods and obejcts to use. This behavior is sometimes called factory pattern.
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // Creates an NSURLSessionDataTask (new in iOS7) to fetch data from the URL. We will parse this ish later.
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // Handle retirved data
            
            if (!error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    // When JSON data exists and no errors, send subscriber to JSON seriaized as either an array or dictionary
                    [subscriber sendNext:json];
                    
                } else {
                    // There is an error serializing json, notify subscriber
                    [subscriber sendError:jsonError];
                }
            } else {
                // if there is an error handling data task, notify subscriber
                [subscriber sendError:error];
            }
            
            // Whether the request passed or failed, let subscriber know request has completed
            [subscriber sendCompleted];
            
            
            
        }];
        
        // Starts network request once someone subscribtes to the singal
        [dataTask resume];
        
        // Creates and returns an RACDisposable obejct which handles and cleanup when the signal when it is destroyed
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
        
    }] doError:^(NSError *error) {
        // Addds a side effect to log any errors that occur. Side effects don't subscribe to the signal; rather, they return the signal to which they're attached for method chaining. We are simply adding the side effect that logs on error
        NSLog(@"%@", error);
    }];
    
}


- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    // Format the URL from a CLLocationCoordinate2D obejct using lat and long
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the method we just built to create the signal. Since the return val is a signal, we can call other ReactiveCocoa methods on it. Here we map the returned value - an instance of NSDictionary into a different value
    return [[self fetchJSONFromURL:url] map:^id(NSDictionary *json) {
        // use MTLJSONAdapter to onvert JSON into an YIWXCondition object, using the MTLJSONSerializing protocol we created in YIWXCondition
        return [MTLJSONAdapter modelOfClass:[YIWXCondition class] fromJSONDictionary:json error:nil];
    }];
    
    
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use fetchJSONFromURL again and map the JSON as appropriate. Note how much code we are saving by using this call woohoo!
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build RACSequence from the list key of the JSON. RACSequences let us perform reactive cocoa operations on lists
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Map the new list of objects. This calls - map: on each object in the list, reutrning a list of new obejcts
        return [[list map:^(NSDictionary *item) {
            // Use MTLJSONAdapter again to convert JSON to a YIWXCondition object
            return [MTLJSONAdapter modelOfClass:[YIWXCondition class] fromJSONDictionary:json error:nil];
            // Using -map on RacSequence returns another RacSequence, so use this convenience method to get the data as NSArray
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^id(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[YIWXDailyForecast class] fromJSONDictionary:json error:nil];
        }] array];
    }];    
}

@end
