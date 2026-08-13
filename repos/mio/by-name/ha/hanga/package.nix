{
  lib,
  rustPlatform,
  pkg-config,
  udev,
  alsa-lib,
  vulkan-loader,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  wayland,
  libxkbcommon,
  mesa,
  xvfb-run,
  makeWrapper,
  callPackage,
}:

let
  mods = callPackage ./mods.nix { };
in
rustPlatform.buildRustPackage {
  pname = "hanga";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [
    udev
    alsa-lib
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
    wayland
    libxkbcommon
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    vulkan-loader
    wayland
    libxkbcommon
    alsa-lib
    udev
    mesa
  ];

  nativeCheckInputs = [
    xvfb-run
    mesa
  ];

  preCheck = ''
    export HANGA_MODS=${mods}/share/hanga/mods
  '';

  checkPhase = ''
    runHook preCheck
    export WGPU_BACKEND=vulkan
    export VK_ICD_FILENAMES=${mesa}/share/vulkan/icd.d/lvp_icd.x86_64.json
    export LIBGL_ALWAYS_SOFTWARE=1

    # 1. Pure unit tests for the engine lib (no display / GPU required)
    cargo test --release --lib -- --test-threads=1

    # 2. Unit tests for shipped WASM mods (gameplay lives here)
    cargo test --release -p urban_chaos -- --test-threads=1
    cargo test --release -p testbed -- --test-threads=1

    # 3. Integration tests (agent CLI test) need a display + the installed mods
    xvfb-run -a cargo test --release --test '*' -- --test-threads=1

    runHook postCheck
  '';

  postInstall = ''
    mkdir -p $out/share/hanga
    cp -r ${mods}/share/hanga/mods $out/share/hanga/mods
    wrapProgram $out/bin/hanga \
      --set HANGA_MODS $out/share/hanga/mods \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          vulkan-loader
          wayland
          libxkbcommon
          alsa-lib
          udev
          mesa
        ]
      }
  '';

  passthru = {
    inherit mods;
  };

  meta = {
    description = "Hanga: Minecraft + Luanti + Teardown + GTA at the same time";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    mainProgram = "hanga";
  };
}
