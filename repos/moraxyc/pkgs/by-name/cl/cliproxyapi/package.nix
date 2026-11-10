{
  nixpkgs,

  sources,
  source ? sources.cliproxyapi,
}:
nixpkgs.cliproxyapi.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) src version;

    # nix-update auto
    vendorHash = "sha256-02Qqrs9lQ0kE+Tnk/SWvlkLXGSh8RQPxRawFZogRYNc=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
