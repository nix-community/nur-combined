{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

let
  base = beamPackages.buildRebar3 rec {
    name = "telemetry";
    version = "1.4.3";

    src = fetchFromGitHub {
      owner = "beam-telemetry";
      repo = "telemetry";
      rev = "v${version}";
      hash = "sha256-7fZkLgGnpVMXNuZRGhaRy1UsNGUAR4Jqj5XJZEYVToY=";
    };

    beamDeps = [ ];

    meta = {
      description = "Dynamic dispatching library for metrics and instrumentations";
      homepage = "https://github.com/beam-telemetry/telemetry";
      license = lib.licenses.asl20;
      platforms = lib.platforms.all;
    };
  };
in
base.overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        base.pname
      ];
    };
  };
})
