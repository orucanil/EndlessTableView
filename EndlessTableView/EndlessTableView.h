//
//  EndlessTableView.h
//  OmsaTech
//
//  Created by Anıl Oruç on 06/05/14.
//  Copyright (c) 2014 OmsaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EndlessTableView : UITableView

@property(nonatomic)BOOL enableEndlessScrolling;

@property(nonatomic)BOOL enableAutoScrolling;

@property(nonatomic)CGFloat autoScrollValue;

@property(nonatomic)CGFloat differenceRateValue;

@property(nonatomic,weak) EndlessTableView *attachedTableView;

@end
