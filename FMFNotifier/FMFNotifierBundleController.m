//
//  FMFNotifierBundleController.m
//  FMFNotifier
//
//  Created by Gianluca Puglia on 21/02/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FMFNotifierBundleController.h"
#import <Preferences/PSSpecifier.h>

#define kSetting_TemplateVersion_Name @"TemplateVersionExample"
#define kSetting_TemplateVersion_Value @"1.0"

#define kUrl_FollowOnTwitter @"https://twitter.com/kokoabim"
#define kUrl_VisitWebSite @"http://iosopendev.com"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=56KLKJLXKM9FS"

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_Key @"key"
#define kPrefs_Defaults @"defaults"

@implementation FMFNotifierBundleController

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
    NSLog(@"[FMFNotifierBundleController] - getValueForSpecifier");
    
	id value = nil;
    NSDictionary *specifierProperties = [specifier properties];
    NSString *specifierKey = [specifierProperties objectForKey:kPrefs_Key];
    
    //Only from Code
    if ([specifierKey isEqual:kSetting_TemplateVersion_Name]) {
		value = kSetting_TemplateVersion_Value;
        return value;
	}
    
    //From plist
    NSString *plistPath = [[NSString alloc] initWithString:[specifierProperties objectForKey:kPrefs_Defaults]];
    plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, plistPath];
    if (plistPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            return value;
        }
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        id objectValue = [dict objectForKey:specifierKey];
        if (objectValue) {
            value = [NSString stringWithFormat:@"%@", objectValue];
            NSLog(@"read key '%@' with value '%@' from plist '%@'", specifierKey, value, plistPath);
        }
        else {
            NSLog(@"key '%@' not found in plist '%@'", specifierKey, plistPath);
        }
    }
	return value;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier {
    NSLog(@"[FMFNotifierBundleController] - setValue:forSpecifier");
    
	NSDictionary *specifierProperties = [specifier properties];
    NSString *specifierKey = [specifierProperties objectForKey:kPrefs_Key];
    NSString *plistPath = [[NSString alloc] initWithString:[specifierProperties objectForKey:kPrefs_Defaults]];
    plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, plistPath];
    if (plistPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            return;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        [dict setObject:value forKey:specifierKey];
        [dict writeToFile:plistPath atomically:YES];
        NSLog(@"saved key '%@' with value '%@' to plist '%@'", specifierKey, value, plistPath);
    }
}

- (void)followOnTwitter:(PSSpecifier*)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)visitWebSite:(PSSpecifier*)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_VisitWebSite]];
}

- (void)makeDonation:(PSSpecifier *)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"FMFNotifier" target:self] retain];
    }
    return _specifiers;
}

- (id)init {
    NSLog(@"[FMFNotifierBundleController] - init");
	if ((self = [super init])) {
        
	}
	return self;
}

@end