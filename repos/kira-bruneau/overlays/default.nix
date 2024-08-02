{
  default =
    final: prev:
    let
      lib = prev.lib;

      nurPkgs = removeAttrs (import ../pkgs { inherit lib; } final prev) [
        "callPackage"
        "emacsPackages"
        "linuxPackages"
        "python3Packages"
      ];

      emacsPackagesOverlay =
        efinal: eprev:
        removeAttrs (import ../pkgs/applications/editors/emacs/elisp-packages/manual-packages {
          inherit lib;
          pkgs = final;
        } efinal eprev) [ "callPackage" ];

      linuxModulesOverlay =
        lfinal: lprev:
        removeAttrs (import ../pkgs/os-specific/linux/modules.nix {
          inherit lib;
          pkgs = final;
        } lfinal lprev) [ "callPackage" ];

      pythonModulesOverlay =
        pyfinal: pyprev:
        removeAttrs (import ../pkgs/development/python-modules {
          inherit lib;
          pkgs = final;
        } pyfinal pyprev) [ "callPackage" ];
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
