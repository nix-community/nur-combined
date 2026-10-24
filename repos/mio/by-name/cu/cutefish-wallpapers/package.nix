{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  cmake,
  ninja,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenvNoCC.mkDerivation {
  pname = "cutefish-wallpapers";
  version = cu.version "2026-10-20";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "wallpapers";
    rev = "2c6191179b82c49584e738baf92d34a84c6a62d6";
    hash = "sha256-oyq7PuGb3X+aEwBC3neVXTl4a05bgjiVaPVfb1egIXs=";
  };

  postPatch = ''
    # The project only copies images. NONE skips the C/C++ compiler probe.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'project(cutefish-wallpapers)' 'project(cutefish-wallpapers NONE)'
    substituteInPlace sources/CMakeLists.txt \
      --replace-fail 'project(unsplash-wallpapers)' 'project(unsplash-wallpapers NONE)' \
      --replace-fail 'DESTINATION /usr/share/backgrounds/cutefishos' \
        'DESTINATION share/backgrounds/cutefishos'
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Default wallpapers for the Cutefish desktop";
    license = {
      fullName = "Unsplash License";
      url = "https://unsplash.com/license";
      free = true;
    };
  };
}
