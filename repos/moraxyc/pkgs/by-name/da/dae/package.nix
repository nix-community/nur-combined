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
  vendorHash = "sha256-Bf2OgF3+dOC2LiD/2Y+g+tfc07ZctdRH/BAUO23fX6k=";

  passthru = (oldAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
