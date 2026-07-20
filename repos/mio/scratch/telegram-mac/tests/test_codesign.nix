with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-codesign";
  src = ./.;
  nativeBuildInputs = [ darwin.cctools ]; # for codesign
  buildPhase = ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    cp /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild ./my-xcodebuild
    codesign --remove-signature ./my-xcodebuild
    ./my-xcodebuild -version || echo "FAILED"
  '';
  installPhase = "mkdir -p $out";
}
