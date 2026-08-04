{ lib, ... }:

{
  flake.githubActionsMatrix =
    let
      baseChannels = [
        "master"
        "nixpkgs-unstable"
      ];

      darwinSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      darwinChannels = baseChannels ++ [ "nixpkgs-25.05-darwin" ];

      nativelinuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      inferiorLinuxSystems = [
        "i686-linux"
      ];

      superiorSystems = {
        i686-linux = "x86_64-linux";
      };

      emulatedLinuxSystems = [
        "armv7l-linux"
        "riscv64-linux"
      ];

      qemuPlatforms = {
        armv7l-linux = "arm";
        riscv64-linux = "riscv64";
      };

      linuxSystems = nativelinuxSystems ++ inferiorLinuxSystems ++ emulatedLinuxSystems;

      linuxChannels = baseChannels ++ [
        "nixos-unstable"
        "nixos-unstable-small"
        "nixos-25.05"
        "nixos-25.05-small"
      ];

      runners =
        let
          ubuntuVersion = "24.04";
        in
        {
          x86_64-linux = "ubuntu-${ubuntuVersion}";
          aarch64-linux = "ubuntu-${ubuntuVersion}-arm";
          x86_64-darwin = "macos-13";
          aarch64-darwin = "macos-15";
        };

      emulatorRunner = runners.x86_64-linux;

      matrixFor =
        systems: channels:
        lib.mapCartesianProduct
          (
            { system, channel, ... }@attrs:
            let
              isInferior = lib.elem system inferiorLinuxSystems;
              isEmulated = lib.elem system emulatedLinuxSystems;
            in
            attrs
            // {
              runs-on =
                let
                  actualSystem = if isInferior then superiorSystems.${system} else system;
                in
                if isEmulated then emulatorRunner else runners.${actualSystem};
              continue-on-error = channel == "master" || isEmulated || isInferior;
              qemu = isEmulated;
              qemu-platform = if isEmulated then qemuPlatforms.${system} else null;
              channel-url =
                if channel == "master" then
                  "https://github.com/NixOS/nixpkgs/archive/master.tar.gz"
                else
                  "https://channels.nixos.org/${channel}/nixexprs.tar.xz";
            }
          )
          {
            system = systems;
            channel = channels;
          };
    in

    lib.concatLists [
      (matrixFor linuxSystems linuxChannels)
      (matrixFor darwinSystems darwinChannels)
    ];
}
