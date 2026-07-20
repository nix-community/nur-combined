with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-devdir";
  src = ./.;
  buildPhase = ''
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    mkdir -p fake-dev
    cd fake-dev
    for f in /Applications/Xcode.app/Contents/Developer/*; do
      ln -s "$f" $(basename "$f")
    done
    rm Toolchains
    mkdir -p Toolchains/XcodeDefault.xctoolchain/usr/bin
    for f in /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/*; do
      ln -s "$f" Toolchains/XcodeDefault.xctoolchain/usr/bin/$(basename "$f")
    done
    rm Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    sed 's|/usr/bin/sandbox-exec|/tmp/bin/sandbox-exec|g' /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package > Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    chmod +x Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
    
    ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib Toolchains/XcodeDefault.xctoolchain/usr/lib
    
    export DEVELOPER_DIR=$PWD
    
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
    
    cd ..
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
    xcodebuild -resolvePackageDependencies || echo "FAILED XCODEBUILD"
  '';
  installPhase = "mkdir -p $out";
}
