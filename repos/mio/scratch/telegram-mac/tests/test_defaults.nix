with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-defaults";
  src = ./.;
  buildPhase = ''
    defaults read com.apple.dt.xcodebuild || echo "FAILED"
  '';
  installPhase = "mkdir -p $out";
}
