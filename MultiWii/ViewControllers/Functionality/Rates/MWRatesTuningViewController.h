//
//  MWAuxSelectViewController.h
//  MultiWii
//
//  Created by Eugene Skrebnev on 7/11/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import "MWBaseViewController.h"

@interface MWRatesTuningViewController : MWBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
