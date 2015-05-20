//
//  UrlMoment.m
//  Pods
//
//  Created by Adam Juhasz on 5/20/15.
//
//

#import "UrlMoment.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation UrlMoment

- (void)downloadMomentsImage
{
    if (self.imageLoaded) {
        return;
    }
    
    self.imageLoaded = [[SDWebImageManager sharedManager] cachedImageExistsForURL:_location];
    if (self.imageLoaded) {
        self.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:self.location]];
        //NSLog(@"%@ has image in cache", self.postid);
        return;
    }
    
    if (self.location == nil) {
        NSLog(@"moment's location is empty: %@; dictioanary: %@", self, myDictionary);
    }
    //download image
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.location
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       self.downloadPercent = (float)receivedSize/expectedSize;
                                                       @synchronized(delegates) {
                                                           for (id <MomentDelegate> delagate in delegates) {
                                                               [delagate moment:self downloadProgress:self.downloadPercent];
                                                           }
                                                       }
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (error) {
                                                          NSLog(@"Error downloading %@ with %@", self.location, error);
                                                          self.downloadPercent = 0.0;
                                                          self.erroredOut = YES;
                                                      } else {
                                                          if (finished) {
                                                              self.image = image;
                                                              self.downloadPercent = 1.0;
                                                          }
                                                      }
                                                  }];
}

- (UIImage*)image
{
    if (self.imageLoaded == NO) {
        if (self.location) {
            [self downloadMomentsImage];
        }
    }
    
    return [super image];
}


@end
