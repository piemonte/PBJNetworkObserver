//
//  PBJNetworkObserver.m
//
//  Created by Patrick Piemonte on 5/24/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "PBJNetworkObserver.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h> // internet address ints

#define LOG_NETWORK 0
#if !defined(NDEBUG) && LOG_NETWORK
#   define DLog(fmt, ...) NSLog((@"network: " fmt), ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

@interface PBJNetworkObserver ()
{
    dispatch_queue_t _queue;
    NSHashTable *_observers;

    SCNetworkReachabilityRef _networkReachability;
    SCNetworkReachabilityFlags _networkReachabilityFlags;
    
    struct {
        unsigned int networkReachable:1;
        unsigned int cellularConnection:1;
        unsigned int networkObserversNotified:1;
    } _flags;
}

@end

@implementation PBJNetworkObserver

#pragma mark - singleton

+ (PBJNetworkObserver *)sharedNetworkObserver
{
    static PBJNetworkObserver *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[PBJNetworkObserver alloc] init];
    });
    return singleton;
}

#pragma mark - getters/setters

- (BOOL)isNetworkReachable
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#endif

    __block BOOL result = NO;
    dispatch_sync(_queue, ^{
        if (!_observers)
            [self _setup];
        result = _flags.networkReachable;
    });
    return result;
}

- (BOOL)isCellularConnection
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif

    __block BOOL result = NO;
    dispatch_sync(_queue, ^{
        if (!_observers)
            [self _setup];
        result = _flags.cellularConnection;
    });
    return result;
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("PBJNetworkObserver", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - PBJNetworkObserver add/remove

- (void)addNetworkReachableObserver:(id<PBJNetworkObserverProtocol>)observer;
{
    dispatch_sync(_queue, ^{
        if (!_observers)
            [self _setup];
    
        if (![_observers containsObject:observer])
            [_observers addObject:observer];
    });
}

- (void)removeNetworkReachableObserver:(id<PBJNetworkObserverProtocol>)observer;
{
    dispatch_sync(_queue, ^{
        if (!_observers || [_observers count] == 0)
            return;
    
        if ([_observers containsObject:observer])
            [_observers removeObject:observer];
    });
}

#pragma mark - private

- (void)_setup
{
    if (!_observers)
        _observers = [NSHashTable weakObjectsHashTable];

    struct sockaddr_in addr = {sizeof(addr), AF_INET, 0, {htonl(INADDR_ANY)}, {0}};
    
    _networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&addr);
    
    SCNetworkReachabilityGetFlags(_networkReachability, &_networkReachabilityFlags);
    
    _flags.networkReachable = ((_networkReachabilityFlags & kSCNetworkReachabilityFlagsReachable) != 0);
    _flags.cellularConnection = ((_networkReachabilityFlags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(_networkReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack, &context);

    NSData *data = [NSData dataWithBytes:&_networkReachability length:sizeof(_networkReachability)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _networkReachableCallBack:*((SCNetworkReachabilityFlags *)[data bytes])];
        SCNetworkReachabilityScheduleWithRunLoop(_networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    });
}

#pragma mark - SCNetworkReachability callbacks

// SCNetworkReachabilityCallBack --> _networkReachableCallBack
static void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, PBJNetworkObserver *me) {
    [me _networkReachableCallBack:flags];
}

- (void)_networkReachableCallBack:(SCNetworkReachabilityFlags)flags
{
    BOOL reachable[2] = {NO, NO};
    BOOL currentReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    BOOL previousReachable = (_networkReachabilityFlags & kSCNetworkReachabilityFlagsReachable) != 0;
    
    if (currentReachable && previousReachable){
        reachable[0] = NO;
        reachable[1] = currentReachable;
    } else {
        reachable[0] = currentReachable;
        reachable[1] = NO;
    }
    
    _networkReachabilityFlags = flags;
    
    // update cellular connection type, this is regardless of network reachability
    _flags.cellularConnection = (unsigned int)((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
    
    DLog(@"updated cellular %d", _flags.cellularConnection);
    
    // update network reachability state change
    for (NSUInteger i = 0; i < 2; i++) {

        if ( !_flags.networkObserversNotified || (reachable[i] != _flags.networkReachable) ) {
            _flags.networkObserversNotified = YES;
            _flags.networkReachable = (unsigned int)reachable[i];

            DLog(@"notifying reachable %d", _flags.networkReachable);

            for (id observer in [_observers allObjects])
                [observer networkObserverReachabilityDidChange:self];
        }

    }
}

@end
