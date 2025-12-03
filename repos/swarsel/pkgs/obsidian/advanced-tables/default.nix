{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = name;
  version = "0.22.1";
  repo = "https://github.com/tgrosinger/advanced-tables-obsidian";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-vzlOEFjS9bwr+KzOa9RuyjVbIR+crmLBHO+NZXWYlCA=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-Y/5KqJ8XuEatfzmFISy/K+P1BDmR0SL/RVeJISlfYow=";
  };

  stylesCss = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-Y/5KqJ8XuEatfzmFISy/K+P1BDmR0SL/RVeJISlfYow=";
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
    description = "Improved table navigation, formatting, and manipulation in Obsidian.md";
    license = licenses.gpl3Only;
  };
}
