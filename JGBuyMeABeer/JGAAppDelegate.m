//
//  JGAAppDelegate.m
//  JGBuyMeABeer
//
//  Created by John Grant on 2014-03-06.
//  Copyright (c) 2014 John Grant. All rights reserved.
//

#import "JGAAppDelegate.h"
@import CoreLocation;

@interface JGAAppDelegate () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UILocalNotification *notification;
@end

static NSString * beaconRegionUUID = @"E132EBAE-AB52-4ABD-B6A8-6B7C65BA407D";
static NSString * beaconRegionIdentifier = @"ca.jg.buymeabeer";

# define BEACON_MAJOR 1
# define BEACON_MINOR 3

@implementation JGAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconRegionUUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                     major:BEACON_MAJOR
                                                                     minor:BEACON_MINOR
                                                                identifier:beaconRegionIdentifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;

    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager requestStateForRegion:region];
    
    return YES;
}
							
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"state: %d", state);
    
    if (state == CLRegionStateInside) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }else if (state == CLRegionStateOutside) {
        [self hideNotification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:beaconRegionIdentifier]) {
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:beaconRegionIdentifier]) {
            [self hideNotification];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        NSLog(@"ranging beacon....%@", beacon);
        if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate) {
            [self showNotification];
        }else{
            [self hideNotification];
        }
    }
}

- (void)showNotification
{
    NSLog(@"here");
    if (!self.notification && [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        
        NSLog(@"creating");
        self.notification = [[UILocalNotification alloc] init];
        self.notification.alertBody = @"HEY YOU! You're passing my desk! Bring me a beer next time!";
        self.notification.alertAction = @"I'm on it";
        self.notification.soundName = @"horn.caf";
        NSLog(@"showing");
        [[UIApplication sharedApplication] presentLocalNotificationNow:self.notification];
    }
}

- (void)hideNotification
{
    if (self.notification) {
        NSLog(@"cancelling");
        [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
        self.notification = nil;        
    }
}



@end
