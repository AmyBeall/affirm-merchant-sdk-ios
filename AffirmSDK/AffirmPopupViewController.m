//
//  AffirmPopupViewController.m
//  AffirmSDK
//
//  Created by Paul on 3/18/19.
//  Copyright © 2019 Affirm, Inc. All rights reserved.
//

#import "AffirmPopupViewController.h"

@interface AffirmPopupViewController ()

@property(nonatomic, copy, readwrite) NSURL *startURL;

@end

@implementation AffirmPopupViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _startURL = [URL copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(dismiss)];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:self.startURL]];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
