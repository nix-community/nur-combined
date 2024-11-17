{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.bunpen;
in
{
  sane.programs.bunpen = {
    packageUnwrapped = pkgs.bunpen.overrideAttrs (base: {
      # create a directory which holds just the `bunpen` so that we
      # can add bunpen as a dependency to binaries via `PATH=/run/current-system/libexec/bunpen` without forcing rebuild every time bunpen changes
      postInstall = ''
        mkdir -p $out/libexec/bunpen
        ln -s $out/bin/bunpen $out/libexec/bunpen/bunpen
      '';
    });
    sandbox.enable = false;
    sandbox.method = null;  #< TODO: avoids infinite recursion in the sane.programs system
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [ "/libexec/bunpen" ];
}
