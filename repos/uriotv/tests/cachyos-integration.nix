# Evaluate the real NixOS module/kernel combination, without building a system.
let
  pinned = import ../pkgs/linux-cachyos-bore-x86_64-v3/pinned.nix { };
  flake = builtins.getFlake (toString ../.);
  # Use the consumer's different nixpkgs to prove that the exported module keeps
  # the kernel derivation pinned to the CI compiler/configuration nonetheless.
  evaluated = import (flake.inputs.nixpkgs.outPath + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      flake.nixosModules.cachyos
      {
        boot.cachyos = {
          enable = true;
          cpuSupportsV3 = true;
        };
        boot.loader.grub.devices = [ "nodev" ];
        fileSystems."/" = { device = "tmpfs"; fsType = "tmpfs"; };
        system.stateVersion = "26.05";
      }
    ];
  };
  config = evaluated.config;
  kernel = config.boot.kernelPackages.kernel;
  options = kernel.structuredExtraConfig;
in
assert builtins.all (a: a.assertion) config.assertions;
assert kernel.drvPath == pinned.kernel.drvPath;
assert options.SCHED_BORE.content.tristate == "y";
assert options.X86_64_VERSION.content.freeform == "3";
assert options.LTO_NONE.content.tristate == "y";
assert options.LTO_CLANG_THIN.content.tristate == "n";
assert builtins.elem "dev" kernel.outputs;
assert builtins.elem "https://uriotv.cachix.org" config.nix.settings.substituters;
assert builtins.elem "https://cache.nixos.org/" config.nix.settings.substituters;
{
  inherit (kernel) version drvPath outputs;
}
