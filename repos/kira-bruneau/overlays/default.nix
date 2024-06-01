{
  default =
    final: prev:
    let
      nurPkgs = removeAttrs (import ../pkgs final prev) [
        "callPackage"
        "emacsPackages"
        "linuxPackages"
        "python3Packages"
      ];

      emacsPackagesOverlay =
        efinal: eprev:
        removeAttrs (import ../pkgs/applications/editors/emacs/elisp-packages/manual-packages final efinal
          eprev
        ) [ "callPackage" ];

      linuxModulesOverlay =
        lfinal: lprev:
        removeAttrs (import ../pkgs/os-specific/linux/modules.nix final lfinal lprev) [ "callPackage" ];

      pythonModulesOverlay =
        pyfinal: pyprev:
        removeAttrs (import ../pkgs/development/python-modules final pyfinal pyprev) [ "callPackage" ];
    in
    nurPkgs
    // {
      emacsPackagesFor = emacs: (prev.emacsPackagesFor emacs).overrideScope emacsPackagesOverlay;

      linuxKernel = prev.linuxKernel // {
        packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend linuxModulesOverlay;
      };

      pythonPackagesExtensions = [ pythonModulesOverlay ];
    };
}
