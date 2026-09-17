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
  vendorHash = "sha256-g/V/VcU/OsCVHGz3msCN1oaYXT+agmnEdojhmdwOry4=";

  passthru = (oldAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
