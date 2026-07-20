    runHook preBuild

    # Copy FFmpeg source
    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1
    cp -r /nix/store/d08r55plxwx0npmcg5qplybczhad8v0z-source/* submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1/

    # Allow scripts to find xcrun and xcodebuild on the host
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    
    # CoreFoundation uses the user database for home dir, override it:
    export CFFIXED_USER_HOME=$HOME

    # Telegram for macOS requires framework configuration first
    sed -i 's/no/yes/g' scripts/rebuild || true

    # Fix CMake 3.5 compatibility for Mozjpeg
    sed -i 's/cmake_minimum_required(VERSION .*/cmake_minimum_required(VERSION 3.5)/g' submodules/telegram-ios/third-party/mozjpeg/mozjpeg/CMakeLists.txt || true

    # Fix libwebp ZIP extraction (Nix GNU tar does not support ZIP, use unzip)
    sed -i 's/tar -xzf "$SOURCE_ARCHIVE" --directory "$OUT_DIR"/unzip -q "$SOURCE_ARCHIVE" -d "$OUT_DIR"/g' core-xprojects/libwebp/libwebp/build*.sh || true

    # Fix webrtc build script to correctly copy source directory contents (avoids missing CMakeLists.txt)
    sed -i 's/cp -R \$SOURCE_DIR \$BUILD_DIR/cp -R "$SOURCE_DIR"\/. "$BUILD_DIR"\//g' core-xprojects/webrtc/webrtc/build.sh || true

    # Fix Mozjpeg build script for GNU cp
    sed -i 's/mozjpeg\/" "${BUILD_DIR}build\/"/mozjpeg\/"\/. "${BUILD_DIR}build\/"/g' core-xprojects/Mozjpeg/Mozjpeg/build.sh || true

    # Fix webrtc libopus include path
    sed -i 's/libopus\/build\/libopus\/include\/opus/libopus\/build\/libopus\/include\/opus\/include/g' core-xprojects/webrtc/webrtc.xcodeproj/project.pbxproj || true

    # Fix the custom pkg-config wrapper to parse custom paths properly when ffmpeg prepends them
    cat > submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config <<'EOF'
    #!/bin/sh
    LIBOPUS_PATH=""
    LIBVPX_PATH=""
    LIBDAV1D_PATH=""
    CMD=""
    NAME=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --libopus_path) LIBOPUS_PATH="$2"; shift 2 ;;
            --libvpx_path) LIBVPX_PATH="$2"; shift 2 ;;
            --libdav1d_path) LIBDAV1D_PATH="$2"; shift 2 ;;
            --version|--exists|--cflags|--libs) CMD="$1"; shift 1 ;;
            --print-errors) shift 1 ;;
            zlib*|opus*|vpx*|dav1d*) NAME="$1"; shift 1 ;;
            *) shift 1 ;;
        esac
    done

    if [ "$CMD" == "--version" ]; then
        echo "0.29.2"
        exit 0
    elif [ "$CMD" == "--exists" ]; then
        case "$NAME" in
            zlib*|opus*|vpx*|dav1d*) exit 0 ;;
            *) exit 1 ;;
        esac
    elif [ "$CMD" == "--cflags" ]; then
        case "$NAME" in
            zlib*) echo "" ;;
            opus*) echo "-I$LIBOPUS_PATH/include/opus/include -I$LIBOPUS_PATH/include/opus" ;;
            vpx*) echo "-I$LIBVPX_PATH/include" ;;
            dav1d*) echo "-I$LIBDAV1D_PATH/include" ;;
            *) exit 1 ;;
        esac
        exit 0
    elif [ "$CMD" == "--libs" ]; then
        case "$NAME" in
            zlib*) echo "-lz" ;;
            opus*) echo "-L$LIBOPUS_PATH/lib -lopus" ;;
            vpx*) echo "-L$LIBVPX_PATH/lib -lVPX" ;;
            dav1d*) echo "-L$LIBDAV1D_PATH/lib -ldav1d" ;;
            *) exit 1 ;;
        esac
        exit 0
    else
        exit 1
    fi
    EOF
    chmod +x submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config

    # Run the setup script
    sh scripts/configure_frameworks.sh

    set -x
    pwd

    # Create a fake sandbox-exec script
    cat > $PWD/fake-sandbox-exec <<'EOF'
    #!/bin/sh
    while [ $# -gt 0 ]; do
      case "$1" in
        -f|-p|-n) shift 2 ;;
        -*) shift 1 ;;
        *) break ;;
      esac
    done
    exec "$@"
EOF
    chmod +x $PWD/fake-sandbox-exec

    # Hook posix_spawn to redirect /usr/bin/sandbox-exec to our fake script,
    # and hook NSUserDefaults to disable out-of-process build services (XPC).
    cat > hook.m <<'EOF'
    #import <Foundation/Foundation.h>
    #import <objc/runtime.h>
    #include <spawn.h>
    #include <string.h>

    #define DYLD_INTERPOSE(_replacement,_replacee) \
       __attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
                __attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

    int my_posix_spawn(pid_t *pid, const char *path, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
        if (path && strcmp(path, "/usr/bin/sandbox-exec") == 0) {
            return posix_spawn(pid, FAKE_SANDBOX, file_actions, attrp, argv, envp);
        }
        return posix_spawn(pid, path, file_actions, attrp, argv, envp);
    }
    DYLD_INTERPOSE(my_posix_spawn, posix_spawn)

    int my_posix_spawnp(pid_t *pid, const char *file, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
        if (file && strcmp(file, "/usr/bin/sandbox-exec") == 0) {
            return posix_spawnp(pid, FAKE_SANDBOX, file_actions, attrp, argv, envp);
        }
        return posix_spawnp(pid, file, file_actions, attrp, argv, envp);
    }
    DYLD_INTERPOSE(my_posix_spawnp, posix_spawnp)

    @implementation NSUserDefaults (Hook)
    + (void)load {
        Method original = class_getInstanceMethod(self, @selector(boolForKey:));
        Method swizzled = class_getInstanceMethod(self, @selector(my_boolForKey:));
        method_exchangeImplementations(original, swizzled);
    }
    - (BOOL)my_boolForKey:(NSString *)defaultName {
        if ([defaultName isEqualToString:@"IDEPackageSupportDisableManifestSandbox"] ||
            [defaultName isEqualToString:@"IDEPackageSupportDisablePluginExecutionSandbox"]) {
            return YES;
        }
        if ([defaultName isEqualToString:@"EnableBuildService"]) {
            return NO;
        }
        return [self my_boolForKey:defaultName];
    }
    @end
EOF
    clang -dynamiclib -DFAKE_SANDBOX="\"$PWD/fake-sandbox-exec\"" -o libhook.dylib hook.m -framework Foundation
    export DYLD_INSERT_LIBRARIES=$PWD/libhook.dylib

    # Build the app using xcodebuild
    xcodebuild -workspace Telegram-Mac.xcworkspace \
               -scheme Telegram \
               -configuration Release \
               -derivedDataPath build \
               -clonedSourcePackagesDirPath build/swiftpm \
               CODE_SIGN_IDENTITY="" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO

    runHook postBuild
