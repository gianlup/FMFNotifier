//
//  FMFNotifierBundleController.m
//  FMFNotifier
//
//  Created by Gianluca Puglia on 21/02/14.
//  Copyright (c) 2014 Gianluca Puglia. All rights reserved.
//

#import "FMFNotifierBundleController.h"
#import <Preferences/PSSpecifier.h>

#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=A9SZH59ARLTLA&lc=IT&item_name=FMFNotifier&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"
#define kUrl_MakeEmail @"mailto:gianluca.puglia@gmail.com?subject=FMFNotifier"

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_Key @"key"
#define kPrefs_Defaults @"defaults"

@implementation FMFNotifierBundleController

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
    NSLog(@"[FMFNotifierBundleController] - getValueForSpecifier");
    
	id value = nil;
    NSDictionary *specifierProperties = [specifier properties];
    NSString *specifierKey = [specifierProperties objectForKey:kPrefs_Key];
    NSString *plistPath = [[NSString alloc] initWithString:[specifierProperties objectForKey:kPrefs_Defaults]];
    plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, plistPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return value;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if ([specifierKey isEqualToString:@"minInterval"]) {
        id objectValue = [dict objectForKey:specifierKey];
        if (objectValue) {
            value = [NSString stringWithFormat:@"%@", objectValue];
            NSLog(@"Read key '%@' with value '%@'.", specifierKey, value);
        }
        else {
            NSLog(@"key '%@' not found.", specifierKey);
        }
        return value;
    }
	return nil;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier {
    NSLog(@"[FMFNotifierBundleController] - setValue:forSpecifier");
    
	NSDictionary *specifierProperties = [specifier properties];
    NSString *specifierKey = [specifierProperties objectForKey:kPrefs_Key];
    NSString *plistPath = [[NSString alloc] initWithString:[specifierProperties objectForKey:kPrefs_Defaults]];
    plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, plistPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if ([specifierKey isEqualToString:@"minInterval"]) {
        [dict setObject:value forKey:specifierKey];
        [dict writeToFile:plistPath atomically:YES];
        NSLog(@"saved key '%@' with value '%@'.", specifierKey, value);
    }
    return;
}

- (void)makeEmail:(PSSpecifier*)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeEmail]];
}

- (void)makeDonation:(PSSpecifier *)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"FMFNotifier" target:self];
    }
    return _specifiers;
}

- (id)init {
    NSLog(@"[FMFNotifierBundleController] - init");
	if ((self = [super init])) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:PreferencesPath]) {
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"rememberPassword"];
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"notificationEnabled"];
            [prefs setObject:[NSNumber numberWithFloat:60.0] forKey:@"minInterval"];
            [prefs setObject:@"Someone has requested your location through Find My Friends app." forKey:@"en"];
            [prefs setObject:@"Qualcuno ha richiesto la tua posizione attraverso l'app Trova Amici." forKey:@"it"];
            [prefs writeToFile:PreferencesPath atomically:YES];
        }
//        else {
//            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PreferencesPath];
//            [prefs setObject:@"Someone has requested your location through Find My Friends app." forKey:@"en"];
//            [prefs setObject:@"Qualcuno ha richiesto la tua posizione attraverso l'app Trova Amici." forKey:@"it"];
//            [prefs writeToFile:PreferencesPath atomically:YES];
//        }
	}
	return self;
}

@end