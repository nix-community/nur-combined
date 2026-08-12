{
  callPackage,
  niri,
  rustPlatform,
  source ? callPackage ./source.nix { },
}:

niri.overrideAttrs (previousAttrs: {
  inherit (source) src;

  cargoDeps = rustPlatform.importCargoLock (import ./cargo-lock.nix);

  env = previousAttrs.env // {
    NIRI_BUILD_COMMIT = source.rev;
  };

  meta = previousAttrs.meta // {
    homepage = "https://github.com/so1ve/niri";
  };
})
