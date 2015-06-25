//
//  BYBRoboRoachViewController.m
//  RoboRoach
//
//  Created by Greg Gage on 4/13/13.
//  Copyright (c) 2013 Backyard Brains. All rights reserved.
//

#import "BYBRoboRoachViewController.h"
#import "BYBRoboRoachSettingsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define STATE_DISCONNECTED 0
#define STATE_CONNECTING 1
#define STATE_CONNECTED 2


#define iPhone4 0
#define iPhone5 1
#define iPhone6 2
#define iPhone6Plus 3

@interface BYBRoboRoachViewController() {
    
    __weak IBOutlet UIBarButtonItem *bookmarkButton;
    __weak IBOutlet UIBarButtonItem *stimulationSettingsButton;
    
    __weak IBOutlet UISegmentedControl *bookmarkBar;
    
    IBOutlet UIActivityIndicatorView *spinner;
    __weak IBOutlet UILabel *goRight;
    __weak IBOutlet UILabel *goLeft;
    IBOutlet UIImageView *roachImage;
    IBOutlet UIImageView *backpackImage;
    IBOutlet UIImageView *batteryImage;
    
    __weak IBOutlet UILabel *stimulationSettings;
    
    IBOutlet UIButton * connectButton;
    
    
    
    float sWidth;
    float sHeight;
    
    BYBRoboRoachManager * rr; //RoboRoach class (private)
    
    UIButton * recordBTN;
    UIButton * stimulateBTN;
    UIButton * connectBTN;
    UIActivityIndicatorView * connectingIndicator ;
    UIButton * configBTN;
    BOOL recordingStarted;
    UIView* overlayView;
    int currentState;
    int deviceSize;
    
    GPUImageVideoCamera *videoCamera;
    GPUImageBrightnessFilter *brightnessFilter;
    GPUImageTransformFilter * transformFilter;
    GPUImageMovieWriter *movieWriter;
    GPUImageUIElement *uiElementInput;
    GPUImageAlphaBlendFilter *blendFilter;
    NSDate * stimulationTime;
    
    UIView * infoView;
    UILabel *widthLabel;
    UILabel *durationLabel;
    UILabel * freqLabel;
    UILabel * stimulationLabel;
    NSString *pathToMovie;
    
    float currentZoom;
}
@end


@implementation BYBRoboRoachViewController

