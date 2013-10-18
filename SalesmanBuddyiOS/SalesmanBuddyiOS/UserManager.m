//
//  UserManager.m
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "UserManager.h"
#import "SFHFKeychainUtils.h"
#import "GTMOAuth2Authentication.h"

@implementation UserManager

// TODO add timeSinceChange to these fields

NSString *userTokenKeychainName = @"token";
NSString *userUsernameKeychainName = @"username";
NSString *userPasswordKeychainName = @"password";
NSString *serviceKeychainName = @"itemMapperV01";
NSString *blankKeychainString = @"No Token";

+(UserManager *)sharedManager{
    static UserManager *sharedManager;
    @synchronized(self){// this is if multiple threads do this at the exact same time
        if (!sharedManager) {
            sharedManager = [[UserManager alloc] init];
        }
        return sharedManager;
    }
}



-(BOOL)hasToken{
    // TODO check if token is expired
    return [self hasForUsername:userTokenKeychainName andService:serviceKeychainName];
}

-(NSString *)getToken{
    return [self getForUsername:userTokenKeychainName andService:serviceKeychainName];
}

-(BOOL)setToken:(NSString *)newToken{
    return [self setForUsername:userTokenKeychainName thePassword:newToken forService:serviceKeychainName];
}

-(BOOL)deleteToken{
    return [self deleteForUsername:userTokenKeychainName forService:serviceKeychainName];
}

-(BOOL)hasUsername{
    return [self hasForUsername:userUsernameKeychainName andService:serviceKeychainName];
}

-(NSString *)getUsername{
    return [self getForUsername:userUsernameKeychainName andService:serviceKeychainName];
}

-(BOOL)setUsername:(NSString *)newUsername{
    return [self setForUsername:userUsernameKeychainName thePassword:newUsername forService:serviceKeychainName];
}

-(BOOL)deleteUsername{
    return [self deleteForUsername:userUsernameKeychainName forService:serviceKeychainName];
}

-(BOOL)hasPassword{
    return [self hasForUsername:userPasswordKeychainName andService:serviceKeychainName];
}

-(NSString *)getPassword{
    return [self getForUsername:userPasswordKeychainName andService:serviceKeychainName];
}

-(BOOL)setPassword:(NSString *)newPassword{
    return [self setForUsername:userPasswordKeychainName thePassword:newPassword forService:serviceKeychainName];
}

-(BOOL)deletePassword{
    return [self deleteForUsername:userTokenKeychainName forService:serviceKeychainName];
}

-(BOOL)deleteEverything{
    NSError *error = nil;
    if ([SFHFKeychainUtils purgeItemsForServiceName:serviceKeychainName error:&error]) {
        return YES;
    }
    if (error) {
        NSLog(@"Delete everything error: %@, for service: %@", error.localizedDescription, serviceKeychainName);
    }
    return NO;
}

-(BOOL)hasForUsername:(NSString *)username andService:(NSString *)service{
    if ([[self getForUsername:username andService:service] isEqualToString:blankKeychainString]) {
        return false;
    }
    return true;
}

-(NSString *)getForUsername:(NSString *)username andService:(NSString *)service{
    NSError *error = nil;
    NSString *token = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:service error:&error];
    if (error) {
        NSLog(@"get error: %@, for username: %@, for service: %@", error.localizedDescription, username, service);
        return blankKeychainString;
    }
    return token;
}

-(BOOL)setForUsername:(NSString *)username thePassword:(NSString *)password forService:(NSString *)service{
    NSError *error = nil;
    if([SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:serviceKeychainName updateExisting:YES error:&error]){
        return YES;
    }
    if(error)
        NSLog(@"Setting error: %@, for username: %@, for password: %@, for service: %@, updateExisting: YES", error, username, password, service);
    return NO;
}

-(BOOL)deleteForUsername:(NSString *)username forService:(NSString *)service{
    NSError *error = nil;
    if ([SFHFKeychainUtils deleteItemForUsername:username andServiceName:service error:&error]) {
        return YES;
    }
    if (error) {
        NSLog(@"Delete error: %@, for username: %@, for service: %@", error.localizedDescription, username, service);
    }
    return NO;
}


@end





