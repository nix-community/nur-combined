{
  lib,

  buildNpmPackage,
  fetchFromGitHub,

  makeWrapper,
}:
buildNpmPackage (finalAttrs: {
  pname = "genieacs";
  version = "1.2.13";

  src = fetchFromGitHub {
    owner = "genieacs";
    repo = "genieacs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VQbqRcR5xHbADY8PxNJhlO1hcd6Y9/n5k6iEWqXz/F0=";
  };

  patches = [ ./build-metadata.patch ];

  nativeBuildInputs = [ makeWrapper ];

  npmDepsHash = "sha256-9vFVBY9GtIOztId80oS7XimpNqsqC4VoO5o161OdkSQ=";

  postPatch = ''
    cp npm-shrinkwrap.json package-lock.json
  '';

  preFixup = ''
    rm "$out"/bin/*
    mkdir -p "$out"/share
    cp -r dist "$out"/share/genieacs
    for binFile in "$out"/share/genieacs/bin/*; do
      makeWrapper "$binFile" "$out"/bin/$(basename -- "$binFile") --chdir "$out"/share/genieacs --prefix NODE_PATH : "$out"/lib/node_modules/genieacs/node_modules
    done
  '';

  meta = {
    description = "An Automatic Configuration Server implementing the TR-069 protocol";
    homepage = "https://genieacs.com/";
    license = [ lib.licenses.agpl3Only ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # things are pulled from npm, and some npm packages may include prebuilt stuff
      binaryNativeCode
      binaryBytecode
    ];
    maintainers = [ lib.maintainers.shelvacu ];
    # intentionally lacking mainProgram; genieacs has 3 main binaries
    platforms = lib.platforms.all;
  };
})
