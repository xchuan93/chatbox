// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


#import <UIKit/UIKit.h>
@import FLAnimatedImage;


@protocol MediaAsset <NSObject>

@property (nonatomic, readonly) CGSize size;

- (NSData *)data;
- (BOOL)isGIF;

@end



@interface UIImage(MediaAsset) <MediaAsset>

@end



@interface FLAnimatedImage(MediaAsset) <MediaAsset>

@end



@protocol MediaAssetView <NSObject>

- (id<MediaAsset>)mediaAsset;
- (void)setMediaAsset:(id<MediaAsset>)asset;

@end



@interface UIImageView(MediaAssetView) <MediaAssetView>

+ (instancetype)imageViewWithMediaAsset:(id<MediaAsset>)image;

@end



@interface FLAnimatedImageView(MediaAssetView) <MediaAssetView>

@end



@interface UIPasteboard(MediaAsset)

- (id<MediaAsset>)mediaAsset;
- (void)setMediaAsset:(id<MediaAsset>)image;

@end

