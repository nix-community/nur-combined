{
  config,
  overlays,
  path,
  stdenv,
}:
  # TODO: factor out some `mkNixpkgs` helper?
  import "${path}/pkgs/top-level" {
    inherit overlays;
    config = config // {
      strictDepsByDefault = true;
    };
    localSystem = stdenv.buildPlatform.system;
    crossSystem = stdenv.hostPlatform.config;
    # XXX: doesn't forward crossOverlays: not composable with pkgsSpliced
  }
