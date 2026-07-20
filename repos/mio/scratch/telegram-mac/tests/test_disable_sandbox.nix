with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-disable-sandbox";
  src = ./.;
  buildPhase = ''
    export HOME=$(mktemp -d)
    export CFFIXED_USER_HOME=$HOME
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    
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
    xcodebuild -resolvePackageDependencies -IDEPackageSupportDisableManifestSandbox=YES -IDEPackageSupportDisablePluginExecutionSandbox=YES || echo "FAILED XCODEBUILD"
  '';
  installPhase = "mkdir -p $out";
}
