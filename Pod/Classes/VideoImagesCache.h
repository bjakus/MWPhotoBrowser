//
//  VideoImagesCache.h
//  Pods
//
//  Created by Bojan Jakus on 14/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface VideoImagesCache : NSObject {
    NSMutableDictionary *imageURLs;
    NSMutableDictionary *videoURLs;
}

@property (nonatomic, retain) NSMutableDictionary *imageURLs;
@property (nonatomic, retain) NSMutableDictionary *videoURLs;

+ (id)instance;

@end
