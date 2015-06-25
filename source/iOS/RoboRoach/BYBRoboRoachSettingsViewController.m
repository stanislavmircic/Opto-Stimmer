//
//  BYBRoboRoachSettingsViewController.m
//  RoboRoach
//
//  Created by Greg Gage on 4/17/13.
//  Copyright (c) 2013 Backyard Brains. All rights reserved.
//

#import "BYBRoboRoachSettingsViewController.h"
#import "BYBRoboRoach.h"


#define BYB_MIN_STIMULATE_PULSE_WIDTH               1
#define BYB_MAX_STIMULATE_PULSE_WIDTH               9
#define BYB_MIN_STIMULATE_PERIOD                    10
#define BYB_MAX_STIMULATE_PERIOD                    25


@interface BYBRoboRoachSettingsViewController (){
    UITextField * activeField;
    float maxStimulationTime;
    float frequencyMinimumValue;
    CGPoint tempScrollOffset;
}
@end

@implementation BYBRoboRoachSettingsViewController
@synthesize freqSlider;
@synthesize pulseWidthSlider;
@synthesize durationSlider;
@synthesize frequencyTI;
@synthesize durationTI;
@synthesize pulseWidthTi;
@synthesize scrollViewBackground;

- (void)viewDidLoad
{
    maxStimulationTime = 1000.0f;
    [super viewDidLoad];
    if([self.roboRoach.firmwareVersion isEqualToString:@"1.0"])
    {
        maxStimulationTime = 1000.0f;
        frequencyMinimumValue = 1.0f;
    }
    else if ([self.roboRoach.firmwareVersion isEqualToString:@"0.81"] || [self.roboRoach.firmwareVersion isEqualToString:@"0.8"])
    {
        maxStimulationTime = 2000.0f;
        frequencyMinimumValue = 0.5f;
    }

    activeField = nil;
    [freqSlider setEnabled:YES];
    [pulseWidthSlider setEnabled:YES];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    durationSlider.minimumValue = 10;
    durationSlider.maximumValue = maxStimulationTime;
    [durationSlider setValue:[self.roboRoach.duration floatValue]];
    
    freqSlider.minimumValue = frequencyMinimumValue;
    freqSlider.maximumValue = 125;
    [freqSlider setValue:[self.roboRoach.frequency floatValue]];

    pulseWidthSlider.minimumValue = 1;
    pulseWidthSlider.maximumValue = 200;
    [pulseWidthSlider setValue:[self.roboRoach.pulseWidth floatValue]];

    [self updateSettingConstraints ];
    [self redrawStimulation];
    
    durationSlider.continuous = YES;
    freqSlider.continuous = YES;
    pulseWidthSlider.continuous = YES;
    
    
    self.pulseWidthTi.delegate = self;
    self.durationTI.delegate = self;
    self.frequencyTI.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeKeyboardDisapear)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}


-(void) makeKeyboardDisapear
{
    [self.pulseWidthTi resignFirstResponder];
    [self.frequencyTI resignFirstResponder];
    [self.durationTI resignFirstResponder];
}

