pkgs: final: prev:

let
  inherit (pkgs) lib;
  callPackage = pkgs.newScope final;
in
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./.;
} // {
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
