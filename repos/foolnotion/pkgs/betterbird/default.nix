# Betterbird is a Thunderbird fork with, among other things, native
# minimize-to-tray support that upstream Thunderbird lacks. No nixpkgs
# derivation exists (a PR added one in 2023, later removed for going stale/
# unbuildable: https://github.com/NixOS/nixpkgs/pull/217930,
# https://github.com/NixOS/nixpkgs/issues/375417), so this mirrors
# nixpkgs' `thunderbird-bin` binary-tarball wrapping (autoPatchelfHook +
# wrapGAppsHook3) against Betterbird's own official Linux archive.
#
# Update instructions:
#   1. Check https://www.betterbird.eu/downloads/index.php for the current
#      version.
#   2. Resolve the real tarball URL (get.php redirects):
#        curl -sIL "https://www.betterbird.eu/downloads/get.php?os=linux&lang=en-US&version=release" | grep -i ^location
#   3. Update `version` and `src.url` below, then refetch the hash:
#        nix-prefetch-url --type sha256 "<url>"
#        nix-hash --to-sri --type sha256 "<prefetch-output>"
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  patchelfUnstable,
  wrapGAppsHook3,
  alsa-lib,
}:

let
  pname = "betterbird";
  version = "153.2.0esr-bb8";

  src = fetchurl {
    url = "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${version}.en-US.linux-x86_64.tar.xz";
    hash = "sha256-FC67Y9P4TG1KiCUs7Swt0s5dKOs7CLBfENhB/j1PgAE=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
  ];

  # Betterbird, like Thunderbird, uses "relrhack" to manually process
  # relocations from a fixed offset.
  patchelfFlags = [ "--no-clobber-old-sections" ];

  postPatch = ''
    # Don't try to fetch updates from Betterbird's own updater; Nix owns
    # the version.
    echo 'pref("app.update.auto", "false");' >> defaults/pref/channel-prefs.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/betterbird-bin-${version}"
    cp -r * "$out/lib/betterbird-bin-${version}"

    mkdir -p "$out/bin"
    ln -s "$out/lib/betterbird-bin-${version}/betterbird" "$out/bin/betterbird"

    install -Dm444 "$out/lib/betterbird-bin-${version}/chrome/icons/default/default256.png" \
      "$out/share/icons/hicolor/256x256/apps/betterbird.png"

    install -Dm444 /dev/stdin "$out/share/applications/betterbird.desktop" <<EOF
[Desktop Entry]
Name=Betterbird
Comment=Send and receive mail with Betterbird
Exec=$out/bin/betterbird %u
Icon=betterbird
Terminal=false
Type=Application
Categories=Network;Email;
MimeType=x-scheme-handler/mailto;message/rfc822;
StartupWMClass=betterbird
EOF

    gappsWrapperArgs+=(--argv0 "$out/bin/.betterbird-wrapped")

    runHook postInstall
  '';

  passthru = {
    binaryName = "betterbird";
  };

  meta = {
    description = "Fork of Mozilla Thunderbird with additional features and fixes (binary package)";
    homepage = "https://www.betterbird.eu/";
    changelog = "https://www.betterbird.eu/status/changelog-153.html";
    mainProgram = "betterbird";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };
}
