{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fontconfig,
  libGL,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ratty";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "ratty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fDNlyTOhwI1nzNf2/Z9DWtTEdJCZEDogLu13ETbpJAw=";
  };

  cargoHash = "sha256-4oLBONIyC924UGTw0d9RzGvNBolWdLMzzC+mihcD3B0=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    wayland
    libxkbcommon
    libGL
    vulkan-loader
  ];

  postInstall = ''
    wrapProgram $out/bin/ratty \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ 
        libxkbcommon
	wayland
	libGL
	vulkan-loader
      ]}"
  '';

  meta = {
    description = "A GPU-rendered terminal emulator with inline 3D graphics";
    homepage = "https://ratty-term.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ VZstless ];
    mainProgram = "ratty";
  };
})
