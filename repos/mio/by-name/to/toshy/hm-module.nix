# by-name/to/toshy/hm-module.nix
#
# Home Manager module for Toshy.
#
# Places the Toshy externally-managed-runtime link at:
#     ~/.local/state/toshy/runtime
# pointing at the wrapped Python environment package. Toshy's launcher
# scripts resolve the runtime through this link (via toshy-runtime-env.sh),
# and "setup_toshy.py install-user-files" refuses to run without it.
#
# The link is part of the home-manager generation, which also protects the
# runtime package from Nix garbage collection, and updates the link target
# on every generation switch (including rollbacks).
#
# NOTE: The launcher scripts honor XDG_STATE_HOME when resolving this link,
# but this module currently places it at the default location. If you set a
# non-default XDG_STATE_HOME, adjust accordingly.

{ config, lib, pkgs, ... }:

let
  cfg = config.services.toshy;
in
{
  options.services.toshy = {
    enable = lib.mkEnableOption "the Toshy externally managed Python runtime link";

    package = lib.mkPackageOption pkgs "toshy" { };
  };

  config = lib.mkIf cfg.enable {
    home.file.".local/state/toshy/runtime".source = cfg.package;
  };
}
