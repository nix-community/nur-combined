{ lib }:
{
  mkExternalEnableOption =
    cfg: s: lib.mkEnableOption s // { default = cfg.abszero.enableExternalModulesByDefault; };
}
