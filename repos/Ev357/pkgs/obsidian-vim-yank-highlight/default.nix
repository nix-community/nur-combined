{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-vim-yank-highlight";
  version = "1.0.8";

  src = pkgs.fetchFromGitHub {
    owner = "aleksey-rowan";
    repo = "obsidian-vim-yank-highlight";
    rev = version;
    sha256 = "sha256-Z10vHpVFntbT7lg6oA9YnxnIBIN0AG6ez/lgso06EhQ=";
  };

  npmDepsHash = "sha256-qFfX55HWRkLlJyKbbWwB1sV253YxblnR/1BORT22sns=";

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json styles.css $out/
    '';

  meta = {
    description = "Highlight yanked text in Vim mode. Enjoy that subtle animation you've missed so much.";
    homepage = "https://github.com/aleksey-rowan/obsidian-vim-yank-highlight";
    changelog = "https://github.com/aleksey-rowan/obsidian-vim-yank-highlight/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
