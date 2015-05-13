//
//  MJCollectionViewCalendarLayout.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJCollectionViewCalendarLayout.h"
#import "MSGridline.h"
#import "MSTimeRowHeader.h"
#import "MJTimeIndicator.h"
@implementation MJCollectionViewCalendarLayout


- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
-(void)prepareLayout
{
    [super prepareLayout];
 
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
//    attributes.transform3D = CATransform3DMakeTranslation(0, 0, attributes.indexPath.item);
    attributes.zIndex = indexPath.item;
    return attributes;
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

    layoutAttributes.frame = CGRectMake(7.0, 80.0 * indexPath.section, 30, 23.0);
    return layoutAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    if ([decorationViewKind isEqualToString:@"MSGridLine"])
    {
        layoutAttributes.frame = CGRectMake(0.0, 80.0 * indexPath.section, self.collectionViewContentSize.width, 2.0);
    }
    else
    {
        layoutAttributes.frame = CGRectMake(7.0, 80.0 * indexPath.section, 30, 23.0);

        //   layoutAttributes.version = indexPath.section;
    }

    layoutAttributes.zIndex = -1;
    return layoutAttributes;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* tempArray = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray* array = [NSMutableArray arrayWithArray:tempArray];
   // [array addObject:[self layoutAttributesForDecorationViewOfKind:@"MSGridLine" atIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]]];
    for (int i = 0; i < 48; i++)
    {
        [array addObject: [self layoutAttributesForDecorationViewOfKind:@"MSGridLine" atIndexPath:[NSIndexPath indexPathWithIndex:i]]];
        [array addObject: [self layoutAttributesForDecorationViewOfKind:@"MSTimeRowHeader" atIndexPath:[NSIndexPath indexPathWithIndex:i]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"MJTimeIndicator" atIndexPath:[NSIndexPath indexPathWithIndex:i]]];
    }
  
    CGRect visibleRect;
    
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    return array;

    
    
}




- (void)initialize
{
    [self registerClass:[MSGridline class] forDecorationViewOfKind:@"MSGridLine"];
}

@end
