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
      hash = "sha256-MXvmS61r/DZ1KL4xh2kv+NpnPhSpRefJn7LuWLoLD0w=";
    };

    patches = prevAttrs.patches or [ ] ++ [
      ./0001-feat-add-support-for-systemd-socket-activation.patch
      ./0002-feat-Add-shutdown-timeout-for-idle-auto-termination.patch
    ];

    # nix-update auto
    vendorHash = "sha256-bf2uITCsa+mYsV2U3tVhxeKCidWFCPG7wjPOA9VMMnQ=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
