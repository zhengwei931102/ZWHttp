//
//  ZWHttpTool.m
//  TaiKangDoctor
//
//  Created by zw on 2019/5/12.
//  Copyright © 2019 zw. All rights reserved.
//

#import "ZWHttpTool.h"

@implementation ZWHttpTool
+(ZWHttpTool *) defaultHttpTool{
    static ZWHttpTool * s_Tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_Tool = [[ZWHttpTool alloc]init];
    });
    return s_Tool;
}

-(AFHTTPSessionManager *)sessionManager{
    if (_sessionManager == nil) {
        _sessionManager = [ZWHttpTool createSessionManagerWithUrl:TKDom];
    }
    return _sessionManager;
}

+(AFHTTPSessionManager *)createSessionManagerWithUrl:(NSString *)url
{
    //倒入证书
    //    NSString * cerPath = [[NSBundle mainBundle]pathForResource:@"aia" ofType:@"cer"];
    //    NSData * cerData =[NSData dataWithContentsOfFile:cerPath];
    //
    //    NSString * cerPath1 = [[NSBundle mainBundle]pathForResource:@"e" ofType:@"cer"];
    //    NSData * cerData1 =[NSData dataWithContentsOfFile:cerPath1];
    //
    //    NSString * cerPath2 = [[NSBundle mainBundle]pathForResource:@"aiaNew" ofType:@"cer"];
    //    NSData * cerData2 =[NSData dataWithContentsOfFile:cerPath2];
    
    //    AFHTTPSessionManager * sessionManager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager] ;
    sessionManager.requestSerializer.timeoutInterval = 60;
    
    // 配置https证书
    //    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[NSSet setWithObjects:cerData,cerData1,cerData2, nil]];
    //    if ([RBDom containsString:@"aia"]) {//判断是否是域名
    //        //        sessionManager.securityPolicy = securityPolicy;
    //
    //    }
    
    sessionManager.securityPolicy.validatesDomainName =NO;
    sessionManager.securityPolicy.allowInvalidCertificates = YES;
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    
    
    return sessionManager;
    
}

+(void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    
    AFHTTPSessionManager * sessionManager = [[ZWHttpTool defaultHttpTool] sessionManager];
    [sessionManager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            responseObject = jsonObject;
        }
        
        if ([[responseObject objectForKey:@"errorCode"] isEqualToString:@"NOTOKEN"] || [[responseObject objectForKey:@"errorCode"] isEqualToString:@"TIMEOUT"]) {
            NSLog(@"%@",[responseObject objectForKey:@"errorCode"]);
            
            return ;
        }
        
        if (success)
        {
            
            if ([responseObject objectForKey:@"content"]) {
                
                success([responseObject objectForKey:@"content"]);
            }else
                
                success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(error);
        }
    }];
    
    
}



+(void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    //    UInt64 recordTime =  [NSDate date].timeIntervalSince1970*1000;
    //    NSNumber * intervalNow =[NSNumber numberWithUnsignedInteger:recordTime];
    //    NSLog(@"---%@--%@------",url,[NSNumber numberWithUnsignedInteger:recordTime]);
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    //加入版本
    //    [paramsDic setObject:@"ios" forKey:@"appType"];
    //
    //    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    //    app_build = [app_build substringFromIndex:2];
    //    [paramsDic setObject:app_build forKey:@"appVersion"];
    //    NSLog(@"%@",app_build);
    //    if ([[paramsDic objectForKey:@"token"] length]>0) {
    //        NSString * token = [NSString stringWithFormat:@"%@%@",intervalNow,[paramsDic objectForKey:@"token"]];
    //        NSString * aesStr = [SecurityUtil encryptAESData:token];
    //        [paramsDic setObject:aesStr forKey:@"token"];
    //    }
    
    
    AFHTTPSessionManager * sessionManager = [[ZWHttpTool defaultHttpTool] sessionManager];

    [sessionManager POST:url parameters:paramsDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            responseObject = jsonObject;
        }
        if ( [[responseObject objectForKey:@"successFlag"] integerValue] == -1) {
            
            return ;
        }
        if (success)
        {
            if ([responseObject objectForKey:@"content"]) {
                success([responseObject objectForKey:@"content"]);
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(error);
        }
    }];
    
}


+ (void)postWithLoading:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.label.text = @"加载中。。。";
    [self post:url params:params success:^(id responseObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        if (success) {
            success(responseObj);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        if (failure) {
            failure(error);
        }
    }];
}
@end
