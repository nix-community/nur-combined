{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "cmdr";
  version = "0.7.1";

  src = pkgs.fetchFromGitHub {
    owner = "jsmorabito";
    repo = "obsidian-commander";
    rev = version;
    sha256 = "sha256-5wk+3tK8JTDvUEFyrQeh7lZjXixEj0qmcCX5RLHQq6w=";
  };

  npmDepsHash = "sha256-Gg6E6pVzKuNDXhGmq6iJ1qA9eoDSPBDPxJF6fnFUC38=";
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
