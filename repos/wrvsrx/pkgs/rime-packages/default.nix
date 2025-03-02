{
  sources,
  librime,
  lib,
  newScope,
}:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
    hooks = callPackage ./hooks { };
  in
  {
    inherit librime;
    withRimeDeps' = callPackage ./with-rime-deps-prime { };
    inherit (hooks) rimeDataBuildHook;
    rime-fcitx5 = callPackage ./rime-fcitx5 { };
    rime-prelude = callPackage ./rime-prelude { source = sources.rime-prelude; };
  }
  // (import ./rime-ice { source = sources.rime-ice; } self)
)
