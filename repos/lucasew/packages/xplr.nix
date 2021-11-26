{ pkgs, ... }:
let
  inherit (pkgs) stdenv autoPatchelfHook;
  inherit (builtins) fetchTarball;
in
stdenv.mkDerivation rec {
  name = "xplr";
  version = "0.3.13";
  src = "${fetchTarball {
    url = "https://github.com/sayanarijit/${name}/releases/download/v${version}/${name}-linux.tar.gz";
    sha256 = "sha256:04s2zdnpvyxkwnp7pw6amrr0xfgb4y8fb9sy0vbmi7lpr24n26lc";
  }}";
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    ls $src -R
    cp $src $out/bin/xplr
    chmod +x -R $out
  '';
}
