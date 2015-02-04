//
//  FLSDocument.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSDocument.h"

@implementation FLSDocument
- (instancetype)initWithTitle:(NSString *)title creationDate:(NSDate *)date preview:(UIImage *)preview {
    if (self = [super init]) {
        _title = [title copy];
        _creationDate = [date copy];
        _previewImage = [preview copy];
    }
    
    return self;
}
@end
