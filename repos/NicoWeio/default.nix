{ pkgs }: {
  crpropa = pkgs.callPackage ./crpropa {
    python = pkgs.python312;
    numpy = pkgs.python312Packages.numpy;
  };
  radiopropa = pkgs.callPackage ./radiopropa {
    python = pkgs.python312;
    numpy = pkgs.python312Packages.numpy;
  };
  rainlendar2 = pkgs.callPackage ./rainlendar2 { };
  # someOtherTool = pkgs.callPackage ./some-other-tool { };
}
