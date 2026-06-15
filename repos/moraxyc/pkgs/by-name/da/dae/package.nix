{
  lib,
  buildGoLatestModule,
  nixpkgs,

  sources,
  source ? sources.dae,
}:
(nixpkgs.dae.override { buildGoModule = buildGoLatestModule; }).overrideAttrs (oldAttrs: {
  inherit (source) version src;

  # nix-update auto -u
  vendorHash = "sha256-S2dNFvMeZqGhzu+sIBGeaET4bQXfeucao6XR4QSTpog=";

  passthru = (oldAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
