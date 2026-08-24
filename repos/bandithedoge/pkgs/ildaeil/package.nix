# TODO: figure out plugin scanning with carla
{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libGL,
  libx11,
  libxcursor,
  libxext,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "ildaeil";
  version = "1.3-unstable-2026-02-21";
  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "Ildaeil";
    rev = "af9fc9f73b1a1832da8d6dfa12f7d03c431293d6";
    hash = "sha256-7oayKRqAHXEkf3PMsma3HfuHYXrNNR+xkrHyYrZ7s5I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxcursor
    libxext
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "mini-plugin host as plugin";
    homepage = "https://github.com/DISTRHO/Ildaeil";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "Ildaeil";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
