## PBJNetworkObserver
'PBJNetworkObserver' is an iOS component for detecting network reachability changes as well as the network connection type.

Mobile devices are always moving through connectivity challenged environments made up of various types of networks. This class enables applications to monitor these network changes and set opportunities to refresh, cache, or provide feedback when they occur.

For example, auto-refresh can be performed for the current view if the device joins a WiFi network or higher quality data can be requested to update the current view content.

Observers are notified when a network is no longer reachable, the network becomes reachable, and when the network type changes.

## Installation

[CocoaPods](http://cocoapods.org) is the recommended method of installing PBJNetworkObserver, just add the following line to your `Podfile`:

#### Podfile

```ruby
pod 'PBJNetworkObserver'
```

## Usage

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

## License

PBJNetworkObserver is available under the MIT license, see the LICENSE file for more information.
