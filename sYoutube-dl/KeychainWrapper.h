//
//  KeychainWrapper.h
//  sYoutube-dl
//
//  Created by Yannis on 04/12/2016.
//  Copyright © 2016 isklikas. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KeychainWrapper : NSObject {
    NSMutableDictionary        *keychainData;
    NSMutableDictionary        *genericPasswordQuery;
}

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)mySetObject:(id)inObject forKey:(id)key;
- (id)myObjectForKey:(id)key;
- (void)resetKeychainItem;

@end
