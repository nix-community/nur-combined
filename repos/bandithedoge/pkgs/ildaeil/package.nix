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
  version = "1.3-unstable-2026-11-13";
  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "Ildaeil";
    rev = "16a3cc6992127beff828e6c17f511132f26ea517";
    hash = "sha256-x7C9a9GDXmmYpvmsIjcMJOtyFccn6UWrLPQ8bPcXgko=";
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