- (void)addDoneButton {
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view action:@selector(endEditing:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.durationTI.inputAccessoryView = keyboardToolbar;
    self.frequencyTI.inputAccessoryView = keyboardToolbar;
    self.pulseWidthTi.inputAccessoryView = keyboardToolbar;
}

-(void) viewWillAppear:(BOOL)animated
{
   // UINavigationController * localNavigationController = self.navigationController;
   // [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self registerForKeyboardNotifications];
    if ((int)[[UIScreen mainScreen] bounds].size.height > 560)
    {
        self.scrollViewBackground.contentSize=CGSizeMake(320,480);
    }
    else
    {
        self.scrollViewBackground.contentSize=CGSizeMake(320,580);
    }
    [self addDoneButton];
    [self addBackButton];
}

-(void) addBackButton
{
   /* UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(applyBtnClick:)];
    self.navigationItem.leftBarButtonItem = flipButton;*/
    UIBarButtonItem *_backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(applyBtnClick:)];
    self.navigationItem.leftBarButtonItem = _backButton;//.title = @"Back";
    self.navigationItem.leftItemsSupplementBackButton = NO;
   // self.navigationItem.rightBarButtonItem = _backButton;

}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    
    tempScrollOffset = self.scrollViewBackground.contentOffset;
    if(activeField == self.pulseWidthTi)
    {
        if ((int)[[UIScreen mainScreen] bounds].size.height > 560)
        {
            self.scrollViewBackground.contentOffset = CGPointMake(0, 170);
        } else {
            // This is iPhone 4/4s screen
            self.scrollViewBackground.contentOffset = CGPointMake(0, 270);
        }
        
    }
    
    if(activeField == self.frequencyTI)
    {
        if ((int)[[UIScreen mainScreen] bounds].size.height > 560)
        {
            self.scrollViewBackground.contentOffset = CGPointMake(0, 60);
        }
        else
        {
            self.scrollViewBackground.contentOffset = CGPointMake(0, 160);
        }
    }
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //self.scrollViewBackground.contentOffset = CGPointMake(0, 0);
    self.scrollViewBackground.contentOffset = tempScrollOffset;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    [textField resignFirstResponder];
    [self setSliderValuesFromTI];
    [self updateSettingConstraints ];
    [self redrawStimulation];
}


-(BOOL) setSliderValuesFromTI
{
    NSNumber * tempNumber = [[NSNumber alloc] initWithFloat:0.0f];
    if([self stringIsNumeric:self.durationTI.text andNumber:&tempNumber] && ([tempNumber floatValue] >= 10.0f) && ([tempNumber floatValue]<=self.durationSlider.maximumValue))
    {
        
        [self.durationSlider setValue:[tempNumber floatValue]];
         self.roboRoach.duration = [NSNumber numberWithFloat:[tempNumber floatValue]];
    }
    else
    {
        [self validationAlertWithText: [NSString stringWithFormat: @"Enter valid number for duration. (10ms - %dms)",(int)(self.durationSlider.maximumValue)]];
        return NO;
    }
    
    tempNumber = [[NSNumber alloc] initWithFloat:0.0f];
    if([self stringIsNumeric:self.frequencyTI.text andNumber:&tempNumber]  && ([tempNumber floatValue] >= frequencyMinimumValue) && ([tempNumber floatValue]<=self.freqSlider.maximumValue))
    {
        
        [self.freqSlider setValue:[tempNumber floatValue]];
        self.roboRoach.frequency = [NSNumber numberWithFloat:[tempNumber floatValue]];
    }
    else
    {
        [self validationAlertWithText:[NSString stringWithFormat: @"Enter valid number for frequency. (%.01fHz - %dHz)",frequencyMinimumValue, (int)(self.freqSlider.maximumValue)]];
        return NO;
    }
    tempNumber = [[NSNumber alloc] initWithFloat:0.0f];
    if([self stringIsNumeric:self.pulseWidthTi.text andNumber:&tempNumber]  && ([tempNumber floatValue] >= 1.0f) && ([tempNumber floatValue]<=self.pulseWidthSlider.maximumValue))
    {
        
        [self.pulseWidthSlider setValue:[tempNumber floatValue]];
        self.roboRoach.pulseWidth = [NSNumber numberWithFloat:[tempNumber floatValue]];
    }
    else
    {
        [self validationAlertWithText:[NSString stringWithFormat: @"Enter valid number for pulse width. Pulse width is constrained by frequency to interval: 1ms - %dms", (int)(self.pulseWidthSlider.maximumValue)]];
        return NO;
    }

    
    return YES;
}



-(BOOL) stringIsNumeric:(NSString *) str andNumber: (NSNumber**) outNumberValue
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setDecimalSeparator:@"."];
    *outNumberValue = [formatter numberFromString:str];
    return !!(*outNumberValue); // If the string is not numeric, number will be nil
}

-(void) validationAlertWithText:(NSString *) errorString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid value" message:errorString
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}





- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)redrawStimulation
{
    //NSLog(@"Creating image");
    
    //Area of stimulation will be 1s (max) and divided into 1000ms
#define STIMLINE_OFFSET 10.0f
#define STIMLINE_PEAK 10.0f
#define STIMLINE_BASE 100.0f
#define POINTS_TO_SEC 300.0f
    
    //CGSize size = stimImage.image.size;
    CGSize size = CGSizeMake( 320.0f, 130.0f);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 320.0f, 130.0f));
    
    CGContextSetLineWidth(context, 1.2f);
    CGContextMoveToPoint(context, 1.0f, 100.0f);
    CGContextAddLineToPoint(context, STIMLINE_OFFSET, STIMLINE_BASE);
    //NSLog(@"self.roboRoach.numberOfPulses: %@", self.roboRoach.numberOfPulses);
    
    float pw;
    if([self.roboRoach.pulseWidth floatValue]>[self.roboRoach.duration floatValue])
    {
        self.roboRoach.pulseWidth = self.roboRoach.duration;
    }

    pw  = [self.roboRoach.pulseWidth floatValue]/maxStimulationTime;
    
    float period;
    if([self.roboRoach.frequency floatValue]<1.0f)
    {
        period = (1.0/[self.roboRoach.frequency floatValue])*((float)(1000.0/maxStimulationTime));
    }
    else
    {
        period = (1.0/((float)[self.roboRoach.frequency intValue]))*((float)(1000.0/maxStimulationTime));
        
    }
    //NSLog(@"pw: %f", pw);
    //NSLog(@"period: %f", period);
    
    float x = STIMLINE_OFFSET;
    float gain = [self.roboRoach.gain floatValue]/100.0;
    
    float totalDuration = 0;
    
    while( totalDuration < [self.roboRoach.duration floatValue]/maxStimulationTime)
    {

        totalDuration += period;
        
        //Go Up
        CGContextAddLineToPoint(context, x, STIMLINE_BASE - ((STIMLINE_BASE - STIMLINE_PEAK) * gain));
        
        //Go Over
        x += pw*POINTS_TO_SEC;

        if(x>=(([self.roboRoach.duration floatValue]/maxStimulationTime)*POINTS_TO_SEC + STIMLINE_OFFSET))
        {
             x =([self.roboRoach.duration floatValue]/maxStimulationTime)*POINTS_TO_SEC +STIMLINE_OFFSET;
            CGContextAddLineToPoint(context, x, STIMLINE_BASE - ((STIMLINE_BASE - STIMLINE_PEAK) * gain));
            break;
        }
        else
        {
            CGContextAddLineToPoint(context, x, STIMLINE_BASE - ((STIMLINE_BASE - STIMLINE_PEAK) * gain));
        }
        
        //Go Down
        CGContextAddLineToPoint(context, x, STIMLINE_BASE);
        //Go to end

        x += (period - pw)*POINTS_TO_SEC;
       if(x>=(([self.roboRoach.duration floatValue]/maxStimulationTime)*POINTS_TO_SEC + STIMLINE_OFFSET))
        {
            x =([self.roboRoach.duration floatValue]/maxStimulationTime)*POINTS_TO_SEC +STIMLINE_OFFSET;
            CGContextAddLineToPoint(context, x, STIMLINE_BASE);
            break;
        }
        else
        {
            CGContextAddLineToPoint(context, x, STIMLINE_BASE);
        }
        
    }
    
    NSString *strDisplay;
    
    if ( [self.roboRoach.randomMode boolValue]){
        strDisplay = [NSString stringWithFormat:@"Dur=[%i ms] Freq = [Random] ", [self.roboRoach.duration intValue] ];
    }
    else{
        if([self.roboRoach.frequency floatValue]<1.0f)
        {
            strDisplay = [NSString stringWithFormat:@"Dur=[%i ms] Freq = [%.01f Hz], Pulse = [%i ms] ", [self.roboRoach.duration intValue],[self.roboRoach.frequency floatValue], [self.roboRoach.pulseWidth intValue] ];
            
        }
        else
        {
            strDisplay = [NSString stringWithFormat:@"Dur=[%i ms] Freq = [%i Hz], Pulse = [%i ms] ", [self.roboRoach.duration intValue],[self.roboRoach.frequency intValue], [self.roboRoach.pulseWidth intValue] ];
        }
    }
    
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, transform);
    
    CGContextSelectFont(context, "Helvetica", 10.0, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(context, 1.7);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextShowTextAtPoint(context, STIMLINE_OFFSET + 10.0, STIMLINE_BASE + 20, [strDisplay UTF8String], [strDisplay length]);
    
    CGContextStrokePath(context);
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    stimImage.image = result;
    [stimImage setNeedsDisplay];
    
    //NSLog(@"Image creation finished");
}



