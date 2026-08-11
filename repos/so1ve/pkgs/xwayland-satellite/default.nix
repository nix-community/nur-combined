{
  rustPlatform,
  source,
  xwayland-satellite,
}:

xwayland-satellite.overrideAttrs (previousAttrs: {
  version = "0.8.2-unstable-${source.date}";
  inherit (source) src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  meta = previousAttrs.meta // {
    homepage = "https://github.com/so1ve/xwayland-satellite";
  };
})
