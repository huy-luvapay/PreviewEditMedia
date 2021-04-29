//
//  NSBundle+EditMediaLanguage.m
//



#import "NSBundle+ EditMediaLanguage.h"
#import <objc/runtime.h>

static const char associatedLanguageBundle = 1;

NSString * const bundleIdentifier = @"org.cocoapods.PreviewEditMedia";

@interface PrivateBundleEditMedia : NSBundle
@end

@implementation PrivateBundleEditMedia
- (NSString*)localizedStringForKey:(NSString *)key
                            value:(NSString *)value
                            table:(NSString *)tableName
{
    NSBundle* bundle=objc_getAssociatedObject(self, &associatedLanguageBundle);
    return bundle ? [bundle localizedStringForKey:key
                                            value:value
                                            table:tableName] : [super localizedStringForKey:key
                                                                                      value:value
                                                                                      table:tableName];
}
@end

@implementation NSBundle (EditMediaLanguage)
+(void)setEditMediaLanguage:(NSString*)language
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle bundleWithIdentifier:bundleIdentifier],[PrivateBundleEditMedia class]);
    });
    objc_setAssociatedObject([NSBundle bundleWithIdentifier:bundleIdentifier], &associatedLanguageBundle, language ?
                             [NSBundle bundleWithPath:[[NSBundle bundleWithIdentifier:bundleIdentifier] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
