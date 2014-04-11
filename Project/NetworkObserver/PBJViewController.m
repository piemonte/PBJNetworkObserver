//
//  PBJViewController.m
//  NetworkObserver
//
//  Created by Patrick Piemonte on 7/22/13.
//
//  Copyright (c) 2013-2014 Patrick Piemonte (http://patrickpiemonte.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PBJViewController.h"
#import "PBJNetworkObserver.h"

@interface PBJViewController () <PBJNetworkObserverProtocol>

@end

@implementation PBJViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[PBJNetworkObserver sharedNetworkObserver] addNetworkReachableObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[PBJNetworkObserver sharedNetworkObserver] removeNetworkReachableObserver:self];
}

#pragma mark - PBJNetworkObserverProtocol

- (void)networkObserverReachabilityDidChange:(PBJNetworkObserver *)networkObserver
{
    // network status changed, these properties can also be queried directly from the singleton
    BOOL isNetworkReachable = [networkObserver isNetworkReachable];
    BOOL isCellularConnection = [networkObserver isCellularConnection];
    NSLog(@"network status changed reachable (%d), cellular (%d)", isNetworkReachable, isCellularConnection);
}

@end
