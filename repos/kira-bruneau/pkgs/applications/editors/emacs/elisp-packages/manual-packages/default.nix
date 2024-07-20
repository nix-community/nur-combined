pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  acm = callPackage ./acm { };

  acm-terminal = callPackage ./acm-terminal { };

  lsp-bridge = callPackage ./lsp-bridge {
    inherit (pkgs)
      basedpyright
      git
      go
      gopls
      python3
      ;
  };
}
