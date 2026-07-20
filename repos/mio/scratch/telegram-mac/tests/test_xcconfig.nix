with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-xcconfig";
  src = ./.;
  buildPhase = ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    cat > build.xcconfig <<XC
IDEPackageSupportDisableManifestSandbox = YES
IDEPackageSupportDisablePluginExecutionSandbox = YES
XC
    xcodebuild -xcconfig build.xcconfig -showBuildSettings | grep IDEPackageSupportDisableManifestSandbox || echo "NOT FOUND IN SETTINGS"
  '';
  installPhase = "mkdir -p $out";
}
