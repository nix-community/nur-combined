{
  lib,
  buildGoLatestModule,
  nixpkgs,

  sources,
  source ? sources.dae,
}:
(nixpkgs.dae.override { buildGoModule = buildGoLatestModule; }).overrideAttrs (oldAttrs: {
  inherit (source) version src vendorHash;

  passthru = (oldAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
