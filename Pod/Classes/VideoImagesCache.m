//
//  VideoImagesCache.m
//  Pods
//
//  Created by Bojan Jakus on 14/07/2017.
//
//

#import "VideoImagesCache.h"

@implementation VideoImagesCache

@synthesize imageURLs;
@synthesize videoURLs;

#pragma mark Singleton Methods

+ (id)instance {
    static VideoImagesCache *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        imageURLs = [[NSMutableDictionary alloc] init];
        videoURLs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
