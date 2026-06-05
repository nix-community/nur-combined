{ config, lib, ... }:
let
  cfg = config.sane.hal.strict;
in
{
  options = {
    sane.hal.strict.enable = (lib.mkEnableOption "tweaks required on a strictDepsByDefault = true system") // {
      default = config.nixpkgs.config.strictDepsByDefault or false;
    };
  };

  config = lib.mkIf cfg.enable {
    sane.programs.alsa-utils.enableFor = { system = false; user.colin = false; };  #< 2026-01-31: blocked on ? -> ... -> gdb
    sane.programs.fftest.enableFor = { system = false; user.colin = false; };  #< 2026-01-31
    sane.programs.gdb.enableFor = { system = false; user.colin = false; };  #< 2026-01-31
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  # blocked on `mkYarnModules`
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # blocked on dotnet-sdk
    sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  # blocked on text-zipper
    sane.programs."sane-scripts.wipe".enableFor.user.colin = false;  #< 2026-01-31: blocked on libsecret
    sane.programs.valgrind.enableFor = { system = false; user.colin = false; };  #< 2026-01-31
  };
}
