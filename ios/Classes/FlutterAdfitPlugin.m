#import "FlutterAdfitPlugin.h"
#if __has_include(<flutter_adfit/flutter_adfit-Swift.h>)
#import <flutter_adfit/flutter_adfit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_adfit-Swift.h"
#endif

@implementation FlutterAdfitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAdfitPlugin registerWithRegistrar:registrar];
}
@end
