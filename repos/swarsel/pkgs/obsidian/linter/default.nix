{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "1.30.0";
  repo = "https://github.com/platers/obsidian-linter";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-hgOaz484q7nlMHNFwGOVHMJ0IHJGksyaXf9sYqaJ5EI=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-yeimJ+SlCIQpgUWsqVEEED/ItJYw86XFlKzeq10b134=";
  };

  stylesCss = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-yeimJ+SlCIQpgUWsqVEEED/ItJYw86XFlKzeq10b134=";
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
    description = "An Obsidian plugin that formats and styles your notes with a focus on configurability and extensibility.";
    license = licenses.mit;
  };
}
