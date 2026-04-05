{
  lib,
  makeWrapper,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wayland,
  wayland-protocols,
  libGL,
  vulkan-loader,
  libxkbcommon,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nmag";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "nmag";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8QMIT5ouXEgv+EzhmEvhjdCBw+Hc62ByqasCwQNYK3g=";
  };

  cargoHash = "sha256-14k3+GpyKf7mNrnjKUTAsROyml7JUp4iXkLtdhBqEl4=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    vulkan-loader
    libxkbcommon
  ];

  postInstall = ''
    wrapProgram $out/bin/nmag \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
        ]
      }
  '';

  meta = {
    description = "Full-screen zoom for Wayland compositors";
    homepage = "https://github.com/lonerOrz/nmag";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "nmag";
  };
})
