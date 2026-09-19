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
  vendorHash = "sha256-N2noQXRV9Vewie4PiWkjDeX6U2+kF1kQ9L10kZ5X/LI=";

  passthru = (oldAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
