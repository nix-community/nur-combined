{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.apeloader;
  apeElfLoader = ./ape.elf;
in
# NOTE: Currently, if you activate the loader in your config and then disable
# it, it will continue to be the loader until the next reboot, despite the
# relevant binfmt files in /proc disappearing.
{
  options.programs.apeloader = {
    enable = mkEnableOption "APE helper/loader";
    mode = mkOption {
      type = types.str;
      default = "loader";
      description = ''
        If "loader" (default), use the APE loader to speed up execution of APE
        binaries. If "workaround", use a simple redirect to a Bourne shell to
        help resolve some execution issues.
      '';
    };
  };
  config = {
  boot.binfmt.registrations."APE" = mkIf cfg.enable
    (if cfg.mode == "loader" then
      {
        recognitionType = "magic";
        magicOrExtension = "MZqFpD";
        interpreter = "${apeElfLoader}";
        # TODO: get the elf loader from local compilation of Cosmo
      }
     else {
       # APE workaround (not ape loader)
       # FIXME NOT WORKING LAST I CHECKED
       recognitionType = "magic";
       magicOrExtension = "MZqFpD";
       interpreter = "${pkgs.bash}/bin/sh";
     });
  };
}
