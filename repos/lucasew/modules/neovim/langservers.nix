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
  typescript = ["${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server" "--stdio"];
  typescriptreact = ["${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server" "--stdio"];
  zig = ["zls"];
}
