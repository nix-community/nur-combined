{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-hider";
  version = "1.6.1";

  src = pkgs.fetchFromGitHub {
    owner = "kepano";
    repo = "obsidian-hider";
    rev = version;
    sha256 = "sha256-wOq3VuIwZeBWh+oq8gUYGYWtBJc0b1uE0RjbnTcieRc=";
  };

  npmDepsHash = "sha256-4LVgsQV8ovszOfn/3lreyDPZpnlnsxAD//uPBzUkhRI=";

  postPatch =
    # bash
    ''
      cp ${./package-lock.json} package-lock.json
    '';

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json styles.css $out/
    '';

  meta = {
    description = "Hide UI elements such as tooltips, status, titlebar and more";
    homepage = "https://github.com/kepano/obsidian-hider";
    changelog = "https://github.com/kepano/obsidian-hider/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
