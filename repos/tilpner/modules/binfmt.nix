{ config, lib, pkgs, ... }:

# what could go wrong?
let
  inherit (pkgs) writeScript;
  cfg = config.binfmt;
in with lib; {
  options.binfmt = {
    java = mkEnableOption "java binfmt";
    wine = mkEnableOption "wine";
    racket = mkEnableOption "racket";
    golang = mkEnableOption "golang";
    tcc = mkEnableOption "tcc";
  };

  config = mkMerge [
    (mkIf cfg.java {
      boot.binfmtMiscRegistrations.jar = {
        recognitionType = "extension";
        magicOrExtension = "jar";

        interpreter = writeScript "binfmt-jar" ''
          #!/bin/sh
          exec ${pkgs.openjdk}/bin/java -jar "$@"
        '';
      };
    })

    (mkIf cfg.wine {
      boot.binfmtMiscRegistrations.exe = {
        magicOrExtension = "MZ";

        interpreter = writeScript "binfmt-exe" ''
          #!/bin/sh
          exec ${pkgs.wine}/bin/wine "$@"
        '';
      };
    })

    (mkIf cfg.racket {
      boot.binfmtMiscRegistrations.racket = {
        recognitionType = "extension";
        magicOrExtension = "rkt";

        interpreter = writeScript "binfmt-racket" ''
          #!/bin/sh
          exec ${pkgs.racket}/bin/racket "$@"
        '';
      };
    })

    (mkIf cfg.golang {
      boot.binfmtMiscRegistrations.golang = {
        recognitionType = "extension";
        magicOrExtension = "go";

        interpreter = writeScript "binfmt-go" ''
          #!/bin/sh
          exec ${pkgs.go}/bin/go run "$@"
        '';
      };
    })

    (mkIf cfg.tcc {
      boot.binfmtMiscRegistrations.c = {
        recognitionType = "extension";
        magicOrExtension = "c";

        interpreter = writeScript "binfmt-c" ''
          #!/bin/sh
          exec ${pkgs.tinycc}/bin/tcc -run "$@"
        '';
      };
    })
  ];
}
