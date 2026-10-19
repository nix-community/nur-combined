# ego lite is not in nixpkgs and ships only as a macOS DMG (Windows and Linux
# are on upstream's roadmap), so this repacks the official prebuilt app --
# same approach nixpkgs takes for google-chrome on darwin. The bundle arrives notarized with
# an intact seal, so it is copied verbatim.
#
# Upstream publishes no versioned download URL: the token below is rewritten
# in place on each release, so release_pins.py re-prefetches it nightly and
# bumps the hashes in pin.json; the version label there has to be corrected by
# hand from CFBundleShortVersionString.
#
# `version` describes the DMG in the store, which is not necessarily the
# version that runs: EgoUpdater rewrites the installed app in place, and can
# do that when the bundle is copied out to a writable path (home-manager's
# copyApps does) rather than symlinked from the store.
{
  lib,
  stdenvNoCC,
  fetchurl,
  runtimeShell,
  undmg,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "ego-lite";
  inherit (pin) version src;

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  # `ego-browser` is the whole point of the package for agent use, and it is
  # not a separate download: it is a self-contained helper (Mach-O with an
  # embedded Node) inside the app bundle. Upstream's GUI onboarding is what
  # normally drops it into ~/.local/bin; this puts it on PATH declaratively
  # instead.
  #
  # It picks the bundle at run time instead of symlinking the store's, because
  # a store symlink strands PATH on the DMG's build while the browser service
  # it drives moves on with each EgoUpdater release. That skew is worth this
  # much indirection because the service misreports it: 0.4.7.4 driving
  # 0.5.0.28 failed `import --browser chrome` with
  # SOURCE_DATABASE_COOKIES_TOO_OLD against a profile whose cookie schema
  # matched ego's own exactly.
  installPhase = ''
    runHook preInstall
    app=$(find . -maxdepth 1 -name "*.app" -print -quit)
    test -n "$app"
    mkdir -p "$out/Applications" "$out/bin"
    cp -R "$app" "$out/Applications/"

    cat > "$out/bin/ego-browser" <<'WRAPPER'
    #!${runtimeShell}
    helper='Contents/Frameworks/ego Framework.framework/Versions/Current/Helpers/ego-browser'
    # Home Manager Apps first: that copy is the one EgoUpdater can write to,
    # so it is the newest, and it is what LaunchServices actually opens.
    for bundle in \
      "$HOME/Applications/Home Manager Apps/ego lite.app" \
      "$HOME/Applications/ego lite.app" \
      "/Applications/ego lite.app" \
      '@store@'; do
      if [ -x "$bundle/$helper" ]; then
        exec "$bundle/$helper" "$@"
      fi
    done
    printf 'ego-browser: found no ego lite.app containing %s\n' "$helper" >&2
    exit 1
    WRAPPER

    substituteInPlace "$out/bin/ego-browser" \
      --replace-fail '@store@' "$out/Applications/ego lite.app"
    chmod +x "$out/bin/ego-browser"
    runHook postInstall
  '';

  meta = {
    description = "Chromium-based browser that shares your logged-in state with AI agents, plus its ego-browser automation CLI (official prebuilt macOS app)";
    homepage = "https://lite.ego.app/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ego-browser";
    inherit (pin) platforms;
  };
}
