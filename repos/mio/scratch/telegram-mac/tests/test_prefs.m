#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"IDEPackageSupportDisableManifestSandbox"];
        NSLog(@"val = %d", val);
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.dt.xcodebuild"];
        NSLog(@"dict = %@", dict);
    }
    return 0;
}
