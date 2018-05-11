//
//  CropVideoVC.h
//  VideoEditor
//
//  Created by Mohammed Aslam on 23/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLCVideoPlayer.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface CropVideoVC : UIViewController
@property(nonatomic,strong)NSURL *getSelectedURl;
@property(nonatomic,strong)NSURL *getfullSelectedURl;
@property (nonatomic) AVAssetExportSession *exporter;
-(void)cropVideoMethod:(NSURL *)geturl getWidth:(NSString *)widthValue getHeigth:(NSString *)heightValue;
@end
