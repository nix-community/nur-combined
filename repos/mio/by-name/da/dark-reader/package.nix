{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "dark-reader";
  version = "4.9.134";

  extid = "addon@darkreader.org";

  nativeBuildInputs = [ zip ];

  patches = [
    # Follow the system color scheme (KDE/Plasma on Linux): enable Dark Reader's
    # "Use system color scheme" automation by default, switch profiles still
    # holding the disabled stock default over once, and make a scheme change
    # actually reach the background page (fresh MediaQueryList + recheck).
    ./system-color-scheme.patch
  ];

  src = fetchFromGitHub {
    owner = "darkreader";
    repo = "darkreader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G0Z9MOvRpWRspTu81nW2d/WPjr7KPbkIgf/O6TCsEBQ=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-HDenlMeBZJjPbzeqoU5rWYrXcFovBCwei5oW+GUbedo=";

  buildPhase = ''
    runHook preBuild
    npm run build:firefox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd build/release/firefox > /dev/null
    zip -qr "$TMPDIR/dark-reader.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/dark-reader.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/dark-reader.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/darkreader/darkreader/releases/tag/v${finalAttrs.version}";
    description = "Dark Reader browser extension — eye-care dark mode for every website";
    homepage = "https://darkreader.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
