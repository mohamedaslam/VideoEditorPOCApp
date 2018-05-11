//
//  ListCollectionViewCell.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 17/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "ListCollectionViewCell.h"

@implementation ListCollectionViewCell
@synthesize _imageView,tickMark;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [tickMark setHidden:YES];
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_imageView];
        tickMark =[[UIImageView alloc] initWithFrame:CGRectMake(6,6,20,20)];
        tickMark.image=[UIImage imageNamed:@"uparrow.png"];
        [_imageView addSubview:tickMark];
       
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
