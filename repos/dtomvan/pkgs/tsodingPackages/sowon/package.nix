{
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  lib,
  SDL2,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "sowon";
  version = "0-unstable-2024-11-08";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "sowon";
    rev = "558f125a78e8ede33e86c4ec584f87892a8ab94a";
    hash = "sha256-QloqwVkjZwsDtxZTaywVgKuKJsyBNpcKPjKHvw9Vql8=";
  };

  installPhase = "make PREFIX=$out install";

  buildInputs = [ SDL2 ];
  nativeBuildInputs = [ pkg-config ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Starting Soon Timer for Tsoding Streams";
    homepage = "https://github.com/tsoding/sowon";
    license = lib.licenses.mit;
    mainProgram = "sowon";
  };
}
