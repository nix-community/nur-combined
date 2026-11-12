{
  nixpkgs,

  sources,
  source ? sources.cliproxyapi,
}:
nixpkgs.cliproxyapi.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) src version vendorHash;

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
