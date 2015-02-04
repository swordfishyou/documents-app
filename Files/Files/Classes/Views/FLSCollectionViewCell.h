//
//  FLSCollectionViewCell.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@class FLSDocument;

@interface FLSCollectionViewCell : UICollectionViewCell
@property (nonatomic, readonly) FLSDocument *document;
- (void)configureWithDocument:(FLSDocument *)document dateFormatter:(NSDateFormatter *)dateFormatter;
@end
