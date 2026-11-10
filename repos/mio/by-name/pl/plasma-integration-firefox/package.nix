{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  zip,
  writeShellApplication,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-integration-firefox";
  version = "6.8.3";

  extid = "plasma-browser-integration@kde.org";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-browser-integration";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DIvQY936eX+8AVlTy5VdiJCbasUfhOhsmOAnd5B/XS8=";
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
    updateScript = writeShellApplication {
      name = "update-plasma-integration-firefox";
      text = ''
        export UPDATE_NIX_ATTR_PATH="plasma-integration-firefox"
        exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
      '';
    };
  };

  meta = {
    description = "Plasma Browser Integration Firefox add-on built from KDE source";
    homepage = "https://invent.kde.org/plasma/plasma-browser-integration";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
