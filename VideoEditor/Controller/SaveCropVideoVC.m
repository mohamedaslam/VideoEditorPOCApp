//
//  SaveCropVideoVC.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 08/05/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "SaveCropVideoVC.h"
#import "OLCVideoPlayer.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ViewController.h"
#import "CropVideoVC.h"

@interface SaveCropVideoVC ()<OLCVideoPlayerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
    UIView *videoPlayerBGView;
    UIButton *backbtn;
    UIButton *homebtn;
    UILabel *titleNamelabel;
    UIView *titleBarBGView;
    NSArray *playlist;
    NSURL *uploadedVideoPath;
    UIView *CropSizeBGView;
    NSArray *ratiocropsize;
    NSArray *cropSizeImages;
}
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) NSString *tempVideoPath;
@property(strong,nonatomic) UIView *croplayerview;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic)OLCVideoPlayer *vidplayer;
@property (strong, nonatomic) UIProgressView *sldProgress;
@property(strong,nonatomic) UIButton *btnPlayPause;
@property (strong, nonatomic) UILabel *CurrentTimeLabel;
@property (strong, nonatomic) UILabel *totalDurationLabel;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;
//    @property (strong, nonatomic) NSString *tempVideoPath;
@property(strong,nonatomic)NSString *getWidthSize;
@property(strong,nonatomic)NSString *getHeightSize;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;

@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (assign, nonatomic) BOOL restartOnPlay;

@end

