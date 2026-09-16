{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  nix-update-script,
}:
let
  pnpm = pnpm_11;
in
buildGoModule rec {
  pname = "syncyomi";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "SyncYomi";
    repo = "SyncYomi";
    tag = "v${version}";
    hash = "sha256-Qbibe+D2YpNY7pPrAePFXBNLSrN0m2Kwvko0a7bMpW4=";
  };

  vendorHash = "sha256-kn9GihRu/TmQLDRw5TEkXvGLWHM7eO/qROyo+yYA44o=";

  web = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "${pname}-web";
    inherit src version;
    sourceRoot = "${finalAttrs.src.name}/web";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-Zi8JY4Bm0sm8phU+dWlNOuU04tbaRLC/Uixgm5YKe3A=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  });

  preConfigure = ''
    cp -r $web/* web/dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  postInstall = lib.optionalString (!stdenvNoCC.hostPlatform.isDarwin) ''
    mv $out/bin/SyncYomi $out/bin/syncyomi
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source project to synchronize Tachiyomi manga reading progress and library across multiple devices";
    homepage = "https://github.com/SyncYomi/SyncYomi";
    changelog = "https://github.com/SyncYomi/SyncYomi/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [
      eriedaberrie
      ataraxiasjel
    ];
    mainProgram = "syncyomi";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
