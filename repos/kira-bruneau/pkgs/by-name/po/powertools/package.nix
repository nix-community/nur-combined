{
  lib,
  stdenv,
  fetchFromGitea,
  cargo,
  cmake,
  nodejs,
  pnpm,
  rustc,
  rustPlatform,
  pciutils,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "powertools";
  version = "2.0.3";

  src = fetchFromGitea {
    domain = "git.ngni.us";
    owner = "NG-SD-Plugins";
    repo = "PowerTools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xBqEZzV/Y9xnmWPW6KQbn7HVlbtzRKGQNGdRAGcOsLI=";
  };

  patches = [
    ./fix-tests.patch
    ./fix-time.patch
    ./update-lock.patch
  ];

  cargoRoot = "backend";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    patches = [ ./fix-time.patch ];
    sourceRoot = "source/${finalAttrs.cargoRoot}";
    patchFlags = [ "-p2" ];
    hash = "sha256-YTppt5/kKgkheG0TtlX3Y3is+49vY+97lkEqQy6fEtE=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    patches = [ ./update-lock.patch ];
    fetcherVersion = 2;
    hash = "sha256-1Mn4FMXjcf5rRtyenjJHqrotDTG7z1J/v49rbIwTAyM=";
  };

  dontUseCmakeConfigure = true;

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    cmake
    nodejs
    pnpm.configHook
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoBuildHook
    rustPlatform.cargoCheckHook
    rustPlatform.cargoInstallHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [ pciutils ];

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  buildAndTestSubdir = "backend";

  cargoBuildType = "release";

  postBuild = ''
    pnpm run build
  '';

  cargoCheckType = finalAttrs.cargoBuildType;

  postInstall = ''
    mv "$out/bin/powertools" "$out/bin/backend"
    cp -r dist main.py plugin.json translations "$out"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Steam Deck power tweaks for power users";
    homepage = "https://git.ngni.us/NG-SD-Plugins/PowerTools";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "backend";
    platforms = platforms.all;
  };
})
