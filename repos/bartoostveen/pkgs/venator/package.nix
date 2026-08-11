{
  lib,
  callPackage,
  buildGoModule,
  fetchFromGitea,
  nix-update-script,
  go,
  mdbook,
  versionCheckHook,
  withDocs ? true,
}:

buildGoModule (finalAttrs: {
  pname = "venator";
  version = "0.1.0a2-unstable-2026-08-11";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "matrix-venator";
    repo = "venator";
    rev = "873eb42ea1b2de21ceb8dd1aaa3d11ad3f5ee926";
    hash = "sha256-NXTdCvxLxJJAZDH6VZsonFsW4EQWkODBV9y9fnVtBWc=";
  };

  vendorHash = "sha256-SMHhDTNkknJ6OawlyZ53uZhjYIDtL9LjbTg/dZ4VJkI=";

  preBuild = lib.optionalString withDocs ''
    if [ -d vendor ]; then
      go generate -tags "$VENATOR_BUILD_TAGS" ./internal/embedded_docs/
    fi
  '';

  nativeBuildInputs = lib.optional withDocs mdbook ++ [
    versionCheckHook
  ];

  tags = lib.optional withDocs "docs";

  env = {
    VENATOR_BUILD_TAGS = lib.concatStringsSep "," finalAttrs.tags;
    GOEXPERIMENT = "jsonv2";
  };

  ldflags = [
    "-s"
    "-w"
    "-X"
    "codeberg.org/matrix-venator/venator/version.LatestTag=${finalAttrs.version}"
    "-X"
    "codeberg.org/matrix-venator/venator/version.CurrentTag=${finalAttrs.version}"
    "-X"
    "codeberg.org/matrix-venator/venator/version.CommitHash=${finalAttrs.src.rev}"
    "-X"
    "codeberg.org/matrix-venator/venator/version.Dirty=false"
    "-X"
    "codeberg.org/matrix-venator/venator/version.BuildDate=\"1970.01.01T00.00.00Z\""
    "-X"
    "codeberg.org/matrix-venator/venator/version.GoVersion=${go.version}"
    "-X"
    "codeberg.org/matrix-venator/venator/version.OSArch=${finalAttrs.goModules.GOARCH}"
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch=dev" ]; };
    docs = callPackage (
      {
        stdenv,
        mdbook,
      }:

      stdenv.mkDerivation {
        pname = "venator-docs";
        inherit (finalAttrs) version src meta;

        nativeBuildInputs = [ mdbook ];

        dontConfigure = true;

        buildPhase = ''
          runHook preBuild

          mdbook build

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          cp -r site $out

          runHook postInstall
        '';
      }
    ) { };
  };

  meta = {
    description = "Matrix Venator - versatile capital Matrix homeserver written from scratch in mautrix-go";
    homepage = "https://codeberg.org/matrix-venator/venator";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "venatorctl";
    platforms = lib.platforms.all;
  };
})
