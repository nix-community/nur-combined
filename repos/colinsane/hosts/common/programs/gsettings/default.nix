{ config, lib, pkgs, ... }:
let
  # [ ProgramConfig ]
  enabledPrograms = builtins.filter
    (p: p.enabled && p.gsettings != {})
    (builtins.attrValues config.sane.programs);

  keyfileTexts = lib.map (p: lib.generators.toDconfINI p.gsettings) enabledPrograms;

  cfg = config.sane.programs.gsettings;
in
{
  sane.programs.gsettings = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.glib "gsettings";
    # most things don't actually need this persistence.
    # the strategy is to selectively grant consumers access to this directory -- and only those who actually need persistence.
    persist.byStore.private = [ ".config/glib-2.0/settings" ];
    env.GSETTINGS_BACKEND = "keyfile";
  };

  environment.etc."glib-2.0/settings/defaults" = lib.mkIf cfg.enabled {
    # GKeyfileSettingsBackend slurps from just two files:
    # - /etc/glib-2.0/settings/default  (immutable)
    # - ~/.config/glib-2.0/settings/keyfile  (mutable, and overrides the above)
    # it doesn't mind me just concatenating everything together though; it handles duplicate groups gracefully.
    #
    # for tighter control, /etc/glib-2.0/settings/locks can be used to restrict which values a glib program may write to ~/.config/glib-2.0/settings/keyfile,
    # but this isn't so much needed for as long as i'm not persisting that keyfile
    text = lib.mkMerge keyfileTexts;
  };
}
