{
  lib,
  callPackage,
  buildGo127Module,
  fetchFromCodeberg,
  nix-update-script,
  go_1_27,
  mdbook,
  versionCheckHook,
  withDocs ? true,
  withFederation ? true,
}:

let
  go = go_1_27;
in
buildGo127Module (finalAttrs: {
  pname = "venator";
  version = "0.1.0a4-unstable-2026-09-26";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromCodeberg {
    owner = "matrix-venator";
    repo = "venator";
    rev = "dc94220b417335150df950f12f9e82efb4e3cfee";
    hash = "sha256-NelTffzKTOCee5Np6eE+qlR231/nOn4i/LCYBXrFGLk=";
  };

  vendorHash = "sha256-nMGU34KApGrnHqtoI6WoqDXBVhTwJIR8wAPzEZEWjko=";

  preBuild = lib.optionalString withDocs ''
    if [ -d vendor ]; then
      go generate -tags "$VENATOR_BUILD_TAGS" ./internal/venatord/api/static/
    fi
  '';

  nativeBuildInputs = lib.optional withDocs mdbook ++ [
    versionCheckHook
  ];

  tags = lib.optional withDocs "docs" ++ lib.optional withFederation "federation";

  env = {
    VENATOR_BUILD_TAGS = lib.concatStringsSep "," finalAttrs.tags;
    GOEXPERIMENT = "jsonv2";
  };

  ldflags = [
    "-s"
    "-w"
    "-X"
    "kuat.thefifthfleet.net/venator/version.LatestTag=${finalAttrs.version}"
    "-X"
    "kuat.thefifthfleet.net/venator/version.CurrentTag=${finalAttrs.version}"
    "-X"
    "kuat.thefifthfleet.net/venator/version.CommitHash=${finalAttrs.src.rev}"
    "-X"
    "kuat.thefifthfleet.net/venator/version.Dirty=false"
    "-X"
    "kuat.thefifthfleet.net/venator/version.BuildDate=\"1970.01.01T00.00.00Z\""
    "-X"
    "kuat.thefifthfleet.net/venator/version.GoVersion=${go.version}"
    "-X"
    "kuat.thefifthfleet.net/venator/version.OSArch=${finalAttrs.goModules.GOARCH}"
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
