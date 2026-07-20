set -x
pwd
cat > hook.m <<EOF
#import <Foundation/Foundation.h>
EOF
clang -dynamiclib -o libhook.dylib hook.m -framework Foundation
