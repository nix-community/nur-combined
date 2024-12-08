{ lib, fetchFromGitHub, rustPlatform, pkgs }: let
  buildInputs = with pkgs; [
    wayland
    wayland-scanner
    wayland-utils
    wayland-protocols
    xorg.libxcb
    xorg.xcbutilrenderutil
    xorg.libXau
    xorg.libXdmcp
    shaderc
  ];
in rustPlatform.buildRustPackage rec {
  inherit buildInputs;

  pname = "amdgpud";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner  = "Eraden";
    repo   = pname;
    rev    = "v" + version;
    sha256 = "AAchC//Thrs5ZBOiP9fOtUFdVwJGDW9LtQ9+ja7lXQk=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    git
    python3
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

  cargoHash = "sha256-0OI/AQe0mtpxcp6Ok6iepCIdJpdSgFKz8nO3uFEVRDY=";

  meta = with lib; {
    description = "AMD GPU management tools";
    homepage = "https://github.com/Eraden/amdgpud";
    license = licenses.mit;
  };
}

