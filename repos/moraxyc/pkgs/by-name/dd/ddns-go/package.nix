{
  nixpkgs,
}:
nixpkgs.ddns-go.overrideAttrs (
  finalAttrs: prevAttrs: {
    patches = prevAttrs.patches or [ ] ++ [
      ./0001-feat-add-systemd-socket-activation.patch
    ];

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
