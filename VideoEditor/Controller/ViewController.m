//
//  ViewController.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 16/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AssetBrowserItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ListCollectionViewCell.h"
#import "Masonry.h"
#import "TrimVideoVC.h"
#import "OLCVideoPlayer.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,OLCVideoPlayerDelegate>
{
    UICollectionView *_collectionView;
    UIView *titleBarBGView;
    UIButton *uparrowbtn;
    UIButton *donebtn;
    UIButton *playbtn;
    UIButton *pausebtn;
    UIButton *stopbtn;
    UILabel *titleNamelabel;
    NSURL *getSelectedURl;
    AVPlayer* player;
    AVPlayerLayer *layer;
    NSArray *playlist;

}
@property (strong, nonatomic)OLCVideoPlayer *vidplayer;
@property (strong, nonatomic) UIProgressView *sldProgress;
@property(strong,nonatomic) UIButton *btnPlayPause;
@property (strong, nonatomic) UILabel *CurrentTimeLabel;
@property (strong, nonatomic) UILabel *totalDurationLabel;
@property (strong,nonatomic)UIView *progressbarBGView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSMutableArray *videoURLArray;
@property (nonatomic, strong) NSMutableArray *imagesTHumbnailarray;
@property (nonatomic, strong) NSMutableArray *videosTitlearray;
@property (nonatomic, strong) NSMutableArray *videosURLArray;
@property (nonatomic, strong) NSMutableArray *assetItems;
@property (nonatomic, strong) NSMutableDictionary *dic;
@end

@implementation ViewController
@synthesize assetsLibrary, assetItems,dic;
@synthesize videoURL,videoURLArray;

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
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
    titleNamelabel.text = @"Choose Picture";
    [titleBarBGView addSubview:titleNamelabel];
    UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
        make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
        make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
        make.height.equalTo(@(50));
    }];

    ////////Up arrow Button
    uparrowbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [uparrowbtn addTarget:self action:@selector(upArrowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [uparrowbtn setBackgroundColor:[UIColor clearColor]];
    [uparrowbtn setExclusiveTouch:YES];
    [uparrowbtn setHidden:true];
    [titleBarBGView addSubview:uparrowbtn];
    [uparrowbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(8);
        make.centerX.equalTo(titleBarBGView);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    
    ////////Done button
    donebtn = [UIButton new];
    donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn addTarget:self action:@selector(DonebtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    ////////List of Vdeos CollectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 400) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[ListCollectionViewCell class] forCellWithReuseIdentifier:@"ListCollectionViewCell"];
    [_collectionView setBackgroundColor:[UIColor darkGrayColor]];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
}];

    self.vidplayer = [[OLCVideoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
//    self.vidplayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 180);
     [self.vidplayer setBackgroundColor:[UIColor darkGrayColor]];
     self.vidplayer.translatesAutoresizingMaskIntoConstraints = NO;
     [self.view addSubview:self.vidplayer];
     [self.vidplayer setHidden:true];
     [self playPauseControllerMethods];
     [self buildAssetsLibrary];
}
-(void)playPauseControllerMethods{
//
//    [self.vidplayer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).with.offset(70);
//        make.left.equalTo(self.view).with.offset(0);
//        make.height.equalTo(@(180));
//        make.width.equalTo(@(self.view.frame.size.width));
//    }];
//    [self.vidplayer setDelegate:self];
    
    /////////
    self.progressbarBGView=[[UIView alloc]init];
    self.progressbarBGView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressbarBGView setBackgroundColor:[UIColor blackColor]];
    [self.progressbarBGView setAlpha:0.6];
    [self.vidplayer addSubview:self.progressbarBGView];
    [self.progressbarBGView setHidden:true];
    [self.progressbarBGView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [self.progressbarBGView addSubview:self.btnPlayPause];
    [self.btnPlayPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressbarBGView).with.offset(10);
        make.left.equalTo(self.progressbarBGView).with.offset(4);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    self.sldProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.sldProgress.progressTintColor = [UIColor redColor];
    self.sldProgress.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[self.sldProgress layer]setFrame:CGRectMake(0, 8, 280, 40)];
    self.sldProgress.trackTintColor = [UIColor whiteColor];
    [self.progressbarBGView addSubview:self.sldProgress];
    [self.sldProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.progressbarBGView);
        make.left.equalTo(self.progressbarBGView).with.offset(50);
        make.right.equalTo(self.progressbarBGView).with.offset(-6);
        make.height.equalTo(@(4));
    }];
    
     ////////totaltimelabel Name label
    self.totalDurationLabel = [UILabel new];
    self.totalDurationLabel.backgroundColor = [UIColor clearColor];
    self.totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    self.totalDurationLabel.textColor = [UIColor whiteColor];
    [self.totalDurationLabel setFont:[UIFont systemFontOfSize:12]];
    self.totalDurationLabel.text = @"00:00:00";
    self.totalDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressbarBGView addSubview:self.totalDurationLabel];
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressbarBGView).with.offset(2);
        make.right.equalTo(self.progressbarBGView).with.offset(-6);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];
    ////////     /totaltimelabel Name label
    UILabel *slaplabel = [UILabel new];
    slaplabel.backgroundColor = [UIColor clearColor];
    slaplabel.textAlignment = NSTextAlignmentCenter;
    slaplabel.textColor = [UIColor whiteColor];
    [slaplabel setFont:[UIFont systemFontOfSize:12]];
    slaplabel.text = @"/";
    slaplabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressbarBGView addSubview:slaplabel];
    [slaplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressbarBGView).with.offset(2);
        make.right.equalTo(self.progressbarBGView).with.offset(-66);
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
    [self.progressbarBGView addSubview:self.CurrentTimeLabel];
    [self.CurrentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressbarBGView).with.offset(2);
        make.right.equalTo(self.progressbarBGView).with.offset(-78);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];
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
#pragma mark - Custom Methods

