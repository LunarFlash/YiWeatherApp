//
//  YIWXManager.m
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIWXManager.h"
#import "YIWXClient.h"
#import <TSMessages/TSMessage.h>

@interface YIWXManager ()

// Declare the same properties but as readwrite so we can handle these properties locally
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) YIWXCondition *currentCondition;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// A few other properties for location finding and data fetching
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) YIWXClient *client;

@end



@implementation YIWXManager

// Singleton constructor
+ (instancetype)sharedManager
{
    static id _sharedManager;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


// overload constructor
- (id) init
{
    if (self = [super init]) {
        // Create location manager and set delegate to self
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // Create a YIWXClient object for the manager. This handles all network and data parsing, following seperation of convern design pattern
        _client = [[YIWXClient alloc] init];
        
        // The manager observes the currentLocation key on itself using a ReactiveCocoa macro which returns a signal. This is similar to Key-Value Observing but is far more powerful.
        [[[[RACObserve(self, currentLocation)
         //In order to continue down the method chain, currentLocation must not be nil.
         ignore:nil]
           
         // -flattenMap: is very similar to -map:, but instead of mapping each value, it flattens the values and returns one object containing all three signals. In this way, you can consider all three processes as a single unit of work.
         // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               
            // Deliver the sigal to subscribers on the main thread
        }] deliverOn: RACScheduler.mainThreadScheduler]
        
        // It's not good pratice to interact with the UI from inside your model, but fo demonstration puporses well display a banner whenever an error occcurs
        subscribeError:^(NSError *error) {
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the latest weather." type:TSMessageNotificationTypeError];
            
        }];
        
    }
    return self;
}


#pragma mark Update current location
- (void) findCurrentLocation
{
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Always ignore the first location update because it is almost always cached
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // Once we have a location with the proper accuracy, stop further updates
    if (location.horizontalAccuracy > 0) {
        // Setting the currentLocation key triggers the RACObservable we set earlier in the init implmentation
        
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma fetch methods
- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(YIWXCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast
{
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast
{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}


@end
