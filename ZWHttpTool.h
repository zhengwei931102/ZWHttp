//
//  ZWHttpTool.h
//  TaiKangDoctor
//
//  Created by zw on 2019/5/12.
//  Copyright © 2019 zw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZWHttpTool : NSObject
@property(strong,nonatomic) AFHTTPSessionManager * sessionManager;
+(ZWHttpTool *) defaultHttpTool;
+(AFHTTPSessionManager *)createSessionManagerWithUrl:(NSString *)url;
+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
+ (void)postWithLoading:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
