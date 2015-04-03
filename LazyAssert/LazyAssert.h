//
//  LazyAssert.h
//  LazyAssert
//
//  Created by Roman Gayu on 03/04/15.
//
//

#import <AppKit/AppKit.h>

@interface LazyAssert : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end