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

  cargoHash = let
    version = builtins.substring 0 5 lib.version;
  in {
    "24.05" = "sha256-0OI/AQe0mtpxcp6Ok6iepCIdJpdSgFKz8nO3uFEVRDY=";
    "24.11" = "sha256-0OI/AQe0mtpxcp6Ok6iepCIdJpdSgFKz8nO3uFEVRDY=";
    "25.05" = "sha256-XgdbFMcyoYRaimN4rEmqU8qkZg78vsCmPMlKeO5zPcg=";
  }.${version}; # DISGOSTAN

  meta = with lib; {
    description = "AMD GPU management tools";
    homepage = "https://github.com/Eraden/amdgpud";
    license = licenses.mit;
  };
}

