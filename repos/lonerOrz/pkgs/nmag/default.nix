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
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "nmag";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7U0PvaPj9L1kwiS1SpHZ5yiO/nhkLQi2vGqblENCasc=";
  };

  cargoHash = "sha256-O2WRr11LuU0Yk2j2f0bek9d3EQ4VRMu4jOWrjMn0v9o=";

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
