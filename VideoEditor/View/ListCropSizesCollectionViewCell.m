//
//  ListCropSizesCollectionViewCell.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 03/05/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "ListCropSizesCollectionViewCell.h"

@implementation ListCropSizesCollectionViewCell
@synthesize _imageView,ratioSizeLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 10, self.contentView.frame.size.width-32, 44)];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_imageView];
        ratioSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 58, self.contentView.frame.size.width-12, 20)];
       // fromLabel.numberOfLines = 1;
       // fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        ratioSizeLabel.adjustsFontSizeToFitWidth = YES;
        ratioSizeLabel.clipsToBounds = YES;
        ratioSizeLabel.backgroundColor = [UIColor clearColor];
        ratioSizeLabel.textColor = [UIColor whiteColor];
        ratioSizeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:ratioSizeLabel];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    // reset image property of imageView for reuse
    _imageView.image = nil;
    // update frame position of subviews
    _imageView.frame = self.contentView.bounds;
}
@end
