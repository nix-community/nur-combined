{ pkgs, lib }:

let

  mangohud_64 = pkgs.callPackage ./default.nix { };
  mangohud_32 = pkgs.pkgsi686Linux.callPackage ./default.nix { libprefix="lib32"; };

in

pkgs.buildEnv rec {
  name = "mangohud";

  paths = [
    mangohud_64
    mangohud_32
  ];

  # ignoreCollisions = true;

  meta = with lib; {
    description = "A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more.";
    homepage = "https://github.com/flightlessmango/MangoHud";
    # maintainers = with maintainers; [ zeratax ];
  };
}