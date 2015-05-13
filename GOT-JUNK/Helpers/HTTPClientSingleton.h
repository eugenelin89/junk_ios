//
//  HTTPClientSingleton.h
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "AFHTTPClient.h"

@interface HTTPClientSingleton : AFHTTPClient

+(HTTPClientSingleton *)sharedInstance;

-(void)setHeaderUsername:(NSString*)un andPassword:(NSString*)pw;
-(void)clearUsernameAndPassword;

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
