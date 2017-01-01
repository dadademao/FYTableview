//
//  FYNavigateSegementCell.h
//  NewACE
//
//  Created by fuyuan on 2016/12/30.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYNavigateSegementCell : UIView
@property (strong, nonatomic) NSString *identify;

- (instancetype)initWithIdentify:(NSString *)identify;
@end
