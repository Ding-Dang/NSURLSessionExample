//
//  ViewController.m
//  NSURLSessionExample
//
//  Created by DingDang on 15/6/12.
//  Copyright (c) 2015年 DingDang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableData *sessionData;

@end

@implementation ViewController

- (NSMutableData *)data
{
    if (!_data) {
        _data = [[NSMutableData alloc] init];
    }
    return _data;
}

- (NSMutableData *)sessionData
{
    if (!_sessionData) {
        _sessionData = [[NSMutableData alloc] init];
    }
    return _sessionData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    NSURLConnection

    // use delegate
    NSURL *url = [NSURL URLWithString:@"http://api.meiriyiwen.com/v2/day/date=20150328&version=4"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    // sychronous
    NSError *error;
    NSURLResponse *response;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
    result = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSLog(@"get result sychronously: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);

    // asynchronous
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        sleep(2);
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSData *result = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSLog(@"get result asynchronously: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
    }];


//    NSURLSession

    // use delegate
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithURL:url];
    [task resume];

    // asynchronous
    task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *parseError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSData *result = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
            NSLog(@"session get result asynchronously: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
        }
    }];
    [task resume];
}

#pragma mark - NSURLConnectionDataDelegate

// will be called at most once, if an error occurs during a resource load. No other callbacks will be made after
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
}

// used for redirect
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"url: %@, statusCode: %@, headers: %@", httpResponse.URL, @(httpResponse.statusCode), httpResponse.allHeaderFields);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");

    [self.data appendData:data];
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    NSLog(@"needNewBodyStream");
    return nil;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
                                                totalBytesWritten:(NSInteger)totalBytesWritten
                                        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"send: %@, totalWritten: %@, totalExpectedToWrite: %@", @(bytesWritten), @(totalBytesWritten), @(totalBytesExpectedToWrite));
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"willCacheResponse");
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");

    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
    NSData *result = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSLog(@"get result with delegate: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveData:(NSData *)data
{
    NSLog(@"session didReceiveData");

    [self.sessionData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"session didCompleteWithError");

    if (!error) {
        NSError *parseError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&parseError];
        NSData *result = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
        NSLog(@"session get result with delegate: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
    }
}

@end
