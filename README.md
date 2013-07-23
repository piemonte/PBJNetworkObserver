## PBJNetworkObserver
'PBJNetworkObserver' is an iOS component for detecting network reachability changes as well as the network connection type.

Mobile devices are always moving through connectivity challenged environments and various types of networks.

This class enables an iOS application to monitor these network changes and provide the opportunity to refresh, cache, or provide feedback when a connection is established or even lost.

Observers are notified when a network is no longer reachable, the network becomes reachable, and when the network changes.

### Basic Use

```objective-c
#import "PBJNetworkObserver.h"
```

```objective-c
@interface MyClass () <PBJNetworkObserverProtocol>
```

```objective-c
// add observer on init or viewDidAppear
    [[PBJNetworkObserver sharedNetworkObserver] addNetworkReachableObserver:self];

// remove observer on dealloc or on viewDidDisappear
    [[PBJNetworkObserver sharedNetworkObserver] removeNetworkReachableObserver:self];
```

```objective-c
- (void)networkObserverReachabilityDidChange:(PBJNetworkObserver *)networkObserver
{
    // network status changed, these properties can also be queried at any time
    BOOL isNetworkReachable = [networkObserver isNetworkReachable];
    BOOL isCellularConnection = [networkObserver isCellularConnection];
    NSLog(@"network status changed reachable (%d),  cellular (%d)", isNetworkReachable, isCellularConnection);
}

```
