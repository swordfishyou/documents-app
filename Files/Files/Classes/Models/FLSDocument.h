//
//  FLSDocument.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit.UIImage;

@interface FLSDocument : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) UIImage *previewImage;

- (instancetype)initWithTitle:(NSString *)title
                 creationDate:(NSDate *)date
                      preview:(UIImage *)preview;
@end
