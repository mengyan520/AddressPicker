//
//  AddressPickerView.h
//  Fresh
//
//  Created by Youcai on 2017/7/5.
//  Copyright © 2017年 shequcun. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^PickerBlk)(NSString *name,NSArray *rpath);
@interface AddressPickerView : UIView
+ (instancetype)instance;
- (void)showInView:(UIView *)view rpath:(NSArray *)rpath level:(NSInteger)level blk:(PickerBlk)blk;

@end