BOOL isConnected = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    currentZoom = 1.0;
    stimulationTime = [NSDate date];
    currentState = STATE_DISCONNECTED;
    [UIApplication sharedApplication].statusBarHidden = YES;

    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    //----------------HERE WE SETUP FOR IPHONE 4/4s/iPod----------------------
    
    sWidth = iOSDeviceScreenSize.width;
    sHeight = iOSDeviceScreenSize.height;
    
    if (iOSDeviceScreenSize.height == 480){
        deviceSize = iPhone4;
    }else if (iOSDeviceScreenSize.height == 568){
        deviceSize = iPhone5;
    }else if (iOSDeviceScreenSize.height == 667){
        deviceSize = iPhone6;
    } else if (iOSDeviceScreenSize.height == 736){
        deviceSize = iPhone6Plus;
    }
    else
    {
         deviceSize = iPhone6;
    }
    
    
    
    switch (deviceSize) {
        case iPhone4:
                videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
            break;
        case iPhone5:
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
            break;
        case iPhone6:
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
            break;
        case iPhone6Plus:
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
            break;
        default:
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
            break;
    }
    

    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    transformFilter = [[GPUImageTransformFilter alloc] init];
    [transformFilter setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
 
    [videoCamera addTarget:transformFilter];
    
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [brightnessFilter setBrightness:0.0];
    
    [transformFilter addTarget:brightnessFilter];
    
    
    
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    

    
    [self setupVideoRecorder];
    
    
    
    
    blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,sWidth, sHeight)];

    
    float xPosition = (50.0/640.0)*sWidth;
    float yStep = (30.0/1136.0)*sHeight;
    float xWidth = (190.0/640.0)*sWidth;
    float yHeight = (30.0/1136.0)*sHeight;
    float fontSize = (26.0/1136.0)*sHeight;
    
    
    infoView.backgroundColor = [UIColor clearColor];
    
    widthLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yStep, xWidth, yHeight)];
    widthLabel.font = [UIFont systemFontOfSize:fontSize];
    widthLabel.text = @"Pulse: 9 ms";
    widthLabel.backgroundColor = [UIColor clearColor];
    widthLabel.textColor = [UIColor whiteColor];
    [infoView addSubview:widthLabel];
 
    durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, 2*yStep, xWidth, yHeight)];
    durationLabel.font = [UIFont systemFontOfSize:fontSize];
    durationLabel.text = @"Dur: 1000 ms";
    durationLabel.backgroundColor = [UIColor clearColor];
    durationLabel.textColor = [UIColor whiteColor];
    [infoView addSubview:durationLabel];
    
    freqLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, 3*yStep, xWidth, yHeight)];
    freqLabel.font = [UIFont systemFontOfSize:fontSize];
    freqLabel.text = @"Freq: 3 Hz";
    freqLabel.backgroundColor = [UIColor clearColor];
    freqLabel.textColor = [UIColor whiteColor];
    [infoView addSubview:freqLabel];
    
    
    
    stimulationLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, 4.2*yStep, xWidth, yHeight)];
    stimulationLabel.font = [UIFont systemFontOfSize:fontSize];
    stimulationLabel.text = @"Stimulation";
    stimulationLabel.textAlignment = NSTextAlignmentCenter;
    stimulationLabel.backgroundColor = [UIColor redColor];
    stimulationLabel.textColor = [UIColor whiteColor];
    stimulationLabel.hidden = YES;
    [infoView addSubview:stimulationLabel];
    
    
    
    uiElementInput = [[GPUImageUIElement alloc] initWithView:infoView];
    
    [brightnessFilter addTarget:blendFilter];
    [uiElementInput addTarget:blendFilter];
    
    [blendFilter addTarget:filterView];
    [blendFilter addTarget:movieWriter];
    
    __unsafe_unretained GPUImageUIElement *weakUIElementInput = uiElementInput;
    
    [brightnessFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        infoView.hidden = !(currentState == STATE_CONNECTED);
        [self updateTextForParametersLabels];
        if(currentState == STATE_CONNECTING)
        {
            [connectingIndicator startAnimating];
        }
        else
        {
            [connectingIndicator stopAnimating];
        }
        if([stimulationTime timeIntervalSinceNow] >-1.0)
        {
            stimulationLabel.hidden = NO;
        }
        else
        {
            stimulationLabel.hidden = YES;
        }
       // timeLabel.text = [NSString stringWithFormat:@"Time: %f s", -[stimulationTime timeIntervalSinceNow]];
        [weakUIElementInput update];
    }];
    
    [videoCamera startCameraCapture];
    

    recordingStarted = NO;
    
    rr = [[BYBRoboRoachManager alloc] init];   // Init BYBRoboRoachManager class.
    rr.delegate = self;  //Start recieveing RoboRoach updates
    
    [self setupControlls];

}


-(void) setupVideoRecorder
{
    pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(sWidth, sHeight)];
    
    movieWriter.encodingLiveVideo = YES;
    movieWriter.delegate = self;

}


