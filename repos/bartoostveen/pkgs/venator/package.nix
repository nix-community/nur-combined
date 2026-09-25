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
  version = "0.1.0a4-unstable-2026-09-25";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromCodeberg {
    owner = "matrix-venator";
    repo = "venator";
    rev = "252b77c8ef3b3fa2c9130ab7c1a60f9b7bc830d0";
    hash = "sha256-lzlL8Hat4EP9PqwXwreGaPRCRKqolt8DuRZ8Ov8WHs4=";
  };

  vendorHash = "sha256-0flLB5KcpNarSFC0fZj3JzSLKlmzqGvGZ33oU6wBcHs=";

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
    withExperimentalOauth = finalAttrs.overrideAttrs {
      version = "0.1.0a4-unstable-2026-09-18";

      src = fetchFromCodeberg {
        owner = "matrix-venator";
        repo = "venator";
        rev = "c2e09307added03ec8e42928de7608ed956ba920";
        hash = "sha256-9fZSLpuXF+iMs/9TmMaZBqLd+OaCBHTAAFc9zLxrl2I=";
      };

      vendorHash = "sha256-0flLB5KcpNarSFC0fZj3JzSLKlmzqGvGZ33oU6wBcHs=";

      passthru = finalAttrs.passthru // {
        updateScript = nix-update-script {
          extraArgs = [ "--version=branch=wip/oauth2-account-management" ];
        };
      };
    };
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
