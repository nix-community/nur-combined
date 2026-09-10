{
  callPackage,
  rustPlatform,
  source ? callPackage ./source.nix { },
  xwayland-satellite,
}:

xwayland-satellite.overrideAttrs (previousAttrs: {
  version = "0.8.2-unstable-${source.date}";
  inherit (source) src;

  cargoDeps = rustPlatform.importCargoLock (import ./cargo-lock.nix);

  meta = previousAttrs.meta // {
    homepage = "https://github.com/Supreeeme/xwayland-satellite";
    changelog = "https://github.com/Supreeeme/xwayland-satellite/commits/${source.rev}";
  };
})
