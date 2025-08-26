{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.5.4";

  src = pkgs.fetchFromGitHub {
    owner = "phibr0";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-ROC21Rytve+FAy24lN+w697sAFvamUVIe6Uf+wo6yuI=";
  };

  npmDepsHash = "sha256-Gr3PzgSY4Tae6PWMvCsLtzcQu9SO8UUy2rU+8tWQbOs=";

  postPatch =
    # bash
    ''
      cp ${./package.json} package.json
      cp ${./package-lock.json} package-lock.json
    '';

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
