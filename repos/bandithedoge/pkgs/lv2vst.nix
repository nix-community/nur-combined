{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.lv2vst) src pname version;
  makeFlags = ["PREFIX=$(out)"];
}
