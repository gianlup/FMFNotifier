//
//  FMFNotifier.mm
//  FMFNotifier
//
//  Created by Gianluca Puglia on 21/02/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "CaptainHook/CaptainHook.h"
#import "KeychainItemWrapper.h"
#import "Notifier.h"

CHDeclareClass(BBServer);
CHDeclareClass(AOSFindBaseServiceProvider);
CHDeclareClass(FMF3PasswordLoginViewController);

CHOptimizedMethod(3, self, void, AOSFindBaseServiceProvider, ackLocateCommand, id, arg1, withStatusCode, int, arg2, andStatusMessage, id, arg3) {
    NSString *ackURL = [(NSDictionary *)arg1 objectForKey:@"ackURL"];
    if ([ackURL rangeOfString:@"fmf"].location != NSNotFound && [ackURL rangeOfString:@"findme"].location == NSNotFound) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
        if (prefs) {
            NSNumber *nE = [prefs objectForKey:@"notificationEnabled"];
            if ([nE boolValue]) {
                CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
                CFNotificationCenterPostNotification(darwin, CFSTR("com.pgl.fmnotifier.requestedLocation"), NULL, NULL, true);
            }
            [prefs release];
        }
    }
    CHSuper(3, AOSFindBaseServiceProvider, ackLocateCommand, arg1, withStatusCode, arg2, andStatusMessage, arg3);
}

CHOptimizedMethod(0, self, void, FMF3PasswordLoginViewController, performUserPasswordAuth) {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
    if (prefs) {
        NSNumber *rP = [prefs objectForKey:@"rememberPassword"];
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FMFNotifier" accessGroup:nil];
        if ([rP boolValue]) {
            UITextField *tf = CHIvar(self, _passwordTextField, UITextField*);
            [keychainItem setObject:tf.text forKey:(__bridge id)kSecValueData];
        }
        else {
            [keychainItem resetKeychainItem];
        }
        [keychainItem release];
        [prefs release];
    }
    CHSuper(0, FMF3PasswordLoginViewController, performUserPasswordAuth);
}

CHOptimizedMethod(1, self, void, FMF3PasswordLoginViewController, appDidBecomeActive, id, arg1) {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
    if (prefs) {
        NSNumber *rP = [prefs objectForKey:@"rememberPassword"];
        if ([rP boolValue]) {
            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FMFNotifier" accessGroup:nil];
            NSString *pw = [keychainItem objectForKey:(__bridge id)kSecValueData];
            UITextField *tf = CHIvar(self, _passwordTextField, UITextField*);
            [tf setText:pw];
            [tf becomeFirstResponder];
            [keychainItem release];
        }
        [prefs release];
    }
    CHSuper(1, FMF3PasswordLoginViewController, appDidBecomeActive, arg1);
}

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

static void requestedLocNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (!objc_getClass("SpringBoard")) {
        return;
    }
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesPath];
    if (prefs) {
        NSString *languageId = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *localizedMessage = [prefs objectForKey:languageId];
        if (localizedMessage == nil) {
            localizedMessage = @"Someone has requested your location through Find My Friends app.";
        }
        
        NSDate *oldDate = [prefs objectForKey:@"lastDateFMAlertItem"];
        NSDate *actualDate = [NSDate date];
        if (!oldDate) {
            Notifier *notifier = [Notifier sharedInstance];
            [notifier showNotificationWithTitle:@"FMFNotifier"
                                        message:localizedMessage
                                       bundleID:@"com.apple.mobileme.fmf1"];
            
            [prefs setObject:actualDate forKey:@"lastDateFMAlertItem"];
            [prefs writeToFile:PreferencesPath atomically:YES];
        }
        
        NSTimeInterval ti = [actualDate timeIntervalSinceDate:oldDate];
        NSTimeInterval minTi = [[prefs objectForKey:@"minInterval"] floatValue];
        if (ti >= minTi) {
            Notifier *notifier = [Notifier sharedInstance];
            [notifier showNotificationWithTitle:@"FMFNotifier"
                                        message:localizedMessage
                                       bundleID:@"com.apple.mobileme.fmf1"];
            
            [prefs setObject:actualDate forKey:@"lastDateFMAlertItem"];
            [prefs writeToFile:PreferencesPath atomically:YES];
        }
        [prefs release];
    }
}

CHConstructor {
	@autoreleasepool {
        NSLog(@"FMF: CHConstructor");
        CHLoadLateClass(BBServer);
        CHHook(0, BBServer, init);
        CHHook(0, BBServer, sharedServer);
        
		CHLoadLateClass(AOSFindBaseServiceProvider);
        CHHook(3, AOSFindBaseServiceProvider, ackLocateCommand, withStatusCode, andStatusMessage);
        
        CHLoadLateClass(FMF3PasswordLoginViewController);
        CHHook(1, FMF3PasswordLoginViewController, appDidBecomeActive);
        CHHook(0, FMF3PasswordLoginViewController, performUserPasswordAuth);
        
        CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(darwin, NULL, requestedLocNotification, CFSTR("com.pgl.fmnotifier.requestedLocation"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}

