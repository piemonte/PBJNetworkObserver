## PBJNetworkObserver
'PBJNetworkObserver' is an iOS component for detecting network reachability changes as well as the network connection type.

### Basic Use

```objective-c
#import "PBJNetworkObserver.h"
```

```objective-c

// add observer on init or viewDidAppear
    [[PBJNetworkObserver sharedNetworkObserver] addNetworkReachableObserver:self];

// remove observer on dealloc or on viewDidDisappear

    [[PBJNetworkObserver sharedNetworkObserver] removeNetworkReachableObserver:self];

// ...

#pragma mark - PBJNetworkObserverProtocol

- (void)networkObserverReachabilityDidChange:(PBJNetworkObserver *)networkObserver
{
    // network status changed, these properties can also be queried at any time
    BOOL isNetworkReachable = [networkObserver isNetworkReachable];
    BOOL isCellularConnection = [networkObserver isCellularConnection];
    NSLog(@"network status changed reachable (%d),  cellular (%d)", isNetworkReachable, isCellularConnection);
}

```