-(void) upArrowBtnClicked:(UIButton*)sender
{
    [self.vidplayer setHidden:true];
    [self.progressbarBGView setHidden:true];
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
    }];
    [titleNamelabel setHidden:false];
    [uparrowbtn setHidden:true];
     [self.vidplayer setDelegate:nil];
//    [self.vidplayer shutdown];

}
-(void) DonebtnClicked:(UIButton*)sender
{
    if(getSelectedURl == nil)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Please select Video"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        

        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
    TrimVideoVC*VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TrimVideoVC"];
    VC.getSelectedVideoURL = getSelectedURl;
    [self presentViewController:VC animated:YES completion:nil];
    }
    
}
-(void) pausebtnClicked:(UIButton*)sender
{
    [player pause];
}

#pragma mark - CollectionView Methods

//////CollectionView DelegateMethods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_imagesTHumbnailarray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor greenColor];
    if(_imagesTHumbnailarray.count>0){
        cell._imageView.image = [_imagesTHumbnailarray objectAtIndex:indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(110, 110);
}
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10,10,10,10);  // top, left, bottom, right
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [uparrowbtn setHidden:false];
    [titleNamelabel setHidden:true];
    [uparrowbtn setImage:[UIImage imageNamed:@"arrowimg.png"] forState:UIControlStateNormal];
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(250);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
    }];
    getSelectedURl = [_videosURLArray objectAtIndex:indexPath.row];
    
   
    [self.vidplayer setHidden:false];
    [self.progressbarBGView setHidden:false];

    [self.vidplayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(180));
        make.width.equalTo(@(self.view.frame.size.width));
    }];
    [self.vidplayer setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationClosing:) name:
     UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpening:) name:
     UIApplicationWillEnterForegroundNotification object:nil];
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    NSMutableDictionary *video = nil;
   
    video = [[NSMutableDictionary alloc] init];
    [video setObject:getSelectedURl forKey:OLCPlayerVideoURL];
    [video setValue:@0 forKey:OLCPlayerPlayTime];
    [videos addObject:video];
    playlist = videos;
    [self.vidplayer playVideos:playlist];
    [self.vidplayer continusPlay:NO];
    [self.vidplayer shuffleVideos:NO];
   // self.vidplayer.transform = CGAffineTransformRotate(self.vidplayer.transform, M_PI_2);

    [_collectionView reloadData];
}

