{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  zip,
  nix-update-script,
  writeShellApplication,
}:

buildNpmPackage (finalAttrs: {
  pname = "dark-reader";
  version = "4.9.135";

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
    hash = "sha256-UkquWrrlEBLosXeIgmadwlxtIgNE6A0sP/hiB6Mbgsg=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-RuRB9sUdBKqb0SV1wa/JpBoXecILgDPH64ooKqHJzmg=";

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
    updateScript = writeShellApplication {
      name = "update-dark-reader";
      text = ''
        export UPDATE_NIX_ATTR_PATH="dark-reader"
        exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
      '';
    };
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