-(void) setupControlls
{

    overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    
    float buttonSize = 67.0f;
    CGRect buttonFrame = CGRectMake( self.view.frame.size.width-20-buttonSize, 30, buttonSize, buttonSize );
    recordBTN = [[UIButton alloc] initWithFrame: buttonFrame];
    [recordBTN setBackgroundImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
    [recordBTN addTarget:self action:@selector(recordPressed:) forControlEvents: UIControlEventTouchUpInside];
    [overlayView addSubview:recordBTN];
    
    CGRect buttonFrame2 = CGRectMake( 0.5*self.view.frame.size.width-0.5*buttonSize, self.view.frame.size.height-30-buttonSize, buttonSize, buttonSize );
    stimulateBTN = [[UIButton alloc] initWithFrame: buttonFrame2];
    [stimulateBTN setBackgroundImage:[UIImage imageNamed:@"stimulate.png"] forState: UIControlStateNormal];
    [stimulateBTN setBackgroundImage:[UIImage imageNamed:@"stimulatepress.png"] forState: UIControlStateHighlighted];
    [stimulateBTN addTarget:self action:@selector(stimulate:) forControlEvents: UIControlEventTouchDown];
    [overlayView addSubview:stimulateBTN];
    
    
    CGRect buttonFrame3 = CGRectMake(  self.view.frame.size.width-20-buttonSize, self.view.frame.size.height-30-buttonSize, buttonSize, buttonSize );
    connectBTN = [[UIButton alloc] initWithFrame: buttonFrame3];
    [connectBTN setBackgroundImage:[UIImage imageNamed:@"disconnected.png"] forState: UIControlStateNormal];
    [connectBTN addTarget:self action:@selector(connectBTNHandler:) forControlEvents: UIControlEventTouchDown];
    [overlayView addSubview:connectBTN];
    
    
    connectingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge ];
    connectingIndicator.frame = buttonFrame3;
    [overlayView addSubview:connectingIndicator];
    
    
    CGRect buttonFrame4 = CGRectMake( 20, self.view.frame.size.height-30-buttonSize, buttonSize, buttonSize );
    configBTN = [[UIButton alloc] initWithFrame: buttonFrame4];
    [configBTN setBackgroundImage:[UIImage imageNamed:@"configuration.png"] forState: UIControlStateNormal];
    [configBTN addTarget:self action:@selector(configurationBTNHandler:) forControlEvents: UIControlEventTouchDown];
    [overlayView addSubview:configBTN];
    
    
    
    [overlayView.layer setOpaque:NO];
    overlayView.opaque = NO;
    
    
    //Add gestures
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 1;
    [overlayView addGestureRecognizer: panGesture];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [overlayView addGestureRecognizer:swipeRight];
    
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [overlayView addGestureRecognizer:pinchGestureRecognizer];
    
    
    
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [overlayView addGestureRecognizer:singleFingerTap];
    
    
    
    [self refreshViewState];
 
    [self.view addSubview:overlayView];
    [self.view bringSubviewToFront:overlayView];

}


- (void)viewDidUnload {
    NSLog(@"viewDidUnload");
  
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"didReceiveMemoryWarning");
}

//================================= Init and state ==========================================================
#pragma mark - Init and state


-(void) refreshViewState
{

    switch (currentState) {
        case STATE_DISCONNECTED:
            configBTN.hidden = YES;
            stimulateBTN.hidden = YES;
            recordBTN.hidden = YES;
            connectBTN.hidden = NO;
            connectingIndicator.hidden = YES;
            [connectBTN setBackgroundImage:[UIImage imageNamed:@"disconnected.png"] forState: UIControlStateNormal];
            break;
        case STATE_CONNECTING:
            configBTN.hidden = YES;
            stimulateBTN.hidden = YES;
            recordBTN.hidden = YES;
            connectBTN.hidden = NO;
            connectingIndicator.hidden = NO;
            [connectBTN setBackgroundImage:[UIImage imageNamed:@"blanckbutton.png"] forState: UIControlStateNormal];
            break;
        case STATE_CONNECTED:
            configBTN.hidden = NO;
            stimulateBTN.hidden = NO;
            recordBTN.hidden = NO;
            connectBTN.hidden = NO;
            connectingIndicator.hidden = YES;
            [connectBTN setBackgroundImage:[UIImage imageNamed:@"connected.png"] forState: UIControlStateNormal];
            break;
        default:
            break;
    }
}




