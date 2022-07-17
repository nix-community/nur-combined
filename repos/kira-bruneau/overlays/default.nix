{
  default = final: prev:
    let
      nurPkgs = removeAttrs (import ../pkgs final prev) [
        "callPackage"
        "python2Packages"
        "python3Packages"
      ];

      pythonOverlay = pyfinal: pyprev:
        removeAttrs (import ../pkgs/development/python-modules final pyfinal pyprev) [ "callPackage" ];
    in
    nurPkgs // {
      pythonInterpreters = builtins.mapAttrs
        (_: interpreter: interpreter.override { packageOverrides = pythonOverlay; })
        prev.pythonInterpreters;
    };
}
