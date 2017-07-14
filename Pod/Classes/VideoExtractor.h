//
//  VideoExtractor.h
//  Pods
//
//  Created by Bojan Jakus on 14/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface VideoExtractor : NSObject

-(void)processVideoUrl:(NSString *)fileUrl fileType:(NSString *)fileType closure:(void (^)(bool))closure;

@end
