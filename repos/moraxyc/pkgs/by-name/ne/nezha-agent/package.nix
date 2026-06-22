{
  nixpkgs,
  sources,

  source ? sources.nezha-agent,
}:
nixpkgs.nezha-agent.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    # nix-update auto
    vendorHash = "sha256-kYw1XgtlzRSQ0k8XK0lCJ0s2UaevVdmPunb9e7hoc70=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
