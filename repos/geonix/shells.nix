{ self, system, pkgs }:

rec {

  # CLI shell
  cli =
    let
      py = pkgs.python3;
      pythonPackage = py.withPackages (p: with self.packages.${system}; [
        python3-fiona
      ]);

    in
    pkgs.mkShell {
      nativeBuildInputs = [ pkgs.bashInteractive ];
      buildInputs = with self.packages.${system}; [
        gdal
        pythonPackage
      ];
    };

  default = cli;
}
