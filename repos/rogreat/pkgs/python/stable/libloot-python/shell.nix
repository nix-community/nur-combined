let
  pkgs = import <nixpkgs> { };

  python = pkgs.python3.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      libloot-python = pyfinal.callPackage ./package.nix { };
    };
  };
in
pkgs.mkShell {
  packages = [
    (python.withPackages (python-pkgs: [ python-pkgs.libloot-python ]))
  ];
}
