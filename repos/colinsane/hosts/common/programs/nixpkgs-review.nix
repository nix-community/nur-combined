{ config, lib, pkgs, ... }:
{
  sane.programs.nixpkgs-review = {
    packageUnwrapped = pkgs.nixpkgs-review.overrideAttrs (upstream: {
      makeWrapperArgs = upstream.makeWrapperArgs ++ lib.optionals ((config.sane.fs."/home/colin/.cache/nixpkgs-review" or {}) != {}) [
        # fixes `error: path '/home/colin/.cache/nixpkgs-review' is a symlink`
        "--set NIXPKGS_REVIEW_CACHE_DIR ${config.sane.fs."/home/colin/.cache/nixpkgs-review".symlink.target}"
        # "--set XDG_CACHE_DIR ${config.sane.fs."/home/colin/.cache/nixpkgs-review".symlink.target}"  #< nixpkgs-review is ignoring this?
      ];
    });

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
