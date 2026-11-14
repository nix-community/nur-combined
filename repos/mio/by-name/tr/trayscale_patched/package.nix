{
  lib,
  stdenv,
  trayscale,
}:

trayscale.overrideAttrs (
  old:
  lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    patches = (old.patches or [ ]) ++ [ ./trayscale-main-thread.patch ];

    # godbus v5.2.3 returns a single value from getSystemBusPlatformAddress,
    # which is declared to return (string, error), so every darwin build that
    # vendors it dies with "not enough return values have (string) want
    # (string, error)" in vendor/github.com/godbus/dbus/v5/conn_darwin.go.
    # Upstream fixed it in v5.2.4; until trayscale bumps godbus itself, repair
    # the vendored copy. The vendor tree is only populated at the end of
    # configurePhase, so this cannot be a regular patch.
    postConfigure = (old.postConfigure or "") + ''
      substituteInPlace vendor/github.com/godbus/dbus/v5/conn_darwin.go \
        --replace-fail 'return fmt.Sprintf("unix:path=%s", address)' 'return fmt.Sprintf("unix:path=%s", address), nil'
    '';
  }
)
