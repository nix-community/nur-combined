{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "catppuccin-obsidian";
  version = "2.0.4";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "obsidian";
    rev = "v${version}";
    sha256 = "sha256-fbPkZXlk+TTcVwSrt6ljpmvRL+hxB74NIEygl4ICm2U=";
  };

  npmDepsHash = "sha256-4revqvwwk9v1AVzn4lfhbJjQHg79ix/PYTFnEQVPf1g=";

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp manifest.json $out/
      cp dist/catppuccin.css $out/theme.css
    '';

  meta = {
    description = "Catppuccin for Obsidian";
    homepage = "https://github.com/catppuccin/obsidian";
    changelog = "https://github.com/catppuccin/obsidian/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
