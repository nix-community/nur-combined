with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-toolchain";
  src = ./.;
  buildPhase = ''
    export HOME=$(mktemp -d)
    export CFFIXED_USER_HOME=$HOME
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    
    mkdir -p my.xctoolchain/usr/bin
    mkdir -p my.xctoolchain/usr/lib
    for f in /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/*; do
      ln -s "$f" my.xctoolchain/usr/bin/$(basename "$f")
    done
    rm my.xctoolchain/usr/bin/swift-package
    sed 's|/usr/bin/sandbox-exec|/tmp/bin/sandbox-exec|g' /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package > my.xctoolchain/usr/bin/swift-package
    chmod +x my.xctoolchain/usr/bin/swift-package
    
    for f in /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/*; do
      ln -s "$f" my.xctoolchain/usr/lib/$(basename "$f")
    done
    
    # Toolchain needs Info.plist
    cat > my.xctoolchain/Info.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.fake.toolchain</string>
</dict>
</plist>
PLIST
    
    export TOOLCHAINS=com.fake.toolchain
    
    mkdir -p /tmp/bin
    cat > /tmp/bin/sandbox-exec <<'SH'
#!/bin/sh
while [ $# -gt 0 ]; do
  case "$1" in
    -f|-p|-n) shift 2 ;;
    -*) shift 1 ;;
    *) break ;;
  esac
done
exec "$@"
SH
    chmod +x /tmp/bin/sandbox-exec
    
    mkdir -p dummy-project
    cd dummy-project
    cat > Package.swift <<'PKG'
// swift-tools-version:5.5
import PackageDescription
let package = Package(
    name: "Dummy",
    dependencies: [
        .package(url: "https://github.com/google/promises.git", from: "2.1.1")
    ]
)
PKG
    xcodebuild -resolvePackageDependencies -toolchain $PWD/../my.xctoolchain || echo "FAILED XCODEBUILD"
  '';
  installPhase = "mkdir -p $out";
}
