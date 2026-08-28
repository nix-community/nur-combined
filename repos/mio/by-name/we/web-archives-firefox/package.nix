{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "web-archives-firefox";
  version = "7.3.3";

  extid = "{d07ccf11-c0cd-4938-a265-2a4d6ad01189}";

  src = fetchFromGitHub {
    owner = "dessant";
    repo = "web-archives";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VPhHOfUj41R4IDYNy72rncKT3qigBOHXg5BIg7hUZcw=";
  };

  npmDepsHash = "sha256-O5fS7QceHk2pkWa7HEcmF5dZmZJogWSNycW8OkD9Wb4=";

  npmRebuild = false;
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    npm run build:firefox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    extdir=$(find dist -mindepth 1 -maxdepth 1 -type d -print -quit)
    test -n "$extdir"

    pushd "$extdir" > /dev/null
    zip -qr "$TMPDIR/web-archives.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/web-archives.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/web-archives.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/dessant/web-archives/releases/tag/v${finalAttrs.version}";
    description = "Web Archives Firefox add-on built from source";
    homepage = "https://github.com/dessant/web-archives";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
