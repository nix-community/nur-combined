{pkgs, ...}:
let
  pkgbin = name: "${pkgs."${name}"}/bin/${name}";
in
{
  go = ["gopls"]; # gopls
  rust = ["rls"]; # rls
  python = ["python-language-server"]; # python3Packages.python-language-server
  nix = [(pkgbin "rnix-lsp")];
  c = [(pkgbin "ccls")];
  cpp = [(pkgbin "ccls")];
  typescript = ["${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server" "--stdio"];
  typescriptreact = ["${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server" "--stdio"];
  zig = ["zls"]; # from a external overlay
  dart = ["${pkgs.dart}/bin/dart" "${pkgs.dart}/bin/snapshots/analysis_server.dart.snapshot" "--lsp"];
  sh = ["bash-language-server" "start"]; # nodePackages.bash-language-server
  lua = ["lua-lsp"];
}
