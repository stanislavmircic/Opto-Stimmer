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
SCSliderCell *freqSlider;
SCSliderCell *pulseWidthSlider;
SCSliderCell *durationSlider;
SCSwitchCell *randomCell;
SCSliderCell *batterySlider;
SCTextFieldCell *firmwareCell;
SCTextFieldCell *hardwareCell;
    
}
@end

@implementation BYBRoboRoachSettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [freqSlider setEnabled:YES];
    [pulseWidthSlider setEnabled:YES];

    
    [UIApplication sharedApplication].statusBarHidden = YES;
    //self.roboRoach.duration = [NSNumber numberWithDouble:[self.roboRoach.numberOfPulses  doubleValue] * 1000 / [self.roboRoach.frequency doubleValue]];
    

    tableViewModel = [[SCTableViewModel alloc] initWithTableView:self->tableView] ;
    tableViewModel.tableView.scrollEnabled = NO;
    //tableViewModel.tableView.scrollsToTop = YES;
    
    SCTableViewSection *stimulationSection = [SCTableViewSection sectionWithHeaderTitle:@"Stimulation Parameters"];
    
    [tableViewModel addSection:stimulationSection];
    
    /*gainSlider = [SCSliderCell cellWithText:@"Gain" boundObject:self.roboRoach boundPropertyName:@"gain" ];
    gainSlider.slider.minimumValue = 0;
    gainSlider.slider.maximumValue = 100;
    
    [stimulationSection addCell:gainSlider];*/
    
    durationSlider = [SCSliderCell cellWithText:@"Duration" boundObject:self.roboRoach boundPropertyName:@"duration"  ];
    durationSlider.slider.minimumValue = 10;
    durationSlider.slider.maximumValue = (float)MAX_STIMULATION_TIME;
    [stimulationSection addCell:durationSlider];
    
   /* randomCell = [SCSwitchCell cellWithText:@"Random Mode" boundObject:self.roboRoach boundPropertyName:@"randomMode"];
    [stimulationSection addCell:randomCell];
    */
    
    freqSlider = [SCSliderCell cellWithText:@"Frequency" boundObject:self.roboRoach boundPropertyName:@"frequency"  ];
    freqSlider.slider.minimumValue = 0.5;
    freqSlider.slider.maximumValue = 125;
    [stimulationSection addCell:freqSlider];
    
    pulseWidthSlider = [SCSliderCell cellWithText:@"Pulse Width" boundObject:self.roboRoach boundPropertyName:@"pulseWidth"  ];
    pulseWidthSlider.slider.minimumValue = 1;
    pulseWidthSlider.slider.maximumValue = 200;
    [stimulationSection addCell:pulseWidthSlider];

#if 0
    
    batterySlider = [SCSliderCell cellWithText:@"Battery Level" boundObject:self.roboRoach boundPropertyName:@"batteryLevel"  ];
    batterySlider.slider.minimumValue = 1;
    batterySlider.slider.maximumValue = 100;
    batterySlider.slider.enabled = NO;
   
    
    //#if 0
    //[stimulationSection addCell:batterySlider];
    //#else
    SCTableViewSection *deviceSection = [SCTableViewSection sectionWithHeaderTitle:@"RoboRoach Device Information"];
    [tableViewModel addSection:deviceSection];
    
    [deviceSection addCell:batterySlider];
    
    firmwareCell = [SCTextFieldCell cellWithText:@"Firmware" boundObject:self.roboRoach boundPropertyName:@"firmwareVersion"];
    firmwareCell.textField.enabled = NO;
    [deviceSection addCell:firmwareCell];

    hardwareCell = [SCTextFieldCell cellWithText:@"Hardware" boundObject:self.roboRoach boundPropertyName:@"hardwareVersion"];
    hardwareCell.textField.enabled = NO;
    [deviceSection addCell:hardwareCell];

#endif
    
    
    [self updateSettingConstraints ];
    [self redrawStimulation];
    
    durationSlider.slider.continuous = YES;
    freqSlider.slider.continuous = YES;
    pulseWidthSlider.slider.continuous = YES;
   // gainSlider.slider.continuous = YES;
  
    //[[tableViewModel tableView] setContentOffset:CGPointZero animated:YES];
    
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

    pw  = [self.roboRoach.pulseWidth floatValue]/MAX_STIMULATION_TIME;
    
    float period;
    if([self.roboRoach.frequency floatValue]<1.0f)
    {
        period = (1.0/[self.roboRoach.frequency floatValue])*((float)(1000.0/MAX_STIMULATION_TIME));
    }
    else
    {
        period = (1.0/((float)[self.roboRoach.frequency intValue]))*((float)(1000.0/MAX_STIMULATION_TIME));
        
    }
    //NSLog(@"pw: %f", pw);
    //NSLog(@"period: %f", period);
    
    float x = STIMLINE_OFFSET;
    float gain = [self.roboRoach.gain floatValue]/100.0;
    
    float totalDuration = 0;
    
    while( totalDuration < [self.roboRoach.duration floatValue]/MAX_STIMULATION_TIME)
    {

        totalDuration += period;
        
        //Go Up
        CGContextAddLineToPoint(context, x, STIMLINE_BASE - ((STIMLINE_BASE - STIMLINE_PEAK) * gain));
        
        //Go Over
        x += pw*POINTS_TO_SEC;

        if(x>=(([self.roboRoach.duration floatValue]/MAX_STIMULATION_TIME)*POINTS_TO_SEC + STIMLINE_OFFSET))
        {
             x =([self.roboRoach.duration floatValue]/MAX_STIMULATION_TIME)*POINTS_TO_SEC +STIMLINE_OFFSET;
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
       if(x>=(([self.roboRoach.duration floatValue]/MAX_STIMULATION_TIME)*POINTS_TO_SEC + STIMLINE_OFFSET))
        {
            x =([self.roboRoach.duration floatValue]/MAX_STIMULATION_TIME)*POINTS_TO_SEC +STIMLINE_OFFSET;
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
    pulseWidthSlider.slider.minimumValue = 1;
    pulseWidthSlider.slider.maximumValue = 1000.0/[self.roboRoach.frequency doubleValue];
    if(pulseWidthSlider.slider.maximumValue > [self.roboRoach.duration doubleValue])
    {
        pulseWidthSlider.slider.maximumValue = [self.roboRoach.duration doubleValue];
    }

    //NSLog(@"pulseWidthSlider.slider.maximumValue: %f", pulseWidthSlider.slider.maximumValue);
    //NSLog(@"Num Pulses: %@", self.roboRoach.numberOfPulses);
    
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
    
    //Fix a bug with SCTableView calling scroll event on zombie object.
    //tableViewModel.delegate = nil;
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
       
        //Fix a bug with SCTableView calling scroll event on zombie object.
        //[tableViewModel tableView].scrollEnabled = NO;
        //[[tableViewModel tab] setContentOffset:CGPointZero animated:YES];

        //tableViewModel.delegate = nil;
        
    
        
        
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
@end
