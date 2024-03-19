{ stdenv
, gforth
, fetchFromGitea
}:
stdenv.mkDerivation {
  pname = "uc";
  version = "0-unstable-2024-03-17";

  nativeBuildInputs = [ gforth ];

  src = fetchFromGitea {
    domain = "git.envs.net";
    owner = "binarycat";
    repo = "unit.fs";
    rev = "7f998171df3beff2c5609f21c50e27b496bf7b09";
    hash = "sha256-iNajBgHqBACTA+fVYxX6qDNYwLOa33FEgjvA4nrvnlI=";
  };

  buildPhase = ''
    runHook preBuild
    gforthmi --application cmd.fi cmd.fs
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp cmd.fi $out/bin/uc
    runHook postInstall
  '';

  meta = {
    description = "simple unit conversion program";
    broken = true;
  };
}
