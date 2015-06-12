//
//  ViewController.m
//  NSURLSessionExample
//
//  Created by DingDang on 15/6/12.
//  Copyright (c) 2015年 DingDang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation ViewController

- (NSMutableData *)data
{
    if (!_data) {
        _data = [[NSMutableData alloc] init];
    }
    return _data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    // synchronous
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        sleep(2);
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSData *result = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSLog(@"get result asynchronously: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - NSURLConnectionDelegate

// will be called at most once, if an error occurs during a resource load. No other callbacks will be made after
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
}

// used for authenication
//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
//{
//
//}

//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//}

#pragma mark - NSURLConnectionDataDelegate

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

@end
