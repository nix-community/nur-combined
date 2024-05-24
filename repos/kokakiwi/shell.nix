let
  pkgs = import <nixpkgs> {
    overlays = [
      (self: super: let
        nurPkgs = import ./default.nix { pkgs = super; };
      in nurPkgs // {
        nur = nurPkgs;
        lib = super.lib // nurPkgs.lib;
      })
    ];
  };
  inherit (pkgs) lib;

  updateChecker = lib.mkUpdateChecker {
    packages = lib.filterAttrs (name: drv: lib.isDerivation drv) pkgs.nur;
    sources = {
      freenginx = {
        source = "mercurial";
        mercurial = "http://freenginx.org/hg/nginx";
        prefix = "release-";
      };
    };
  };
in pkgs.mkShell {
  packages = with pkgs; [
    arion
  ];

  shellHook = ''
    checkUpdates() {
      ${updateChecker} -k ~/.config/nvchecker/keyfile.toml
    }
  '';
}
