
//
//  PickerCell.m
//  Fresh
//
//  Created by Youcai on 2017/7/7.
//  Copyright © 2017年 shequcun. All rights reserved.
//

#import "PickerCell.h"

@implementation PickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.textLabel.highlighted = selected;
}

@end