//===========================================================================================
#pragma mark - Actions

-(void) configurationBTNHandler:(id) item
{
    //stop recording
    [self stopVideoAndSaveToLibrary];
    
    //Open config screen
    UIStoryboard *storyBoard = self.storyboard;
    BYBRoboRoachSettingsViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"BYBRoboRoachSettingsViewController"];
    viewController.roboRoach = rr.activeRoboRoach;
    viewController.masterDelegate = self;
   // self.cameraUI.cameraOverlayView = viewController.view;
    
   
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:viewController];

 
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void) applySettings
{
    //self.cameraUI.cameraOverlayView = overlayView;
    [self dismissViewControllerAnimated:YES completion:nil];
    connectingIndicator.hidden = YES;
   // [self updateTextForParametersLabels];
}

-(void) updateTextForParametersLabels
{
    if(rr.activeRoboRoach.pulseWidth)
    {
        widthLabel.text =[NSString stringWithFormat:@"Pulse: %d ms",[rr.activeRoboRoach.pulseWidth intValue]];
        durationLabel.text = [NSString stringWithFormat:@"Dur: %d ms",[rr.activeRoboRoach.duration intValue]];
        
        if([rr.activeRoboRoach.frequency floatValue]<1.0f)
        {
            freqLabel.text = [NSString stringWithFormat:@"Freq: %.01f Hz",[rr.activeRoboRoach.frequency floatValue]];
        }
        else
        {
           freqLabel.text = [NSString stringWithFormat:@"Freq: %i Hz",[rr.activeRoboRoach.frequency intValue]];
        }

        widthLabel.hidden = NO;
        durationLabel.hidden = NO;
        freqLabel.hidden = NO;
    }
    else
    {
        widthLabel.hidden = YES;
        durationLabel.hidden = YES;
        freqLabel.hidden = YES;
       // [self performSelector:@selector(updateTextForParametersLabels) withObject:nil afterDelay:0.5];
       // NSLog(@"RR is not ready for printing settings");
    }
}


-(void) connectBTNHandler:(id) item
{

#if TARGET_IPHONE_SIMULATOR
    
    NSLog(@"Running in Simulator");
    [self didConnectToRoboRoach:YES];
    [self configurationBTNHandler:nil];
    
#else
    [self connectButtonClicked:nil];
    if (!isConnected) {
        currentState = STATE_CONNECTING;
        [connectingIndicator startAnimating];
        
        [connectBTN setEnabled:NO];
        
        [rr searchForRoboRoaches:4];
        
    }else{
        //currentState = STATE_DISCONNECTED;
        currentState = STATE_CONNECTING;
        [rr disconnectFromRoboRoach];
        isConnected = NO;
    }
    [self refreshViewState];
#endif
}

-(void) recordPressed:(id) item
{
    if(recordingStarted)
    {
        [self stopVideoAndSaveToLibrary];

    }
    else
    {
        NSLog(@"Record video");
        [recordBTN setBackgroundImage:[UIImage imageNamed:@"stoprec.png"] forState: UIControlStateNormal];
       // [self.cameraUI startVideoCapture];
        videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
        recordingStarted = YES;
    }
    
}