@implementation SaveCropVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(popNavigationController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    //    ////////TitleBar BackGroundView
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
    
    //    ////////Title Name label
    titleNamelabel = [UILabel new];
    titleNamelabel.backgroundColor = [UIColor clearColor];
    titleNamelabel.textAlignment = NSTextAlignmentCenter;
    titleNamelabel.textColor = [UIColor whiteColor];
    titleNamelabel.text = @"Save/Share";
    [titleBarBGView addSubview:titleNamelabel];
    UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
        make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
        make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
        make.height.equalTo(@(50));
    }];
    //    ////////////////BackButton
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
//    ///////////Home Button
    homebtn = [UIButton new];
    homebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [homebtn addTarget:self action:@selector(homeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [homebtn setBackgroundColor:[UIColor clearColor]];
    homebtn.translatesAutoresizingMaskIntoConstraints = NO;
    [homebtn setImage:[UIImage imageNamed:@"homebtnIMG.png"] forState:UIControlStateNormal];
    [homebtn setExclusiveTouch:YES];
    [titleBarBGView addSubview:homebtn];
    [homebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(4);
        make.right.equalTo(titleBarBGView).with.offset(-10);
        make.height.equalTo(@(40));
        make.width.equalTo(@(40));
    }];
    
    self.vidplayer = [[OLCVideoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 340)];
    //   self.vidplayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 240);
    [self.vidplayer setBackgroundColor:[UIColor darkGrayColor]];
    self.vidplayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.vidplayer];
    [self.vidplayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(340));
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
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    NSMutableDictionary *video = nil;
    video = [[NSMutableDictionary alloc] init];
    [video setObject:_getSelectedURl forKey:OLCPlayerVideoURL];
    [video setValue:@0 forKey:OLCPlayerPlayTime];
    [videos addObject:video];
    playlist = videos;
    [self.vidplayer playVideos:playlist];
    [self.vidplayer continusPlay:YES];
    [self.vidplayer shuffleVideos:NO];
    
    UIView *sharedBGView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)];
    sharedBGView.translatesAutoresizingMaskIntoConstraints = NO;
    [sharedBGView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:sharedBGView];
    
    //    ////////savedAlbumLabel  label
    UILabel *savedAlbumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, sharedBGView.frame.size.width, 24)];
    savedAlbumLabel.backgroundColor = [UIColor blackColor];
    savedAlbumLabel.textAlignment = NSTextAlignmentCenter;
    savedAlbumLabel.textColor = [UIColor whiteColor];
    [savedAlbumLabel setFont:[UIFont systemFontOfSize:16]];
    savedAlbumLabel.text = @"Saved to Album";
    [sharedBGView addSubview:savedAlbumLabel];
    
    //    ////////shareTOLabel  label
    UILabel *shareTOLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, sharedBGView.frame.size.width, 24)];
    shareTOLabel.backgroundColor = [UIColor blackColor];
    shareTOLabel.textAlignment = NSTextAlignmentCenter;
    shareTOLabel.textColor = [UIColor whiteColor];
    [shareTOLabel setFont:[UIFont systemFontOfSize:20]];
    shareTOLabel.text = @"Share To:";
    [sharedBGView addSubview:shareTOLabel];
    
    ////////messagebtn Button
    UIButton *messagebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messagebtn addTarget:self action:@selector(messagebtn:) forControlEvents:UIControlEventTouchUpInside];
    messagebtn.frame = CGRectMake(40.0, 64, 60, 60);
    [messagebtn setBackgroundColor:[UIColor blackColor]];
    [messagebtn setImage:[UIImage imageNamed:@"messageIMG.png"] forState:UIControlStateNormal];
    [messagebtn setExclusiveTouch:YES];
    [sharedBGView addSubview:messagebtn];

    //    /////////Message  label
    UILabel *MessagesLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 124, 60, 24)];
    MessagesLabel.backgroundColor = [UIColor blackColor];
    MessagesLabel.textAlignment = NSTextAlignmentCenter;
    MessagesLabel.textColor = [UIColor whiteColor];
    [MessagesLabel setFont:[UIFont systemFontOfSize:12]];
    MessagesLabel.text = @"Messages";
    [sharedBGView addSubview:MessagesLabel];
    
    ////////mailb button
    UIButton *mailbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mailbtn addTarget:self action:@selector(mailbtn:) forControlEvents:UIControlEventTouchUpInside];
    mailbtn.frame = CGRectMake(sharedBGView.frame.size.width/2- 30, 64, 60, 60);
    [mailbtn setBackgroundColor:[UIColor blackColor]];
    [mailbtn setImage:[UIImage imageNamed:@"mailIMG.png"] forState:UIControlStateNormal];
    [mailbtn setExclusiveTouch:YES];
    [sharedBGView addSubview:mailbtn];
    
    //    //////// MailLabel
    UILabel *MailLabel = [[UILabel alloc]initWithFrame:CGRectMake(sharedBGView.frame.size.width/2- 30, 124, 60, 24)];
    MailLabel.backgroundColor = [UIColor blackColor];
    MailLabel.textAlignment = NSTextAlignmentCenter;
    MailLabel.textColor = [UIColor whiteColor];
    [MailLabel setFont:[UIFont systemFontOfSize:12]];
    MailLabel.text = @"Mail";
    [sharedBGView addSubview:MailLabel];
    

    ////////More Button
    UIButton *morebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [morebtn addTarget:self action:@selector(morebtn:) forControlEvents:UIControlEventTouchUpInside];
    morebtn.frame = CGRectMake(sharedBGView.frame.size.width- 100, 64, 60, 60);
    [morebtn setBackgroundColor:[UIColor blackColor]];
    [morebtn setImage:[UIImage imageNamed:@"MoreIMg.png"] forState:UIControlStateNormal];
    [morebtn setExclusiveTouch:YES];
    [sharedBGView addSubview:morebtn];
    
    //    //////// /Morelabel
    UILabel *MoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(sharedBGView.frame.size.width- 100, 124, 60, 24)];
    MoreLabel.backgroundColor = [UIColor blackColor];
    MoreLabel.textAlignment = NSTextAlignmentCenter;
    MoreLabel.textColor = [UIColor whiteColor];
    [MoreLabel setFont:[UIFont systemFontOfSize:12]];
    MoreLabel.text = @"More";
    [sharedBGView addSubview:MoreLabel];
   
}
-(void)homeButtonClicked:(id)sender
{
    ViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:VC animated:YES completion:nil];
}
- (void)viewDidLayoutSubviews
{
    self.playerLayer.frame = CGRectMake(0, 0, videoPlayerBGView.frame.size.width, videoPlayerBGView.frame.size.height);
}
-(void) backbtnClicked:(UIButton*)sender
{
    CropVideoVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"CropVideoVC"];
    VC.getSelectedURl = _getfullSelectedURl;
    [self presentViewController:VC animated:YES completion:nil];
    
}
- (void)morebtn:(id)sender
{
    
    NSArray* sharedObjects=[NSArray arrayWithObjects:@"sharecontent",  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
}
- (void)mailbtn:(id)sender
{
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:@"Email subject"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@""]];
        NSString *_getURl = _getSelectedURl.absoluteString;

        [mailCont setMessageBody:_getURl isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}
- (void)messagebtn:(id)sender
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.recipients = [NSArray arrayWithObjects:@"", nil];
    NSString *_getURl = _getSelectedURl.absoluteString;

    picker.body = _getURl;
    
    [self presentModalViewController:picker animated:YES];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {

    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void) playpausebtn:(UIButton*)sender
{
    if([self.vidplayer isPlaying]){
        [self.vidplayer pause];
    }
    else{
        [self.vidplayer play];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.vidplayer shutdown];
}
- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
