{
  upstream,
  sources,
}:
upstream.bark-server.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (sources.bark-server) version;

    src = prevAttrs.src.override {
      inherit (sources.bark-server.src) rev;
      tag = null;
      hash = "sha256-ANOGAzm+25WUoRMGE5b70uKE4EhlGkuC4QWvpa2K7Uo=";
    };

    patches = prevAttrs.patches or [ ] ++ [
      ./0001-feat-add-support-for-systemd-socket-activation.patch
      ./0002-feat-Add-shutdown-timeout-for-idle-auto-termination.patch
    ];

    # nix-update auto
    vendorHash = "sha256-eYSePxBEoVtqLJxA9/MxQOUMwnYnnZrIl/TcJ353HMQ=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
