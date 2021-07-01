{
  default = final: prev:
    let
      nurPkgs = removeAttrs (import ../pkgs final prev) [ "callPackage" ];

      pythonOverrides = pyfinal: pyprev:
        removeAttrs (import ../pkgs/development/python-modules final pyfinal pyprev) [ "callPackage" ];
    in
    nurPkgs // {
      python = prev.python.override { packageOverrides = pythonOverrides; };
      python2 = prev.python2.override { packageOverrides = pythonOverrides; };
      python3 = prev.python3.override { packageOverrides = pythonOverrides; };
      python27 = prev.python27.override { packageOverrides = pythonOverrides; };
      python36 = prev.python36.override { packageOverrides = pythonOverrides; };
      python37 = prev.python37.override { packageOverrides = pythonOverrides; };
      python38 = prev.python38.override { packageOverrides = pythonOverrides; };
      python39 = prev.python39.override { packageOverrides = pythonOverrides; };
      python310 = prev.python310.override { packageOverrides = pythonOverrides; };
      pythonPackages = final.python.pkgs;
      python2Packages = final.python2.pkgs;
      python3Packages = final.python3.pkgs;
      python27Packages = final.python27.pkgs;
      python36Packages = final.python36.pkgs;
      python37Packages = final.python37.pkgs;
      python38Packages = final.python38.pkgs;
      python39Packages = final.python39.pkgs;
      python310Packages = final.python310.pkgs;
    };
}