-(void) stopVideoAndSaveToLibrary
{
    if(recordingStarted)
    {
        [recordBTN setBackgroundImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
        videoCamera.audioEncodingTarget = nil;
        [movieWriter finishRecordingWithCompletionHandler:^{
           UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, self,  @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
            
        }];
        recordingStarted = NO;
        
    }
}

- (void)video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{

    if(error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError* error2;
    [manager removeItemAtPath:pathToMovie error:&error2];
    if(error2)
    {
        NSLog(@"%@",[error2 localizedDescription]);
    }
    
    [blendFilter removeTarget:movieWriter];
    movieWriter = nil;
    
    [self setupVideoRecorder];
    [blendFilter addTarget:movieWriter];
    
}

-(void) stimulate:(id) item
{
    if ( isConnected ) {
        NSLog(@"Stimulate");
        [rr.activeRoboRoach goRight ];
        stimulationTime = [NSDate date];
       // videoCamera.frameRate = 120;
       // [self performSelector:@selector(resetFrameRate) withObject:nil afterDelay:1.0];
    }
}

/*-(void) resetFrameRate
{
    videoCamera.frameRate = 0;
}*/

#pragma mark - Video protocol
- (void)movieRecordingCompleted
{
   //do nothing. We are doing everithing in stopVideoAndSaveToLibrary
}

- (void)movieRecordingFailedWithError:(NSError*)error
{
    NSLog(@"Video failed with error: %@", error.localizedDescription);
}



//===========================================================================================
#pragma mark - Video handlers



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Finish picking media");
    NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
    NSString *pathToVideo = [videoURL path];
    BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
    if (okToSaveVideo) {
        UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, nil, NULL);
    } else {
        //[self video:pathToVideo didFinishSavingWithError:nil contextInfo:NULL];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Video error"
                                                          message:@"Error when trying to save video."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}



/*- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel video");
    [recordBTN setBackgroundImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
    [self.cameraUI stopVideoCapture];
    recordingStarted = NO;
}

- (void)imagePickerControllerDidCancelAndDismiss:(UIImagePickerController *)picker
{
    NSLog(@"Cancel video");
    [recordBTN setBackgroundImage:[UIImage imageNamed:@"record.png"] forState: UIControlStateNormal];
    [self.cameraUI stopVideoCapture];
    recordingStarted = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}*/

//===========================================================================================
#pragma mark - Connection handlers



- (void) didFinsihReadingRoboRoachValues {
    NSLog(@"didFinsihReadingRoboRoachValues");
    
    [stimulationSettings setText:[rr.activeRoboRoach getStimulationString]];
    [stimulationSettings setHidden:NO];
    
    [batteryImage setAlpha:1];
    
    if ([rr.activeRoboRoach.batteryLevel integerValue] > 90)
    {
        batteryImage.image = [UIImage imageNamed: @"battery-95.png"];
    }else if ([rr.activeRoboRoach.batteryLevel integerValue] > 80)
    {
        batteryImage.image = [UIImage imageNamed: @"battery-90.png"];
    }else if ([rr.activeRoboRoach.batteryLevel integerValue] > 70)
    {
        batteryImage.image = [UIImage imageNamed: @"battery-80.png"];
    }else if ([rr.activeRoboRoach.batteryLevel integerValue] > 60)
    {
        batteryImage.image = [UIImage imageNamed: @"battery-50.png"];
    }else if ([rr.activeRoboRoach.batteryLevel integerValue] > 50)
    {
        batteryImage.image = [UIImage imageNamed: @"battery-25.png"];
    }else{
        batteryImage.image = [UIImage imageNamed: @"battery-0.png"];
    }
    
    
}


- (void) didSearchForRoboRoaches: (NSArray*)foundRoboRoaches{
    NSLog(@"didSearchForRoboRoaches:foundRoboRoaches[%i]",foundRoboRoaches.count);
    
    [spinner setHidden:YES];
    [spinner stopAnimating];
    
    if (foundRoboRoaches.count > 0 ){
        /*[backpackImage setAlpha:0.25];
         [backpackImage setHidden:NO];
         [batteryImage setAlpha:0.25];
         [batteryImage setHidden:NO];*/
        
        [connectButton setTitle:@"Connecting..." forState: UIControlStateDisabled];
        [connectButton setEnabled:NO];
        
        
        //Select the first RoboRoach
        [rr connectToRoboRoach:foundRoboRoaches[0]];
        
    }
    else{
        [self didDisconnectFromRoboRoach];
    }
    
}

- (void) didDisconnectFromRoboRoach {
    NSLog(@"didDisconnectFromRoboRoach");
    isConnected = NO;
    
    
    //stop recording
    [self stopVideoAndSaveToLibrary];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.sessionBTN setHidden:YES];
    [connectBTN setEnabled:YES];
    currentState = STATE_DISCONNECTED;
    [self refreshViewState];
    
}

