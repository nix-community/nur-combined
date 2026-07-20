with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-global-prefs";
  src = ./.;
  buildPhase = ''
    export HOME=$(mktemp -d)
    export CFFIXED_USER_HOME=$HOME
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    mkdir -p $HOME/Library/Preferences
    cat > $HOME/Library/Preferences/.GlobalPreferences.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>IDEPackageSupportDisableManifestSandbox</key>
    <true/>
</dict>
</plist>
PLIST
    
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
