with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-lndir2";
  src = ./.;
  nativeBuildInputs = [ lndir ];
  buildPhase = ''
    export HOME=$(mktemp -d)
    export CFFIXED_USER_HOME=$HOME
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    
    mkdir -p FakeXcode.app
    lndir /Applications/Xcode.app FakeXcode.app
    
    rm FakeXcode.app/Contents/Developer/usr/bin/xcodebuild
    cp /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild FakeXcode.app/Contents/Developer/usr/bin/xcodebuild
    
    rm FakeXcode.app/Contents/MacOS/Xcode
    cp /Applications/Xcode.app/Contents/MacOS/Xcode FakeXcode.app/Contents/MacOS/Xcode
    
    rm FakeXcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    cp /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package FakeXcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    chmod +w FakeXcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    
    sed -i 's|/usr/bin/sandbox-exec|/tmp/bin/sandbox-exec|g' FakeXcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    
    export DEVELOPER_DIR=$PWD/FakeXcode.app/Contents/Developer
    
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
    $DEVELOPER_DIR/usr/bin/xcodebuild -resolvePackageDependencies || echo "FAILED XCODEBUILD"
  '';
  installPhase = "mkdir -p $out";
}
