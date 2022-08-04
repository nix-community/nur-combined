{
  default = final: prev:
    let
      nurPkgs = removeAttrs (import ../pkgs final prev) [
        "callPackage"
        "linuxPackages"
        "python2Packages"
        "python3Packages"
      ];

      linuxModulesOverlay = lfinal: lprev:
        removeAttrs (import ../pkgs/os-specific/linux/modules.nix final lfinal lprev) [ "callPackage" ];

      pythonModulesOverlay = pyfinal: pyprev:
        removeAttrs (import ../pkgs/development/python-modules final pyfinal pyprev) [ "callPackage" ];
    in
    nurPkgs // {
      linuxKernel = prev.linuxKernel // {
        packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend linuxModulesOverlay;
      };

      pythonInterpreters = builtins.mapAttrs
        (_: interpreter: interpreter.override { packageOverrides = pythonModulesOverlay; })
        prev.pythonInterpreters;
    };
}
