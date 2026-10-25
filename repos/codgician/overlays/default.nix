{
  # Adds every NUR kernel module to every linuxPackages* set, so
  # `config.boot.kernelPackages.<name>` matches the configured kernel.
  kernel-modules = final: prev: {
    kernelPackagesExtensions = prev.kernelPackagesExtensions ++ [
      (import ../pkgs/kernel-modules.nix).extension
    ];
  };
}
