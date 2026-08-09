{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.5.8";

  src = pkgs.fetchFromGitHub {
    owner = "jsmorabito";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-hWRnA4cmeGezf9ndr+dchNc3m02wbQIf2oLpJDk0ez4=";
  };

  npmDepsHash = "sha256-Zx3sDw+KxbHutfocoK1oZmZz61S7mBJ1H/WGu5XDK+I=";
  forceGitDeps = true;
  makeCacheWritable = true;
  npmFlags = ["--legacy-peer-deps"];

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json styles.css $out/
    '';

  meta = {
    description = "Customize your workspace by adding commands everywhere, create Macros and supercharge your mobile toolbar.";
    homepage = "https://github.com/phibr0/obsidian-commander";
    changelog = "https://github.com/phibr0/obsidian-commander/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
