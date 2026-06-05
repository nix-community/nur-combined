{ config, pkgs, ... }:
{
  sane.programs.nixpkgs-review = {
    packageUnwrapped = (pkgs.nixpkgs-review.override {
      nix = config.sane.programs.nix.package;
    }).overrideAttrs (upstream: {
      makeWrapperArgs = upstream.makeWrapperArgs ++ [
        # fixes `error: path '/home/colin/.cache/nixpkgs-review' is a symlink`.
        # only required if ~/.cache/nixpkgs-review is persisted
        "--run" ''export NIXPKGS_REVIEW_CACHE_DIR=$(realpath "''${NIXPKGS_REVIEW_CACHE_HOME:-$XDG_CACHE_HOME/nixpkgs-review}")''
        "--run" ''export GITHUB_TOKEN=''${GITHUB_TOKEN:-$(cat "$XDG_CONFIG_HOME/nixpkgs-review/github_token")}''
        # "--set XDG_CACHE_HOME ${config.sane.fs."/home/colin/.cache/nixpkgs-review".symlink.target}"  #< possible alternative to NIXPKGS_REVIEW_CACHE_DIR
      ];
    });

    secrets.".config/nixpkgs-review/github_token" = ../../../../secrets/common/github_token.bin;

    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      ".config/git"  #< it needs to know commiter name/email, even if not posting
    ];
    sandbox.extraPaths = [
      "/nix/var"
    ];
    persist.byStore.ephemeral = [
      ".cache/nixpkgs-review"  #< help it not exhaust / tmpfs
    ];
  };
}
