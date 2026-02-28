{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  nodejs,
  pnpm_9,
  esbuild,
  nix-update-script,
}:

buildGoModule rec {
  pname = "syncyomi";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "SyncYomi";
    repo = "SyncYomi";
    tag = "v${version}";
    hash = "sha256-ot8c7+a/YLhjt9HkcI8QZ2ICgtBj3VGJhxtnhWC0f+0=";
  };

  vendorHash = "sha256-7AySGQBQHaTp2M1uj5581ZqcpzgexI1KvanWMOc6rx0=";

  web = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "${pname}-web";
    inherit src version;
    sourceRoot = "${finalAttrs.src.name}/web";

    pnpmDeps = pnpm_9.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      fetcherVersion = 1;
      hash = "sha256-Gg4nOxqWb692GvvwE7AJKQzGrrLLW7haaooEkUZW7FQ=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm_9.configHook
    ];

    env.ESBUILD_BINARY_PATH = lib.getExe (
      esbuild.override {
        buildGoModule =
          args:
          buildGoModule (
            args
            // rec {
              version = "0.19.11";
              src = fetchFromGitHub {
                owner = "evanw";
                repo = "esbuild";
                rev = "v${version}";
                hash = "sha256-NUwjzOpHA0Ijuh0E69KXx8YVS5GTnKmob9HepqugbIU=";
              };
              vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
            }
          );
      }
    );

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
