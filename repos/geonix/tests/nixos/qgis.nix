{ nixpkgs, pkgs, lib, qgisPackage, ... }:
  let
    testScript = pkgs.writeTextFile {
      name = "qgis-test.py";
      text = (builtins.readFile ../../pkgs/qgis/test.py);
    };

    testX11Module = import "${toString nixpkgs}/nixos/tests/common/x11.nix";
  in
  {
    name = "qgis";
    meta = {
      maintainers = with lib; [ teams.geospatial.members ];
    };

    nodes = {
      machine = { pkgs, ... }: {
        virtualisation.diskSize = 2 * 1024;

        imports = [ testX11Module ];
        environment.systemPackages = [ qgisPackage ];

      };
    };

    testScript = ''
      start_all()

      machine.succeed("${qgisPackage}/bin/qgis --version | grep 'QGIS ${qgisPackage.version}'")
      machine.succeed("${qgisPackage}/bin/qgis --code ${testScript}")
    '';
  }
