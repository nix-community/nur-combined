{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "0.6.4";
  repo = "https://github.com/pjeby/tag-wrangler";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-lK1y6kXmBinXpihob4z3lWp62WP0PTnyAauAFtLuZKI=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-TljciSQAmyuYOWkv4ljQh1hRLspqtUwXT4Aix+2nGbs=";
  };

  stylesCss = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-TljciSQAmyuYOWkv4ljQh1hRLspqtUwXT4Aix+2nGbs=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp $mainJs $out/main.js
    cp $manifest $out/manifest.json
    cp $stylesCss $out/styles.css
  '';

  meta = with lib; {
    homepage = repo;
    changelog = "${repo}/releases/tag/${version}";
    description = "An Obsidian plugin to provide an editor for Markdown tables. It can open CSV data and data from Microsoft Excel, Google Sheets, Apple Numbers and LibreOffice Calc as Markdown tables from Obsidian Markdown editor. ";
    license = licenses.isc;
  };
}
