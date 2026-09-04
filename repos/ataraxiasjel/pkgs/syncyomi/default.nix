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
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "SyncYomi";
    repo = "SyncYomi";
    tag = "v${version}";
    hash = "sha256-M+XgR651XYQzGT9eXMbDUrHhKOyHkI3pXwLsjPJjNQU=";
  };

  vendorHash = "sha256-PNyukiY11rD8i4h7Bb1SQbQAu2FiMyzWZDzRF8v/dM4=";

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
      hash = "sha256-vs6lJcYjo3b8fWEpivwA3YeEkrJ+NHPuCLs4TiIYkHY=";
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
