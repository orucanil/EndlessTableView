//
//  EndlessTableViewCell.m
//  EndlessTableViewDemo
//
//  Created by Anil Oruc on 4/4/16.
//  Copyright © 2016 Anil Oruc. All rights reserved.
//

#import "EndlessTableViewCell.h"

@interface EndlessTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation EndlessTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    
    _view.backgroundColor = bgColor;
}

@end
