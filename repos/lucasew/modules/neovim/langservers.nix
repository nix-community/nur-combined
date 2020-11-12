{pkgs, ...}:
let
  pkgbin = name: import <dotfiles/lib/pkgbin.nix> {
    pkgs = pkgs;
    name = name;
  };
in
{
  go = ["gopls"];
  rust = ["rls"];
  python = ["python-language-server"];
  nix = [(pkgbin "rnix-lsp")];
  c = [(pkgbin "ccls")];
  cpp = [(pkgbin "ccls")];
  zig = ["zls"];
}
