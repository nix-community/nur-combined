{
  nixpkgs,
  sources,

  source ? sources.bark-server,
}:
nixpkgs.bark-server.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    postPatch = ''
      echo "1970-01-01T00:00:00Z" > SOURCE_DATE_EPOCH
      echo "${finalAttrs.src.rev}" > COMMIT
    '';

    patches = prevAttrs.patches or [ ] ++ [
      ./0001-feat-add-support-for-systemd-socket-activation.patch
      ./0002-feat-Add-shutdown-timeout-for-idle-auto-termination.patch
    ];

    # nix-update auto
    vendorHash = "sha256-Q8ByawOpa7magYiD938mihFqjpLrOYaItiTn0cfXlHw=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