- (void) roboRoachReady {
    NSLog(@"roboRoachReady");
    
    isConnected = YES;
    
    [connectBTN setEnabled:YES];
    currentState = STATE_CONNECTED;
    [self refreshViewState];

    
}


- (void) hadBluetoothError: (int) CMState{
    
    NSLog( @"hadBluetoothError delegate in RRViewController");
    
    NSString *errorText;
    
    
    switch(CMState) {
        case 0: //CBCentralManagerStateUnknown:
            errorText = @"Strange... Your bluetooth is in an unknown state.  Try restarting the application or your phone.";
            break;
        case 1: //CBCentralManagerStateResetting:
            errorText = @"It seems your BlueTooth on your phone is resetting.  Wait a few seconds and try again.";
            break;
        case 2: //CBCentralManagerStateUnsupported:
            errorText = @"Sadly, BlueTooth is Not Supported on this device.  You need an iPhone 4s or iPod Touch 5th Generation or later.";
            break;
        case 3: //CBCentralManagerStateUnauthorized:
            errorText = @"Your phone is not authorized to use Bluetooth";
            break;
        case 4: //CBCentralManagerStatePoweredOff:
            errorText = @"Your BlueTooth is currently powered off.  Please turn it on to use the OptoStimmer.";
            break;
        case 5: //CBCentralManagerStatePoweredOn:
            errorText = @"State powered up and ready (CBCentralManagerStatePoweredOn)";
            break;
        default:
            errorText = @"Your BlueTooth is in an Unkown State.";
    }
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Bluetooth Error"
                                                      message:errorText
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


- (void) didConnectToRoboRoach: (BOOL)success{
    NSLog(@"didConnectToRoboRoach:success[%i]",success);
    rr.activeRoboRoach.delegate = self;
    [stimulationSettingsButton setEnabled:YES];
    isConnected = YES;
}

//===========================================================================================
#pragma mark - Settings function

//RoboRoach Delgate Methods
- (void) roboRoachHasChangedSettings:(BYBRoboRoach *)roboRoach{
    //Confusing Architecture.  Think about renaming it.
    NSLog(@"roboRoachHasChangedSettings++");
    
    [bookmarkBar setSelectedSegmentIndex:5]; //Other
    //NSLog(@"Updated Bar");
    
    [rr sendUpdatedSettingsToActiveRoboRoach];
    //NSLog(@"Finished sendUpdatedSettingsToActiveRoboRoach");
    
    [stimulationSettings setText:[rr.activeRoboRoach getStimulationString]];
    //NSLog(@"stimulationSettings Text Updated");
    
    NSLog(@"roboRoachHasChangedSettings--");
    
}


-(void) handlePan:(UIPanGestureRecognizer *) pan
{
    
    if(pan.numberOfTouches  == 1)
    {
        CGPoint translation = [pan velocityInView:self.view];
        NSLog(@"Pan: x: %f      y: %f", translation.x, translation.y);
        if(fabsf(translation.y)*3.0<fabsf(translation.x))
        {
            float relativeSizeOfTranslation = translation.x/(300.0*self.view.frame.size.width);
            if(relativeSizeOfTranslation<-1.0)
            {
                relativeSizeOfTranslation = -1;
            }
            if(relativeSizeOfTranslation > 1.0)
            {
                relativeSizeOfTranslation = 1.0;
            }
            brightnessFilter.brightness += relativeSizeOfTranslation;
        }
    }
}


-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    
    currentZoom+=pinchGestureRecognizer.velocity/30.0;
    if (currentZoom<1.0) {
        currentZoom = 1.0;
    }
    if(currentZoom>9.0)
    {
        currentZoom = 9.0;
    }
    NSLog(@"Zoom: %f", currentZoom);
    [transformFilter setAffineTransform:CGAffineTransformMakeScale(currentZoom,currentZoom)];
}

