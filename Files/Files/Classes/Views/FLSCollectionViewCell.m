//
//  FLSCollectionViewCell.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSCollectionViewCell.h"
#import "FLSDocument.h"

@interface FLSCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsTextLabel;
@end

@implementation FLSCollectionViewCell
- (void)configureWithDocument:(FLSDocument *)document dateFormatter:(NSDateFormatter *)dateFormatter{
    _document = document;
    
    self.imageView.image = self.document.previewImage;
    self.textLabel.text = self.document.title;
    self.detailsTextLabel.text = [dateFormatter stringFromDate:self.document.creationDate];
}
@end
