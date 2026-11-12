{
  nixpkgs,
  sources,

  source ? sources.bark-server,
}:
nixpkgs.bark-server.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src vendorHash;

    postPatch = ''
      echo "1970-01-01T00:00:00Z" > SOURCE_DATE_EPOCH
      echo "${finalAttrs.src.rev}" > COMMIT
    '';

    patches = prevAttrs.patches or [ ] ++ [
      ./0001-feat-add-support-for-systemd-socket-activation.patch
      ./0002-feat-Add-shutdown-timeout-for-idle-auto-termination.patch
    ];

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
