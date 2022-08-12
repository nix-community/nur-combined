rec {
  checkPlatform = system: pkg:
    !(pkg ? meta && pkg.meta ? platforms)
    || (builtins.elem system pkg.meta.platforms)
  ;
}
