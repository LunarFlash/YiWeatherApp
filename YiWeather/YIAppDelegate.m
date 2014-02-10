//
//  YIAppDelegate.m
//  YiWeather
//
//  Created by Yi Wang on 2/3/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//  http://www.raywenderlich.com/55384/ios-7-best-practices-part-1
//  http://www.raywenderlich.com/55386/ios-7-best-practices-part-2

#import "YIAppDelegate.h"
#import "YIWXController.h"
#import <TSMessage.h>  // Importing from other projects in the workspace, we use angle brackets instead of quotes.


@implementation YIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // 1  Initialize and set the WXController instance as the application’s root view controller. Usually this controller is a UINavigationController or UITabBarController, but in this case you’re using a single instance of WXController.
    self.window.rootViewController = [[YIWXController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    // 2  Set the default view controller to display your TSMessages. By doing this, you won’t need to manually specify which controller to use to display alerts.
    [TSMessage setDefaultViewController: self.window.rootViewController];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
