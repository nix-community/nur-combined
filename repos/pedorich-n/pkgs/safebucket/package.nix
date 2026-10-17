{
  buildGo127Module, # TODO: rollback to buildGoModule once it's using Go >=1.27
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:
buildGo127Module (finalAttrs: {
  pname = "safebucket";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "safebucket";
    repo = "safebucket";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aBOPPXedChviNnmXq+o7Cuc88IuHhLdiVvZLtOPllFA=";
  };

  vendorHash = "sha256-+fJq6b+ByFfaXXYGYcqA8FyUvGtP2TweU4nBGjTyKZc=";

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
        "--flake"
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

      npmDepsHash = "sha256-F0pu3mQpGARBnx/OJm7R8FgOLg/w2fel+xjTrXwn8z4=";

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
