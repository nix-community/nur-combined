{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wrapGAppsHook3,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "deltapatcher";
  version = "3.1.6";

  src = fetchFromGitHub {
    owner = "marco-calautti";
    repo = "DeltaPatcher";
    tag = "v${_.version}";
    hash = "sha256-gp31MKin/kQMmXRTQzzBFjAH5WiaOT3VilHL4ceyo6A=";
    fetchSubmodules =  true;
  };

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DwxBUILD_SHARED=OFF"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];
  
  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=v(\\d+\\.\\d+\\.\\d+)" ];
  };

  meta = {
    description = "GUI for creating and applying xdelta patches.";
    homepage = "https://github.com/marco-calautti/DeltaPatcher";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ claymorwan ];
  };
})
