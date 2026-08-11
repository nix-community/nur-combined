{
  lib,
  rustPlatform,
  pkg-config,
  udev,
  alsa-lib,
  vulkan-loader,
  xorg,
  wayland,
  libxkbcommon,
  mesa,
  xvfb-run,
  makeWrapper,
}:

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
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
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
    mesa.drivers
  ];

  checkPhase = ''
    runHook preCheck
    export WGPU_BACKEND=vulkan
    export VK_ICD_FILENAMES=${mesa.drivers}/share/vulkan/icd.d/lvp_icd.x86_64.json
    export LIBGL_ALWAYS_SOFTWARE=1
    xvfb-run -a cargo test --release
    runHook postCheck
  '';

  postInstall = ''
    wrapProgram $out/bin/hanga \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader wayland libxkbcommon alsa-lib udev mesa ]}
  '';

  meta = {
    description = "Hanga: Minecraft + Luanti + Teardown + GTA at the same time";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    mainProgram = "hanga";
  };
}
