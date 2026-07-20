with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-userdefault";
  src = ./.;
  buildPhase = ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
    xcodebuild -userdefault IDEPackageSupportDisableManifestSandbox=YES -showBuildSettings | grep IDE || echo "OK"
  '';
  installPhase = "mkdir -p $out";
}
