{
  fetchurl,
  fetchFromGitHub,
  dockerTools,
  fetchgit,
  stdenv,
  lib,
}:
let
  sources = import ../../_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
in
stdenv.mkDerivation rec {
  inherit (sources.lxgw-neo-xihei) pname version src;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp $src $out/share/fonts/truetype/LXGWNeoXiHei.ttf
  '';
  meta = with lib; {
    homepage = "https://github.com/welai/glow-sans";
    description = ''
      SHSans-derived CJK font family with a more concise & modern look
    '';
    license = with licenses; [
      mit
      ofl
    ];
    platforms = platforms.all;
  };
}
