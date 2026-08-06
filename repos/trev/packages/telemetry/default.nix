{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

let
  base = beamPackages.buildRebar3 rec {
    name = "telemetry";
    version = "1.4.2";

    src = fetchFromGitHub {
      owner = "beam-telemetry";
      repo = "telemetry";
      rev = "v${version}";
      hash = "sha256-8HMihbkus8rs8iwFRNMuy56UAlu8DZFWI5k2/XZXB48=";
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
