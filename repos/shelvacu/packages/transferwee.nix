{
  lib,

  python3Packages,
  fetchFromGitHub,
  stdenv,
}:
let
  python = python3Packages.python.withPackages (p: [ p.requests ]);
in
# transferwee has no build system
stdenv.mkDerivation {
  pname = "transferwee";
  version = "0-unstable-2025-01-12";

  buildInputs = [ python ];

  src = fetchFromGitHub {
    owner = "iamleot";
    repo = "transferwee";
    rev = "ef184d0e1285f8d991648fea54cbb1e21cb81f53";
    hash = "sha256-BjWh7eMhFB2GycEqdJN99fuBzL8NWRy0HeMDOgvDa7o=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/bin
    cp transferwee.py "$out"/bin/transferwee
    chmod u+x "$out"/bin/transferwee

    runHook postInstall
  '';

  meta = {
    description = "CLI tool to upload and download files via wetransfer.com";
    homepage = "https://github.com/iamleot/transferwee";
    license = [ lib.licenses.bsd2 ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "transferwee";
    platforms = lib.platforms.all;
  };
}
