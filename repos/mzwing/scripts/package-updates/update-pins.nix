{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-pins";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
    ];
    runtimeEnv.SYSTEM = pkgs.stdenv.hostPlatform.system;
    text = builtins.readFile ./update-pins.sh;
  };
in {
  update-pins = {
    type = "app";
    program = "${script}/bin/update-pins";
    meta.description = "Refresh package pins (coupled URL+hash data) declared as passthru.pins";
  };
}
