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
}:

let
  go = go_1_27;
in
buildGo127Module (finalAttrs: {
  pname = "venator";
  version = "0.1.0a3-unstable-2026-09-06";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromCodeberg {
    owner = "matrix-venator";
    repo = "venator";
    rev = "980e017751beddeedb0b9a79167b9e8faf95b2d4";
    hash = "sha256-ZgiGINo43QgKQVLY70BoH9MSkrR9ncLlgGxCvvk479E=";
  };

  vendorHash = "sha256-1/znvlE2AxEmYITU8FoNTK1T/5tz7s4+AiWnz88vHvA=";

  preBuild = lib.optionalString withDocs ''
    if [ -d vendor ]; then
      go generate -tags "$VENATOR_BUILD_TAGS" ./internal/venatord/api/static/
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
