{
  niri,
  rustPlatform,
  source,
}:

niri.overrideAttrs (previousAttrs: {
  inherit (source) src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  env = previousAttrs.env // {
    NIRI_BUILD_COMMIT = source.version;
  };

  meta = previousAttrs.meta // {
    homepage = "https://github.com/so1ve/niri";
  };
})
