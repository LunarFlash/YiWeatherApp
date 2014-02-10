//
//  YIWXClient.h
//  YiWeather
//
//  Created by Yi Wang on 2/8/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

/*
 WXClient‘s sole responsibility is to create API requests and parse them; someone else can worry about what to do with the data and how to store it. The design pattern of dividing different types of work between classes is called separation of concerns. This makes your code much easier to understand, extend, and maintain.
 */
//  @import directive before was introduced with Xcode 5 and is viewed by Apple as a modern, more efficient replacement to #import. There’s a great tutorial that covers the new features of Objective-C in What’s New in Objective-C and Foundation in iOS 7.
//  http://www.raywenderlich.com/49850/whats-new-in-objective-c-and-foundation-in-ios-7

//#import <Foundation/Foundation.h>
@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>


@interface YIWXClient : NSObject


- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

/*
 Uhhh... What is RACSignal????
 ReactiveCocoa (RAC) is an Objective-C framework for Functional Reactive Programming that provides APIs for composing and transforming streams of values. Instead of focusing on writing serial code — code that executes in an orderly sequence — your code can react to nondeterministic events.
 
 The RACSignal object captures present and future values. Signals can be chained, combined, and reacted to by observers. A signal won’t actually perform any work until it is subscribed to.
 
 That means calling [mySignal fetchCurrentConditionsForLocation:someLocation]; won’t do anything but create and return a signal. You’ll see how to subscribe and react later on.
*/

@end