//
//Handle single tap and zoom
//
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:overlayView];
    location.x /= overlayView.frame.size.width;
    location.y /= overlayView.frame.size.height;
    
    [videoCamera focusAtPoint:location];
}



//===========================================================================================
#pragma mark - Old functions


- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    
     if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
         
     }
     else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
         
     }
    
}

- (void) bookmarkedStimulationSelected {
    
        switch( bookmarkBar.selectedSegmentIndex) {
            case 0: //5Hz
                rr.activeRoboRoach.frequency = @5;
                rr.activeRoboRoach.pulseWidth = @20;
                rr.activeRoboRoach.duration = @600;
                rr.activeRoboRoach.randomMode = @0;
                break;
            case 1: //15Hz
                rr.activeRoboRoach.frequency = @15;
                rr.activeRoboRoach.pulseWidth = @20;
                rr.activeRoboRoach.duration = @600;
                rr.activeRoboRoach.randomMode = @0;
                break;
            case 2: //30Hz
                rr.activeRoboRoach.frequency = @30;
                rr.activeRoboRoach.pulseWidth = @10;
                rr.activeRoboRoach.duration = @600;
                rr.activeRoboRoach.randomMode = @0;
                break;
            case 3: //55Hz
                rr.activeRoboRoach.frequency = @55;
                rr.activeRoboRoach.pulseWidth = @9;
                rr.activeRoboRoach.duration = @600;
                rr.activeRoboRoach.randomMode = @0;
                break;
            case 4: //100Hz
                rr.activeRoboRoach.frequency = @100;
                rr.activeRoboRoach.pulseWidth = @5;
                rr.activeRoboRoach.duration = @600;
                rr.activeRoboRoach.randomMode = @0;
                break;
        }
        
    [rr sendUpdatedSettingsToActiveRoboRoach];
    [stimulationSettings setText:[rr.activeRoboRoach getStimulationString]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"roboRoachSettingsSegue"])
    {
        // Get reference to the destination view controller
        BYBRoboRoachSettingsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.roboRoach = rr.activeRoboRoach;
    }
}

- (IBAction)startSession:(id)sender {
    
   // [self startCameraControllerFromViewController: self usingDelegate: self];
}

- (void) sideIndicatorTimer:(NSTimer *)timer {
    goRight.hidden = YES;
    goLeft.hidden = YES;
}

- (IBAction)favoritesClicked:(id)sender {
    
    if (bookmarkBar.hidden)
    {
        bookmarkBar.hidden = NO;
    }
    else
    {
        bookmarkBar.hidden = YES;
    }
    
}

- (void) roboRoach: (BYBRoboRoach *)roboRoach hasMovementCommand:(BYBMovementCommand) command{
    
    if (command == moveLeft){
        NSLog(@"Go Left");
        goLeft.hidden = NO;
        
        [rr sendMoveCommandToActiveRoboRoach:moveLeft];
    } else if (command == moveRight){
        NSLog(@"Go Right");
        goRight.hidden = NO;
        [rr sendMoveCommandToActiveRoboRoach:moveRight];
        
    }
    
    [NSTimer scheduledTimerWithTimeInterval:ROBOROACH_TURN_TIMEOUT target:self selector:@selector(sideIndicatorTimer:) userInfo:nil repeats:NO];
}

- (IBAction)connectButtonClicked:(id)sender {
    
    /* if (!isConnected) {
     
     [connectingIndicator startAnimating];
     
     [connectBTN setEnabled:NO];
     
     [rr searchForRoboRoaches:4];
     
     }else{
     [rr disconnectFromRoboRoach];
     isConnected = NO;
     
     }*/
}

@end
