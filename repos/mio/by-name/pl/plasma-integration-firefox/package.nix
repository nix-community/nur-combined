{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  zip,
  gitUpdater,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-integration-firefox";
  version = "2.2";

  extid = "plasma-browser-integration@kde.org";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-browser-integration";
    rev = "v6.8.0";
    hash = "sha256-Dm/80XXtn8NO7dtfRKu73ofa2VWxiGkXxcxHVfK2LW0=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    work="$TMPDIR/plasma-integration"
    mkdir -p "$work"
    cp -r extension/. "$work/"

    pushd "$work" > /dev/null
    zip -qr "$TMPDIR/plasma-integration.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/plasma-integration.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/plasma-integration.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Plasma Browser Integration Firefox add-on built from KDE source";
    homepage = "https://invent.kde.org/plasma/plasma-browser-integration";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
