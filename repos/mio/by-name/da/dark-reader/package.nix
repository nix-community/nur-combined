{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "dark-reader";
  version = "4.9.132";

  extid = "addon@darkreader.org";

  nativeBuildInputs = [ zip ];

  patches = [
    ./keep-awake.patch
  ];

  src = fetchFromGitHub {
    owner = "darkreader";
    repo = "darkreader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1GNqwA4RfZ2jTm8FkIk5kSOBj7IWTiICFGLKs0My1G0=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-eyVjBcaDUtoVSAnOWDhGFHeM1JoPXRyuyZp6lO5kB5E=";

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
