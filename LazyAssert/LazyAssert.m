//
//  LazyAssert.m
//  LazyAssert
//
//  Created by Roman Gayu on 03/04/15.
//
//

#import "LazyAssert.h"
#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"

static LazyAssert *sharedPlugin;

@interface LazyAssert()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation LazyAssert

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        self.bundle = plugin;
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Insert Lazy Assertion" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            
            [actionMenuItem setKeyEquivalent:@"a"];
            [actionMenuItem setKeyEquivalentModifierMask:NSControlKeyMask | NSCommandKeyMask | NSAlternateKeyMask];
            
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}

-(NSUInteger)locationOfStartTokenCursorLocation:(NSUInteger)location inString:(NSString*)string
{
    NSUInteger result = location;
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    while (location--)
    {
        char character = cString[location];
        if (isspace(character))
        {
            break;
        }
        result = location;
    }
    return result;
}

- (void)doMenuAction
{
    DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
    NSRange selectedTextRange = [sourceTextView selectedRange];
    NSString *selectedString = [sourceTextView.textStorage.string substringWithRange:selectedTextRange];
    if (selectedString) {
        NSUInteger startOfToken = [self locationOfStartTokenCursorLocation:selectedTextRange.location inString:sourceTextView.textStorage.string];
        NSString *prefixString = @"NSAssert(";
        NSString *suffixString = [NSString stringWithFormat:@", @\"%@\");", [[NSUUID UUID] UUIDString]];

        NSRange prefixRange = NSMakeRange(startOfToken, 0);
        NSRange suffixRange = NSMakeRange(NSMaxRange(selectedTextRange)+prefixString.length, 0);

        [sourceTextView insertText:prefixString replacementRange:prefixRange];
        [sourceTextView insertText:suffixString replacementRange:suffixRange];

        [sourceTextView setSelectedRange:NSMakeRange(selectedTextRange.location + prefixString.length, selectedTextRange.length)];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
