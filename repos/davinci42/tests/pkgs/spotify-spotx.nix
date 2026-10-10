{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  package = (import ../../default.nix { inherit pkgs; }).spotify-spotx;
  configured = package.override {
    spotxFlags = [
      "--premium"
      "--noexp"
      "--hide"
    ];
  };
  rejects = args: !(builtins.tryEval (package.override args).drvPath).success;
  checks = {
    configurableFlags = lib.hasInfix (lib.escapeShellArgs configured.spotxFlags) configured.postInstall;
    rejectInteractive = rejects { spotxFlags = [ "--interactive" ]; };
    rejectInstaller = rejects { spotxFlags = [ "--installdeb" ]; };
    rejectPathOverride = rejects { spotxFlags = [ "-P" ]; };
    rejectUnknownFlag = rejects { spotxFlags = [ "--unknown" ]; };
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
  clientRoot = "${package}/share/spotify";
  appsPath = "${clientRoot}/Apps";
in
assert lib.assertMsg (failures == [ ]) "Failed checks: ${lib.concatStringsSep ", " failures}";
pkgs.runCommand "spotify-spotx-tests"
  {
    nativeBuildInputs = [ pkgs.python3 ];
  }
  ''
    python3 - ${lib.escapeShellArg appsPath} <<'PY'
    import sys
    import zipfile
    from pathlib import Path

    apps = Path(sys.argv[1])
    with zipfile.ZipFile(apps / "xpui.spa") as archive:
        assert archive.testzip() is None
        scripts = [archive.read(name) for name in archive.namelist() if name.endswith(".js")]
        assert any(b"SpotX was here" in script for script in scripts)
    assert not (apps / "xpui").exists()
    PY
    cmp ${../../pkgs/spotify-spotx/SpotX-Bash-LICENSE} ${package}/share/licenses/spotify-spotx/SpotX-Bash-LICENSE
    test -x ${package}/bin/spotify
    test -f ${package}/share/applications/spotify.desktop
    test -e ${package}/share/icons/hicolor/128x128/apps/spotify-client.png
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/config"
    export XDG_CACHE_HOME="$HOME/cache"
    mkdir -p "$HOME"
    env -u DISPLAY -u WAYLAND_DISPLAY timeout 30 ${package}/bin/spotify --version > version.txt
    grep -F ${lib.escapeShellArg package.version} version.txt
    touch "$out"
  ''
