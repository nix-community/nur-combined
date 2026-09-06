{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.5.11";

  src = pkgs.fetchFromGitHub {
    owner = "jsmorabito";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-rZ+oZETflSnSRWvsKy/9jL72qiAh37UGtUHIaxXkWiM=";
  };

  npmDepsHash = "sha256-OGvq0B1LwrNeug+a1fon7L1xt6r511Ic86/0/+LcG80=";
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
