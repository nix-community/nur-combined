{
  lib,
  callPackage,
  spotify,
  bash,
  perl,
  unzip,
  zip,
  util-linux,
  nix-update-script,
  spotxFlags ? [ ],
}:
let
  spotx = callPackage ./spotx.nix { };
  spotifyVersion = builtins.head (lib.splitString ".g" spotify.version);
  clientPath = "$out/share/spotify";
  allowedFlags = [
    "--premium"
    "--noexp"
    "--devmode"
    "--hide"
    "--lyricsbg"
    "--oldui"
  ];
in
assert lib.assertMsg (lib.all (
  flag: builtins.elem flag allowedFlags
) spotxFlags) "spotify-spotx: unsupported spotxFlags; use documented patch-only flags";
spotify.overrideAttrs (old: {
  pname = "spotify-spotx";

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    bash
    perl
    unzip
    zip
    util-linux
  ];

  postInstall = (old.postInstall or "") + ''
    (
      export HOME="$TMPDIR/spotx-home"
      export SPOTX_BUILD_MODE=true
      mkdir -p "$HOME"
      chmod -R u+w "${clientPath}"
      ${lib.getExe bash} ${spotx.src} \
        --noninteractive --nocolor -P "${clientPath}" -F ${lib.escapeShellArg spotifyVersion} \
        ${lib.escapeShellArgs spotxFlags}
    )
    install -Dm644 ${./SpotX-Bash-LICENSE} "$out/share/licenses/spotify-spotx/SpotX-Bash-LICENSE"
  '';

  passthru = (old.passthru or { }) // {
    inherit spotx spotxFlags;
    updateScript = {
      attrPath = "spotify-spotx.spotx";
      command = nix-update-script {
        attrPath = "spotify-spotx.spotx";
        extraArgs = [
          "-f"
          "."
          "--version=branch=main"
          "--url"
          "https://github.com/SpotX-Official/SpotX-Bash"
          "--src-only"
        ];
      };
    };
    tests.packaging = callPackage ../../tests/pkgs/spotify-spotx.nix { };
  };

  meta = old.meta // {
    description = "Spotify patched with SpotX-Bash";
    platforms = [ "x86_64-linux" ];
  };
})
