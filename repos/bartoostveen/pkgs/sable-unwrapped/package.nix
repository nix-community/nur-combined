{
  lib,
  stdenv,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  nodejs_24,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_24;

  # separately build @sableclient/matrixrtc because this is a non-functional prepare script that builds it upstream
  matrix-rtc = stdenv.mkDerivation (finalAttrs: {
    pname = "matrix-rtc";
    version = "0-unstable-2026-08-08";

    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "SableClient";
      repo = "matrix-rtc";
      rev = "519fe6b863cfac78700f4e2b1748649103bb8a8d";
      hash = "sha256-n5f7529RdRxY8/a43Xkgrhg4yRz5aNgfoZqWrB7kvak=";
    };

    nativeBuildInputs = [
      pnpm
      pnpmConfigHook
      nodejs
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-8SnwSMe4Gqe8bNQQixZUDUtRIONN+zKegDoo2hoFdps=";
    };

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

    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

    meta = {
      description = "";
      homepage = "https://github.com/SableClient/matrix-rtc";
      changelog = "https://github.com/SableClient/matrix-rtc/blob/${finalAttrs.src.rev}/CHANGELOG.md";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ bartoostveen ];
      mainProgram = "matrix-rtc";
      platforms = lib.platforms.all;
    };
  });

  # The same holds for tauri-plugin-livekit-mobile (see above)
  tauri-plugin-livekit-mobile = stdenv.mkDerivation (finalAttrs: {
    pname = "tauri-plugin-livekit-mobile";
    version = "0-unstable-2026-08-13";

    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "SableClient";
      repo = "tauri-plugin-livekit-mobile";
      rev = "c6f0d02ab3da1174535bc1dc8e598a2e6873f977";
      hash = "sha256-ZPx6Ic+Gkvzg9LXYP9BaQALzOrvLCcQHOms8U3VfnU0=";
    };

    nativeBuildInputs = [
      pnpm
      pnpmConfigHook
      nodejs
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-xfr78k+twMH0JxWxvGymZohzUvHOAtrBdO9pQeIJVfI=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist-js $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

    meta = {
      description = "";
      homepage = "https://github.com/SableClient/tauri-plugin-livekit-mobile";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ bartoostveen ];
      mainProgram = "tauri-plugin-livekit-mobile";
      platforms = lib.platforms.all;
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-unwrapped";
  version = "nightly-unstable-2026-08-16";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    rev = "e40782906dcc8347e8840f446232c62f6fe62b56";
    hash = "sha256-jcvkjnh+saOGHUvMJN1cVzbW1zLymc0CAuZBFib6StM=";
  };

  inherit
    matrix-rtc
    tauri-plugin-livekit-mobile
    ;

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-GkycS/o2P6mceDZdFjx81p4jH8wGjZwh4cjPlJIsECs=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
  };

  buildPhase = ''
    runHook preBuild

    pnpm -- config set nodeOptions "--max-old-space-size=4096"

    mkdir node_modules/@sableclient/matrixrtc/dist
    mkdir node_modules/@sableclient/tauri-plugin-livekit-mobile/dist-js

    cp -r ${finalAttrs.matrix-rtc}/* node_modules/@sableclient/matrixrtc/dist/
    cp -r ${finalAttrs.tauri-plugin-livekit-mobile}/* node_modules/@sableclient/tauri-plugin-livekit-mobile/dist-js/

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An almost stable Matrix client";
    homepage = "https://github.com/SableClient/Sable";
    changelog = "https://github.com/SableClient/Sable/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
