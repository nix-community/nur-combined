{
  lib,
  rustPlatform,
  source,
  xwayland-satellite,
}:

xwayland-satellite.overrideAttrs (previousAttrs: {
  version = "0.8.2-unstable-${source.date}";
  inherit (source) src;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (source) src;
    hash = "sha256-Saa3SRsQuY6u6pfBGezaEExOt/ReblnrG7pAXjA6Dk8=";
  };

  meta = previousAttrs.meta // {
    homepage = "https://github.com/so1ve/xwayland-satellite";
  };
})