#pragma mark - Show Video List Methods

- (void)buildAssetsLibrary
{
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibrary *notificationSender = nil;
    videoURLArray = [[NSMutableArray alloc] init];
    _imagesTHumbnailarray = [[NSMutableArray alloc] init];
    _videosURLArray = [[NSMutableArray alloc] init];
    _videosTitlearray = [[NSMutableArray alloc] init];
    NSString *minimumSystemVersion = @"4.1";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion compare:minimumSystemVersion options:NSNumericSearch] != NSOrderedAscending)
        notificationSender = assetsLibrary;
    [self updateAssetsLibrary];
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.vidplayer shutdown];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)assetsLibraryDidChange:(NSNotification*)changeNotification
{
    [self updateAssetsLibrary];
}

- (void)updateAssetsLibrary
{
    assetItems = [NSMutableArray arrayWithCapacity:0];
    ALAssetsLibrary *assetLibrary = assetsLibrary;
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  if (asset)
                  {
                      dic = [[NSMutableDictionary alloc] init];
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      NSString *uti = [defaultRepresentation UTI];
                      videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];

                      NSString *title = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"Video", nil), [assetItems count]+1];
                      
                      [self performSelector:@selector(imageFromVideoURL)];
                      [dic setValue:title forKey:@"VideoTitle"];//kName
                      [dic setValue:videoURL forKey:@"VideoUrl"];//kURL
                      AssetBrowserItem *item = [[AssetBrowserItem alloc] initWithURL:videoURL title:title];
                      [assetItems addObject:item];
                      [videoURLArray addObject:dic];
                  }
                _imagesTHumbnailarray = [videoURLArray valueForKey:@"ImageThumbnail"];
                  _videosTitlearray = [videoURLArray valueForKey:@"VideoTitle"];
                  _videosURLArray = [videoURLArray valueForKey:@"VideoUrl"];
                  [_collectionView reloadData];

              } ];
         }
         else{
         }
     }
    failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];

}

- (UIImage *)imageFromVideoURL
{
    UIImage *image = nil;
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    // calc midpoint time of video
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    // get the image from
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL)
    {
        // cgimage to uiimage
        image = [[UIImage alloc] initWithCGImage:halfWayImage];
        [dic setValue:image forKey:@"ImageThumbnail"];//kImage
        CGImageRelease(halfWayImage);
    }
    return image;
}

#pragma mark - OLCVideoPlayer Controlls

- (IBAction)btnPlayPauseClicked:(id)sender {
    
    if([self.vidplayer isPlaying]){
        [self.vidplayer pause];
    }
    else{
        [self.vidplayer play];
    }
}

- (IBAction)btnNextClicked:(id)sender {
          
    [self.vidplayer playNext];
}

- (IBAction)btnPreviousClicked:(id)sender {
    
    [self.vidplayer playPrevious];
}

- (IBAction)sldVolumeChanged:(id)sender {
    
    float volume = ((UISlider*) sender).value;
    [self.vidplayer setVolume:volume];
}

- (IBAction)btnStopClicked:(id)sender {
    
    [self.vidplayer shutdown];
}

#pragma mark - OLCVideoPlayer Delegates

- (void) onVideoTrackChanged:(NSUInteger)index
{
  //  self.sldVolume.value = [self.vidplayer getVolume];
}

- (void) onFinishPlaying:(NSUInteger)index{
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


@end
