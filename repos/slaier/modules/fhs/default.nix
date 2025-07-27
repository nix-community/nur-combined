{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.buildFHSEnv {
      name = "fhs-run";

      targetPkgs = pkgs: with pkgs; [
        coreutils
        glibc
        gnugrep
        gnumake
        (python3.withPackages (python-pkgs: with python-pkgs; [
          pyyaml
        ]))
      ];
    })
  ];
}
