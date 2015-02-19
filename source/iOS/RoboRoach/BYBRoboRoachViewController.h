//
//  BYBRoboRoachViewController.h
//  RoboRoach
//
//  Created by Greg Gage on 4/13/13.
//  Copyright (c) 2013 Backyard Brains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "BYBRoboRoachManager.h"
#import "BYBRoboRoachSettingsViewController.h"
#import "GPUImage.h"

@interface BYBRoboRoachViewController : UIViewController <BYBRoboRoachManagerDelegate, BYBRoboRoachDelegate, BYBSettingsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GPUImageMovieWriterDelegate>


    @property (nonatomic, strong) UIImagePickerController *cameraUI;
    @property (strong, nonatomic) IBOutlet UIButton *sessionBTN;
    @property (strong, nonatomic) IBOutlet UIImageView *gpuImageView;

    - (IBAction)connectButtonClicked:(id)sender ;
    - (IBAction)favoritesClicked:(id)sender ;
    - (IBAction)startSession:(id)sender;
    - (void) roboRoachHasChangedSettings:(BYBRoboRoach *)roboRoach;
    - (void) roboRoach: (BYBRoboRoach *)roboRoach hasMovementCommand:(BYBMovementCommand) command;
    - (void) didFinsihReadingRoboRoachValues;
    - (void) applySettings;
@end

