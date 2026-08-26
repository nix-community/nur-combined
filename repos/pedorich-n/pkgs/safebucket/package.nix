{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "safebucket";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "safebucket";
    repo = "safebucket";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0p+MfInb9dfKp5MuEJdKKNCvNO3nv1uaNDKrC6XnrwU=";
  };

  vendorHash = "sha256-3qK7bNlhpOCcEl1qCG63ZkU/GgEN+/q8qPBi8MoRU6w=";

  strictDeps = true;
  __structuredAttrs = true;

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  preBuild = ''
    mkdir -p web/dist
    cp -r ${finalAttrs.passthru.frontend}/. web/dist
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
      ];
    };

    frontend = buildNpmPackage {
      pname = "safebucket-frontend";
      inherit (finalAttrs) src version;

      strictDeps = true;
      __structuredAttrs = true;

      sourceRoot = "${finalAttrs.src.name}/web";

      npmDepsHash = "sha256-bv+AiReYPCxpNVYASLjZzdO04W2FXoOqhKsECrYwRV0=";

      installPhase = ''
        runHook preInstall

        mkdir $out
        cp -r dist/. $out

        runHook postInstall
      '';
    };
  };

  meta = {
    mainProgram = "safebucket";
    description = "On-prem file sharing made simple, fast and safe.";
    homepage = "https://github.com/safebucket/safebucket";
    changelog = "https://github.com/safebucket/safebucket/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
