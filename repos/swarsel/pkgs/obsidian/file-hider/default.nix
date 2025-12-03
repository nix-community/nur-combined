{ name, lib, pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "1.1.1";
  repo = "https://github.com/Eldritch-Oliver/file-hider";

  mainJs = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/main.js";
    sha256 = "sha256-jUWgKcTw9wfJ/BgSmxhUFXhTD2BvxF/mk6u5fxHkFfc=";
  };

  manifest = pkgs.fetchurl {
    url = "${repo}/releases/download/${version}/manifest.json";
    sha256 = "sha256-5DiPhQrnNCRYJfzo+TPG512EFMg9Z/l/GACPXgZ6BQo=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp $mainJs $out/main.js
    cp $manifest $out/manifest.json
  '';

  meta = with lib; {
    homepage = repo;
    changelog = "${repo}/releases/tag/${version}";
    description = "A plugin for https://obsidian.md that allows hiding specific files and folders from the file explorer. ";
    license = licenses.mit;
  };
}