- (void) updateSettingConstraints {
    
    
    
    float roundedGain = round([self.roboRoach.gain floatValue]/ 5.0f) * 5.0f;
    self.roboRoach.gain = [NSNumber numberWithFloat:roundedGain];
    
    float roundedDuration = round(([self.roboRoach.duration floatValue]/ 10.0f) * 10.0f);
    self.roboRoach.duration = [NSNumber numberWithFloat:roundedDuration];
    
    
    if ([self.roboRoach.pulseWidth doubleValue] > 1000.0/[self.roboRoach.frequency doubleValue])
    {
        self.roboRoach.pulseWidth = [NSNumber numberWithDouble:(1000.0/[self.roboRoach.frequency doubleValue])];
        
    }
    pulseWidthSlider.minimumValue = 1;
    pulseWidthSlider.maximumValue = 1000.0/[self.roboRoach.frequency doubleValue];
    if(pulseWidthSlider.maximumValue > [self.roboRoach.duration doubleValue])
    {
        pulseWidthSlider.maximumValue = [self.roboRoach.duration doubleValue];
    }

    //NSLog(@"pulseWidthSlider.slider.maximumValue: %f", pulseWidthSlider.slider.maximumValue);
    //NSLog(@"Num Pulses: %@", self.roboRoach.numberOfPulses);
    [durationSlider setValue:[self.roboRoach.duration floatValue]];
    [freqSlider setValue:[self.roboRoach.frequency floatValue]];
    [pulseWidthSlider setValue:[self.roboRoach.pulseWidth floatValue]];
    
    self.durationTI.text = [NSString stringWithFormat:@"%d",(int)[self.roboRoach.duration integerValue]];
    if([self.roboRoach.frequency floatValue]<1.0f)
    {
        self.frequencyTI.text = [NSString stringWithFormat:@"%.01f",[self.roboRoach.frequency floatValue]];
    }
    else
    {
        self.frequencyTI.text = [NSString stringWithFormat:@"%d",(int)[self.roboRoach.frequency integerValue]];
    }
    self.pulseWidthTi.text = [NSString stringWithFormat:@"%d",(int)[self.roboRoach.pulseWidth integerValue]];
    [self redrawStimulation];

}

- (void) tableViewModel:(SCTableViewModel *)tableViewModel
valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSettingConstraints ];
}


- (void) tableViewModel:(SCTableViewModel *)tableViewModel
scrollViewDidScroll:(UIScrollView*)scrollView
{
        return;
}


- (void) tableViewModel:(SCTableViewModel *)tableViewModel
    scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:scrollView.contentOffset animated:YES];
}


-(void) viewWillDisappear:(BOOL)animated {

    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {

        NSLog(@"Save settings back to the RoboRoach!");
        [self.roboRoach updateSettings];
    }
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    stimImage = nil;
    [super viewDidUnload];
}
- (IBAction)applyBtnClick:(id)sender {
    
    [self.roboRoach updateSettings];
    [self.masterDelegate applySettings];
    
}
- (IBAction)pulseWidthChange:(id)sender {
    float tempFloat = self.pulseWidthSlider.value;
    self.roboRoach.pulseWidth = [NSNumber numberWithFloat:tempFloat];
    [self updateSettingConstraints];
    [self redrawStimulation];
}

- (IBAction)frequencyChanged:(id)sender {
    float tempFloat = self.freqSlider.value;
    self.roboRoach.frequency = [NSNumber numberWithFloat:tempFloat];
    [self updateSettingConstraints];
    [self redrawStimulation];
}

- (IBAction)durationChanged:(id)sender {
    float tempFloat = self.durationSlider.value;
    self.roboRoach.duration = [NSNumber numberWithFloat:tempFloat];
    [self updateSettingConstraints];
    [self redrawStimulation];
}
@end
