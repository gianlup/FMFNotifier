//
//  FMFNotifier.mm
//  FMFNotifier
//
//  Created by Gianluca Puglia on 21/02/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

/* TODO:
 * Rendere sicura password
 * Traduzione dylib
 * Non resettare le pref ad ogni installazione
 */

#import "CaptainHook/CaptainHook.h"
#import "KeychainItemWrapper.h"
#import "Notifier.h"

CHDeclareClass(BBServer);
CHDeclareClass(AOSFindBaseServiceProvider);
CHDeclareClass(FMF3PasswordLoginViewController);

CHOptimizedMethod(3, self, void, AOSFindBaseServiceProvider, ackLocateCommand, id, arg1, withStatusCode, int, arg2, andStatusMessage, id, arg3) {
    //NSLog(@"FMF: ackLocateCommand:withStatusCode:andStatusMessage");
    CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(darwin, CFSTR("com.pgl.fmnotifier.requestedLocation"), NULL, NULL, true);
    CHSuper(3, AOSFindBaseServiceProvider, ackLocateCommand, arg1, withStatusCode, arg2, andStatusMessage, arg3);
}

CHOptimizedMethod(1, self, void, FMF3PasswordLoginViewController, appDidBecomeActive, id, arg1) {
    CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(darwin, CFSTR("com.pgl.fmnotifier.pw"), NULL, NULL, true);
    
    UITextField *tf = CHIvar(self, _passwordTextField, UITextField*);
    while (1) {
        NSMutableDictionary *prefs=[NSMutableDictionary dictionaryWithContentsOfFile:PreferencesPath];
        if (prefs) {
            if ([prefs objectForKey:@"password"]) {
                NSLog(@"---pw--- %@",[prefs objectForKey:@"password"]);
                [tf setText:[prefs objectForKey:@"password"]];
                [tf becomeFirstResponder];
                [prefs removeObjectForKey:@"password"];
                [prefs writeToFile:PreferencesPath atomically:YES];
                break;
            }
        }
        usleep(1000);
    }
    CHSuper(1, FMF3PasswordLoginViewController, appDidBecomeActive, arg1);
}

//CHOptimizedMethod(3, self, void, BBServer, publishBulletinRequest, id, arg1, destinations, unsigned int, arg2, alwaysToLockScreen, BOOL, arg3) {
//    NSLog(@"!!! publishBulletinRequest: destinations:%u lock:%i",arg2,arg3);
//    CHSuper(3, BBServer, publishBulletinRequest, arg1, destinations, arg2, alwaysToLockScreen, arg3);
//}

static BBServer *BulletinBoardServer;

CHClassMethod(0, BBServer *, BBServer, sharedServer) {
    return BulletinBoardServer;
}

CHOptimizedMethod(0, self, id, BBServer, init) {
    self = CHSuper(0, BBServer, init);
    if (self) {
        BulletinBoardServer = self;
    }
    return self;
}

static void requestedLocationNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"------ requestedLocationNotification");
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
    if (prefs) {
        NSDate *oldDate = [prefs objectForKey:@"lastDateFMAlertItem"];
        NSDate *actualDate = [NSDate date];
        if (!oldDate) {
            Notifier *notifier = [Notifier sharedInstance];
            [notifier showNotificationWithTitle:@"FMFNotifier"
                                        message:@"Someone has requested your location through the app Find My Friends."
                                       bundleID:@"com.apple.mobileme.fmf1"];
            
            [prefs setObject:actualDate forKey:@"lastDateFMAlertItem"];
            [prefs writeToFile:PreferencesPath atomically:YES];
        }
        NSTimeInterval ti = [actualDate timeIntervalSinceDate:oldDate];
        if (ti >= 60) {
            Notifier *notifier = [Notifier sharedInstance];
            [notifier showNotificationWithTitle:@"FMFNotifier"
                                        message:@"Someone has requested your location through the app Find My Friends."
                                       bundleID:@"com.apple.mobileme.fmf1"];
            
            [prefs setObject:actualDate forKey:@"lastDateFMAlertItem"];
            [prefs writeToFile:PreferencesPath atomically:YES];
        }
    }
}

static void pwNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (!objc_getClass("SBAlertItemsController")) {
        return;
    }
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FMFNotifier" accessGroup:nil];
    NSString *value = [keychainItem objectForKey:(__bridge id)kSecValueData];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
    [prefs setObject:value forKey:@"password"];
    [prefs writeToFile:PreferencesPath atomically:YES];
}

CHConstructor {
	@autoreleasepool {
        NSLog(@"FMF: CHConstructor");
        
        CHLoadLateClass(BBServer);
        CHHook(0, BBServer, init);
        CHHook(0, BBServer, sharedServer);
//      CHHook(3, BBServer, publishBulletinRequest, destinations, alwaysToLockScreen);
        
		CHLoadLateClass(AOSFindBaseServiceProvider);
        CHHook(3, AOSFindBaseServiceProvider, ackLocateCommand, withStatusCode, andStatusMessage);
        
        CHLoadLateClass(FMF3PasswordLoginViewController);
        CHHook(1, FMF3PasswordLoginViewController, appDidBecomeActive);
        
        CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(darwin, NULL, requestedLocationNotification, CFSTR("com.pgl.fmnotifier.requestedLocation"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        CFNotificationCenterAddObserver(darwin, NULL, pwNotification, CFSTR("com.pgl.fmnotifier.pw"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}

