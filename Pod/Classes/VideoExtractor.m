//
//  VideoExtractor.m
//  Pods
//
//  Created by Bojan Jakus on 14/07/2017.
//
//

#import "VideoExtractor.h"
#import "VideoImagesCache.h"
#import "YTVimeoExtractor.h"
#import "XCDYouTubeClient.h"

@implementation VideoExtractor

-(void)processVideoUrl:(NSString *)fileUrl fileType:(NSString *)fileType closure:(void (^)(bool))closure {
    
    if ([self getImageAndPictureFromCache:fileUrl]) {
        closure(true);
        return;
    }
    
    if ([fileType containsString:@"vimeo"]){
        [self processVimeoURL:fileUrl closure:closure];
    } else if ([fileType containsString:@"youtube"]){
        [self processYoutubeURL:fileUrl closure:closure];
    } else if ([fileType containsString:@"mp4"]){
        [[[VideoImagesCache instance] videoURLs] setObject:fileUrl forKey:fileUrl];
        closure(true);
    } else {
        closure(false);
    }
}

-(void)processVimeoURL:(NSString *)fileUrl closure:(void (^)(bool))closure {
    
    [[YTVimeoExtractor sharedExtractor] fetchVideoWithVimeoURL:fileUrl withReferer:nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {
        if (error == nil) {
            NSArray *images = video.thumbnailURLs.allValues;
            for (NSURL *item in images) {
                [[[VideoImagesCache instance] imageURLs] setObject:item.absoluteString forKey:fileUrl];
                [[[VideoImagesCache instance] imageURLs] setObject:item.absoluteString forKey:[fileUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"]];
                break;
            }
            
            NSArray *videos = video.streamURLs.allValues;
            for (NSURL *item in videos) {
                [[[VideoImagesCache instance] videoURLs] setObject:item.absoluteString forKey:fileUrl];
                [[[VideoImagesCache instance] videoURLs] setObject:item.absoluteString forKey:[fileUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"]];
                break;
            }
            closure(true);
        } else {
            closure(false);
        }
    }];
    
}


-(void)processYoutubeURL:(NSString *)fileUrl closure:(void (^)(bool))closure {
    
    NSString *youtubeID = [self extractYoutubeIdFromLink:fileUrl];
 
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:youtubeID completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
        if (video == nil) {
            closure(false);
            return;
        }
        
        NSString *thumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", youtubeID];
        [[[VideoImagesCache instance] imageURLs] setObject:thumbnail forKey:fileUrl];
        [[[VideoImagesCache instance] imageURLs] setObject:thumbnail forKey:[fileUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"]];
        
        if (video.streamURLs != nil) {
            NSDictionary *videosMP4 = video.streamURLs;
            
            NSArray *quality = [NSArray arrayWithObjects:[NSNumber numberWithInteger:XCDYouTubeVideoQualityHD720], [NSNumber numberWithInteger:XCDYouTubeVideoQualityMedium360], [NSNumber numberWithInteger:XCDYouTubeVideoQualitySmall240], nil];
            NSURL *videoURL = nil;
            
            for (NSNumber *item in quality) {
                if ([videosMP4 objectForKey:item] != nil) {
                    videoURL = [videosMP4 objectForKey:item];
                    break;
                }
            }
            NSString *apsoluteString = videoURL.absoluteString;
            if ([apsoluteString containsString:@"mime=video%2Fmp4"]) {
                [[[VideoImagesCache instance] videoURLs] setObject:videoURL.absoluteString forKey:fileUrl];
                [[[VideoImagesCache instance] videoURLs] setObject:videoURL.absoluteString forKey:[fileUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"]];
            }
        }
        
        closure(true);
    }];
    
}

-(NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSError *error = NULL;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSUInteger lengthOfString = [link length];
    NSTextCheckingResult *match = [regex firstMatchInString:link
                                                    options:0
                                                      range:NSMakeRange(0, lengthOfString)];
    if (match) {
        NSRange videoIDRange = [match rangeAtIndex:0];
        NSString *substringForFirstMatch = [link substringWithRange:videoIDRange];
        return substringForFirstMatch;
    }
    return nil;
}

-(BOOL)getImageAndPictureFromCache:(NSString *)url {
    if ([[[VideoImagesCache instance] imageURLs] objectForKey:url] != nil && [[[VideoImagesCache instance] videoURLs] objectForKey:url] != nil) {
        return true;
    }
    return false;
}

@end
