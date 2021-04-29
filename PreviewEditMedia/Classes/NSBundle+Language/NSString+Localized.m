//
//  NSString+Localized.m
//  PreviewEditMedia
//
//  Created by Van Trieu Phu Huy on 4/29/21.
//

#import "NSString+Localized.h"
#import "NSBundle+ EditMediaLanguage.h"

@implementation NSString (Localized)


-(NSString*)localizedString {
   
    return NSLocalizedStringFromTableInBundle(self, nil, [NSBundle bundleWithIdentifier:@"org.cocoapods.PreviewEditMedia"], @"");
    //return NSLocalizedString(self, bundle: [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]], comment: "");
}


@end
