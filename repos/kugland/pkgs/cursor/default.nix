{ pkgs ? import <nixpkgs> { } }:

let
  sources = {
    x86_64 = {
      url = "https://downloads.cursor.com/production/53b99ce608cba35127ae3a050c1738a959750865/linux/x64/Cursor-1.0.0-x86_64.AppImage";
      hash = "sha256-HJiT3aDB66K2slcGJDC21+WhK/kv4KCKVZgupbfmLG0=";
    };
    aarch64 = {
      url = "https://downloads.cursor.com/production/53b99ce608cba35127ae3a050c1738a959750865/linux/arm64/Cursor-1.0.0-aarch64.AppImage";
      hash = "sha256-/F+OUD+sjnIt2ishusi7F/W1kK/n7hwL7Bz1cO3u+x4=";
    };
  };

in
pkgs.appimageTools.wrapType2 {
  pname = "cursor";
  version = "1.0.0";
  src = pkgs.fetchurl
    (if pkgs.stdenv.isx86_64 then
      sources.x86_64
    else if pkgs.stdenv.isAarch64 then
      sources.aarch64
    else
      throw "Unsupported architecture for Cursor editor");
}
