{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "0.3.5";
  repo = "https://github.com/dragonwocky/obsidian-tray";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-BHGlkLij4wgpP10upwgFN3rBVmBTcoVl1j6ktVCUrUI=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-gOjuAtf7mcgrlH162TrC37BmP0hQthSMfeOAN+/kSjQ=";
  };

  stylesCss = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-gOjuAtf7mcgrlH162TrC37BmP0hQthSMfeOAN+/kSjQ=";
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
    description = "Run Obsidian from the system tray for customisable window management & global quick notes";
    license = licenses.mit;
  };
}
