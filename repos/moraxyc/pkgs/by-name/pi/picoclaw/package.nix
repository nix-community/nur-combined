{
  nixpkgs,

  sources,
  source ? sources.picoclaw,
}:
nixpkgs.picoclaw.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    # nix-update auto
    vendorHash = "sha256-dVXjMzn2ClQJRTuhdpDNHvbzKuHThtfjZ4xiBz56I8E=";

    __darwinAllowLocalNetworking = true;

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
