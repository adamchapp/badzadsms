//
//  HistoryView.h
//  MapMessage
//
//  Created by Nucleus on 10/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "RMSwipeTableViewCell.h"

@interface HistoryViewCell : RMSwipeTableViewCell

@property (nonatomic, strong) UIImageView *mapImageView;
@property (nonatomic, strong) UIImageView *checkmarkGreyImageView;
@property (nonatomic, strong) UIImageView *checkmarkGreenImageView;
@property (nonatomic, strong) UIImageView *checkmarkMapImageView;
@property (nonatomic, strong) UIImageView *deleteGreyImageView;
@property (nonatomic, strong) UIImageView *deleteRedImageView;
@property (nonatomic, assign) BOOL isFavourite;

-(void)setThumbnail:(UIImage*)image;
-(void)setFavourite:(BOOL)favourite animated:(BOOL)animated;

@end
