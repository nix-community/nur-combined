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
      iocaine = {
        source = "gitea";
        host = "git.madhouse-project.org";
        gitea = "iocaine/iocaine";
        use_max_tag = true;
        prefix = "iocaine-";
      };
      tumelune = {
        source = "gitlab";
        host = "git.argent.systems";
        gitlab = "alice/tumelune";
        use_max_tag = true;
        prefix = "v";
        include_regex = "v[0-9]+\.[0-9]+\.[0-9]+";
      };
    };
    overrides = {
      aura.exclude_regex = "^$";
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
