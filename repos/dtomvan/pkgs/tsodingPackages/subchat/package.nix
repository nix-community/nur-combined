{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  libxkbcommon,
  libGL,
  glfw,
  glew,
  makeWrapper,
  zenity,
  guiSupport ? true,
}:
stdenv.mkDerivation {
  pname = "subchat";
  version = "0-unstable-2025-04-08";

  src = fetchFromGitHub {
    owner = "dtomvan";
    repo = "SubChat";
    rev = "4528b9bf1066db4d231b13baf59dd0278e2062b8";
    hash = "sha256-wbTC4VZq1+mQJcrMAW5tLG0TzjSH75zFTrBEdyPvSSs=";
    fetchSubmodules = true;
  };

  cmakeFlags = lib.optional (!guiSupport) "-DBUILD_GUI=OFF";

  patches = [
    ./use-nix-glfw.patch # they are vendoring glfw, but nix needs some patches so just use nixpkgs version
    ./dont-fucking-static-link.patch # this is nixpkgs dammit, -static will not work with stdenv
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ] ++ lib.optional guiSupport wayland-scanner;

  buildInputs = lib.optionals guiSupport [
    glfw
    glew
    libGL
    wayland
    wayland-protocols
    libxkbcommon
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp subtitles_generator $out/bin
    ${lib.optionalString guiSupport "cp config_generator_gui $out/bin"}
    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup
    ${lib.optionalString guiSupport ''
      wrapProgram $out/bin/config_generator_gui \
        --prefix PATH ":" ${lib.makeBinPath [ zenity ]}
    ''}
    runHook postFixup
  '';

  meta = {
    description = "SubChat is a command-line and GUI toolset for generating YouTube subtitles from chat logs";
    homepage = "https://github.com/Kam1k4dze/SubChat";
    license = lib.licenses.mit;
    mainProgram = "subchat";
    platforms = lib.platforms.all;
  };
}
