{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-hider";
  version = "1.5.1";

  src = pkgs.fetchFromGitHub {
    owner = "kepano";
    repo = "obsidian-hider";
    rev = version;
    sha256 = "sha256-VpBH0MkNmjaNc04hyecmO8e9meVhlrOhBQaX8mcvd3M=";
  };

  npmDepsHash = "sha256-8PCGvttYFOvJL8MOaRvBbVpqVjdjsnxIWYFeJTTGYQM=";

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
