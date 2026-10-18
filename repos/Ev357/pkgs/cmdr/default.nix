{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.7.0";

  src = pkgs.fetchFromGitHub {
    owner = "jsmorabito";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-SrD82N+6mGOzuLKVz8A6FzvgNtXiErk0vjcEA5l9Z84=";
  };

  npmDepsHash = "sha256-hjWnr2SmYKcT/ZxnO7Wn1wgiG4L1jeJFzC7rAjD2n90=";
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
