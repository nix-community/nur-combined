{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  raylib,
  maintainers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raylib-cpp";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "RobLoach";
    repo = "raylib-cpp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e0DiU8d2v9W/p0Z23kklbMcDGhi6UXRjgXjMPusnABo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    raylib
  ];

  cmakeFlags = [
    "-DBUILD_RAYLIB_CPP_EXAMPLES=OFF"
  ];

  meta = with lib; {
    description = "C++ Object Oriented Wrapper for raylib";
    homepage = "https://github.com/RobLoach/raylib-cpp";
    changelog = "https://github.com/RobLoach/raylib-cpp/releases/tag/v${finalAttrs.version}";
    license = licenses.zlib;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ bensuperpc ];
  };
})