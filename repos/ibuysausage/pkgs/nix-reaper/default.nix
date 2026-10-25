{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "nix-reaper";
  version = "441bea3";

  src = fetchFromGitHub {
    owner = "ibuysausage";
    repo = "nix-reaper";
    rev = version;
    sha256 = "sha256-CNfFJGSOuWZSvA8GrxLMtPkzxRHY0MQCQN96S0xlTAI=";
  };

  buildPhase = ''
    runHook preBuild
    $CC -O2 -Wall -o nix-reaper nix-reaper.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 nix-reaper $out/bin/nix-reaper
    runHook postInstall
  '';

  meta = with lib; {
    description = "Clean old Nix generations, garbage, caches and more";
    homepage = "https://github.com/ibuysausage/nix-reaper";
    license = licenses.mit; # set to whatever the repo uses
    platforms = platforms.linux;
    mainProgram = "nix-reaper";
  };
}
