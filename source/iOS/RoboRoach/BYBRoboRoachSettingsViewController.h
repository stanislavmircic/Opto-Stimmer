//
//  BYBRoboRoachSettingsViewController.h
//  RoboRoach
//
//  Created by Greg Gage on 4/17/13.
//  Copyright (c) 2013 Backyard Brains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SensibleTableView/SCTableViewModel.h>
#import "BYBRoboRoachManager.h"
@protocol BYBSettingsDelegate;


@interface BYBRoboRoachSettingsViewController : UIViewController <SCTableViewModelDelegate>{
    SCTableViewModel *tableViewModel;
    IBOutlet UITableView *tableView;
    __weak IBOutlet UIImageView *stimImage;
}

@property (strong, nonatomic) BYBRoboRoach * roboRoach;
- (IBAction)applyBtnClick:(id)sender;

@property (nonatomic, assign) id <BYBSettingsDelegate> masterDelegate;

@end




@protocol BYBSettingsDelegate <NSObject>
- (void) applySettings;

@end

