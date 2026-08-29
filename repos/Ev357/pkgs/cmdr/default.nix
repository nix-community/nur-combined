{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.5.10";

  src = pkgs.fetchFromGitHub {
    owner = "jsmorabito";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-Uvx/HlhLI0Rh6u1YF7TcJP4VSB9Lim3/5neTOsxFB0Q=";
  };

  npmDepsHash = "sha256-smagKtlHrHqtRb1TMLbG9XRzBM4FgxAoWsUJdEnPKfY=";
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
