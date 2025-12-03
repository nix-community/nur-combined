{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "0.7.0";
  repo = "https://github.com/Vinzent03/obsidian-sort-and-permute-lines";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-iNz7HSgpWYhbHUslwaP7woTNI67+EqHB8KHQpKTpoM4=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-DHJDVMAbzbHsEoyW9cVRICCdT8N12HTRjucEyoqZaNM=";
  };

  stylesCss = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-DHJDVMAbzbHsEoyW9cVRICCdT8N12HTRjucEyoqZaNM=";
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
    description = "Sort and Permute lines in whole file or selection. ";
    license = licenses.unfree;
  };
}
