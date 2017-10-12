//
//  AddressPickerTableView.h
//  Fresh
//
//  Created by Youcai on 2017/7/5.
//  Copyright © 2017年 shequcun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddressPickerTableView;
@protocol AddressPickerTableViewDelegate <NSObject>

- (void)didSelectItemAtView:(AddressPickerTableView *)view name:(NSString *)name pid:(NSString *)pid index:(NSInteger)index isleaf:(BOOL)isleaf;

@end
typedef void(^Block)(NSInteger row);
@interface AddressPickerTableView : UITableView
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, assign) NSInteger index;
@property(nonatomic, copy) Block block;
@property(nonatomic, weak)id<AddressPickerTableViewDelegate> del;
@property (nonatomic, assign) BOOL isLast;
@end
