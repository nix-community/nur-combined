{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,

  pkg-config,

  gtk3,
  libxrandr,
  libxi,
  libxcursor,
  libx11,
  libxcb,
  openssl,  
  speechd-minimal,
  libxkbcommon,
  libGL,
  wayland,
}:

let
  rpathLibs = [
    speechd-minimal
    openssl
    gtk3
    libxkbcommon
    libGL

    # WINIT_UNIX_BACKEND=wayland
    wayland

    # WINIT_UNIX_BACKEND=x11
    libxcursor
    libxrandr
    libxi
    libx11
    libxcb
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "popup-mcp";
  version = "main";

  src = fetchFromGitHub {
    owner = "inanna-malick";
    repo = "popup-mcp";
    rev = finalAttrs.version;
    hash = "sha256-cWXEjs8E1FjUaVUkGGGqZ/KSJ++DBhz57CtcZJtAjh8=";
  };

  cargoHash = "sha256-Sg8JJ/F8HvPMI+VW6aBh7+zqt4BcBp7GrHmcv2ZZo18=";

  env = {
    OPENSSL_NO_VENDOR = 1;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_DIR = "${lib.getDev openssl}";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = rpathLibs;

  postInstall = ''
    patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/popup
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "Native GUI popups via MCP - Display interactive popup windows from AI assistants through the Model Context Protocol.";
    homepage = "https://github.com/inanna-malick/popup-mcp";
    license = licenses.mit;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux;
    mainProgram = "popup";
  };
})
