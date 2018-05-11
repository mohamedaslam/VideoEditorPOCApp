//
//  TrimVideoVC.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 18/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "TrimVideoVC.h"
#import "Masonry.h"
#import "ViewController.h"
#import "CropVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OLCVideoPlayer.h"
#import "LLVideoEditor.h"
@interface TrimVideoVC ()<ICGVideoTrimmerDelegate,OLCVideoPlayerDelegate>
{
    UIView *videoPlayerBGView;
    UIButton *backbtn;
    UIButton *donebtn;
    UILabel *titleNamelabel;
    UIView *titleBarBGView;
    NSURL *movieUrl;
    NSArray *playlist;

   // ICGVideoTrimmerView *trimmerView;
}
@property (strong, nonatomic)OLCVideoPlayer *vidplayer;
@property (strong, nonatomic) UIProgressView *sldProgress;
@property(strong,nonatomic) UIButton *btnPlayPause;
@property (strong, nonatomic) UILabel *CurrentTimeLabel;
@property (strong, nonatomic) UILabel *totalDurationLabel;


@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;
@property (strong, nonatomic) NSString *tempVideoPath;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (assign, nonatomic) BOOL restartOnPlay;
@end

@implementation TrimVideoVC
@synthesize getSelectedVideoURL;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    [self.view setBackgroundColor:[UIColor blackColor]];
    ////////TitleBar BackGroundView
    titleBarBGView=[[UIView alloc]init];
    titleBarBGView.translatesAutoresizingMaskIntoConstraints = NO;
    [titleBarBGView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:titleBarBGView];
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 0, 0, 0);
    [titleBarBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top);
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
        make.right.equalTo(self.view.mas_right).with.offset(-padding.right);
        make.height.equalTo(@(50));
    }];
    
    ////////Title Name label
    titleNamelabel = [UILabel new];
    titleNamelabel.backgroundColor = [UIColor clearColor];
    titleNamelabel.textAlignment = NSTextAlignmentCenter;
    titleNamelabel.textColor = [UIColor whiteColor];
    titleNamelabel.text = @"Time Cut";
    [titleBarBGView addSubview:titleNamelabel];
    UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
        make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
        make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
        make.height.equalTo(@(50));
    }];
    ////////////////BackButton
    backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backbtn addTarget:self action:@selector(backbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backbtn setBackgroundColor:[UIColor clearColor]];
    [backbtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backbtn setExclusiveTouch:YES];
    [titleBarBGView addSubview:backbtn];
    [backbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(8);
        make.left.equalTo(titleBarBGView).with.offset(4);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    ///////////DoneButton
    donebtn = [UIButton new];
    donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [donebtn setBackgroundColor:[UIColor clearColor]];
    donebtn.translatesAutoresizingMaskIntoConstraints = NO;
    [donebtn setImage:[UIImage imageNamed:@"doneimg.png"] forState:UIControlStateNormal];
    [donebtn setExclusiveTouch:YES];
    [titleBarBGView addSubview:donebtn];
    [donebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(4);
        make.right.equalTo(titleBarBGView).with.offset(-10);
        make.height.equalTo(@(40));
        make.width.equalTo(@(40));
    }];
    

    self.vidplayer = [[OLCVideoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    [self.vidplayer setBackgroundColor:[UIColor darkGrayColor]];
    self.vidplayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.vidplayer];
    [self.vidplayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(240));
    }];
    [self.vidplayer setDelegate:self];
    
    /////////
    UIView *progressbarBGView=[[UIView alloc]init];
    progressbarBGView.translatesAutoresizingMaskIntoConstraints = NO;
    [progressbarBGView setBackgroundColor:[UIColor blackColor]];
    [progressbarBGView setAlpha:0.6];
    [self.vidplayer addSubview:progressbarBGView];
    [progressbarBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.vidplayer.mas_bottom).with.offset(0);
        make.left.equalTo(self.vidplayer.mas_left).with.offset(0);
        make.right.equalTo(self.vidplayer.mas_right).with.offset(0);
        make.height.equalTo(@(60));
    }];
    ////////Play/Pause button
    self.btnPlayPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnPlayPause addTarget:self action:@selector(playpausebtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlayPause setBackgroundColor:[UIColor clearColor]];
    [self.btnPlayPause setImage:[UIImage imageNamed:@"playicon.png"] forState:UIControlStateNormal];
    [self.btnPlayPause setExclusiveTouch:YES];
    [progressbarBGView addSubview:self.btnPlayPause];
    [self.btnPlayPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressbarBGView).with.offset(10);
        make.left.equalTo(progressbarBGView).with.offset(4);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    self.sldProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.sldProgress.progressTintColor = [UIColor redColor];
    self.sldProgress.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[self.sldProgress layer]setFrame:CGRectMake(0, 8, 280, 40)];
    self.sldProgress.trackTintColor = [UIColor whiteColor];
    [progressbarBGView addSubview:self.sldProgress];
    [self.sldProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(progressbarBGView);
        make.left.equalTo(progressbarBGView).with.offset(50);
        make.right.equalTo(progressbarBGView).with.offset(-6);
        make.height.equalTo(@(4));
    }];
    //    ////////totaltimelabel Name label
    self.totalDurationLabel = [UILabel new];
    self.totalDurationLabel.backgroundColor = [UIColor clearColor];
    self.totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    self.totalDurationLabel.textColor = [UIColor whiteColor];
    [self.totalDurationLabel setFont:[UIFont systemFontOfSize:12]];
    self.totalDurationLabel.text = @"00:00:00";
    self.totalDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [progressbarBGView addSubview:self.totalDurationLabel];
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-6);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];
    //    ////////     /totaltimelabel Name label
    UILabel *slaplabel = [UILabel new];
    slaplabel.backgroundColor = [UIColor clearColor];
    slaplabel.textAlignment = NSTextAlignmentCenter;
    slaplabel.textColor = [UIColor whiteColor];
    [slaplabel setFont:[UIFont systemFontOfSize:12]];
    slaplabel.text = @"/";
    slaplabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [progressbarBGView addSubview:slaplabel];
    [slaplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-66);
        make.width.equalTo(@(4));
        make.height.equalTo(@(20));
    }];
    
    //    ////////     /CUrrentrunningtimelabel  label
    self.CurrentTimeLabel = [UILabel new];
    self.CurrentTimeLabel.backgroundColor = [UIColor clearColor];
    self.CurrentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.CurrentTimeLabel.textColor = [UIColor whiteColor];
    [self.CurrentTimeLabel setFont:[UIFont systemFontOfSize:12]];
    self.CurrentTimeLabel.text = @"00:00:00";
    self.CurrentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [progressbarBGView addSubview:self.CurrentTimeLabel];
    [self.CurrentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-78);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];

    self.asset = [AVAsset assetWithURL:getSelectedVideoURL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [videoPlayerBGView.layer addSublayer:self.playerLayer];
    
    /////////// VIdeoPlayer Background VIeww/////////////
    if(self.asset == nil){
        
    }else
    {
    self.trimmerView = [[ICGVideoTrimmerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 120) asset:self.asset];
    [self.trimmerView setBackgroundColor:[UIColor redColor]];
    [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setRulerLabelInterval:10];
    [self.trimmerView setTrackerColor:[UIColor cyanColor]];
    [self.trimmerView setDelegate:self];
    [self.trimButton setHidden:NO];
    [self.view addSubview:self.trimmerView];
        [self.trimmerView resetSubviews];

    }
}
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}
- (CALayer *)createVideoLayer {
    // a simple red rectangle
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(10, 10, 100, 50);
    return layer;
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationClosing:) name:
     UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpening:) name:
     UIApplicationWillEnterForegroundNotification object:nil];
    NSMutableDictionary *video = nil;
    
    if(getSelectedVideoURL == nil)
    {
        
    }else{
        NSMutableArray *videos = [[NSMutableArray alloc] init];

        video = [[NSMutableDictionary alloc] init];
        
      

        [video setObject:getSelectedVideoURL forKey:OLCPlayerVideoURL];
        [video setValue:@0 forKey:OLCPlayerPlayTime];
        [videos addObject:video];
        playlist = videos;
        [self.vidplayer playVideos:playlist];
        [self.vidplayer continusPlay:YES];
        [self.vidplayer shuffleVideos:NO];
    }

}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   // [self.vidplayer setDelegate:nil];
    [self.vidplayer shutdown];
  //  [self.vidplayer removeFromSuperview];
    //self.vidplayer = nil;
}
-(void) backbtnClicked:(UIButton*)sender
{
    ViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:VC animated:YES completion:nil];
    
}
-(void) playpausebtn:(UIButton*)sender
{
    if([self.vidplayer isPlaying])
    {
        [self.vidplayer pause];
    }
    else
    {
        [self.vidplayer play];
    }
}
-(void) buttonClicked:(UIButton*)sender
{
    [self deleteTempFile];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                       movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
                        NSLog(@"asdfasdfasfd%@", [movieUrl relativePath]);
                        UISaveVideoAtPathToSavedPhotosAlbum([movieUrl relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
                    });
                    break;
            }
        }];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ICGVideoTrimmerDelegate

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    _restartOnPlay = YES;
    [self.player pause];
    self.isPlaying = NO;
    [self stopPlaybackTimeChecker];
    [self.trimmerView hideTracker:true];
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    else{ // right has changed
        [self seekVideoToPos:endTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
    
}

#pragma mark - Actions
- (void)deleteTempFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

- (IBAction)selectAsset:(id)sender
{
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}


- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        CropVideoVC*VC = [self.storyboard instantiateViewControllerWithIdentifier:@"CropVideoVC"];
        VC.getSelectedURl = movieUrl ;
        VC.getfullSelectedURl = getSelectedVideoURL;
        [self presentViewController:VC animated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    self.playerLayer.frame = CGRectMake(0, 0, videoPlayerBGView.frame.size.width, videoPlayerBGView.frame.size.height);
}

- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

#pragma mark - PlaybackTimeCheckerTimer

- (void)onPlaybackTimeCheckerTimer
{
    CMTime curTime = [self.player currentTime];
    Float64 seconds = CMTimeGetSeconds(curTime);
    if (seconds < 0){
        seconds = 0; // this happens! dont know why.
    }
    self.videoPlaybackPosition = seconds;
    [self.trimmerView seekToTime:seconds];
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [self.trimmerView seekToTime:self.startTime];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [self.vidplayer shutdown];
}
- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - OLCVideoPlayer Delegates

- (void) onFinishPlaying:(NSUInteger)index
{
    
}

- (void) onPause:(NSUInteger)index
{
    [self.btnPlayPause setImage:[UIImage imageNamed:@"playicon.png"] forState:UIControlStateNormal];
}

- (void) onPlay:(NSUInteger)index
{
    [self.btnPlayPause setImage:[UIImage imageNamed:@"pauseicon.png"] forState:UIControlStateNormal];
}

//this get called every 0.5 seconds with video duration and current playtime so we can update our progress bars
- (void) onPlayInfoUpdate:(double)current withDuration:(double)duration
{
    float progress = ( current / duration );
    self.sldProgress.progress = progress;
    self.CurrentTimeLabel.text = [self stringFromSeconds:current];
    self.totalDurationLabel.text = [self stringFromSeconds:duration];
}

#pragma mark - notifications

- (void) applicationClosing:(NSNotification *)notification
{
    [self.vidplayer playInBackground];
}

- (void) applicationOpening:(NSNotification *)notification
{
    [self.vidplayer playInForeground];
}

#pragma mark - private

- (NSString *) stringFromSeconds:(double) value
{
    NSTimeInterval interval = value;
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
