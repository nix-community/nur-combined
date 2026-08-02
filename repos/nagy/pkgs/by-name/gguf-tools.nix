{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "gguf-tools";
  version = "0-unstable-2026-05-16";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "gguf-tools";
    rev = "fdfafbed766db0a1e9019b07994cd88f133d1aab";
    hash = "sha256-nkt/JbpeVb3AxSkDVhiwWfQF+r3orhzauq9T/y038CY=";
  };

  preConfigure = ''
    # Drop -march=native (breaks on non-x86 builds, hurts reproducibility)
    # and debug flags; keep -ffast-math and -O3 from the Makefile.
    substituteInPlace Makefile \
      --replace-fail '-march=native -ffast-math' '-ffast-math' \
      --replace-fail '-g -ggdb -Wall -W -pedantic -O3' '-Wall -W -pedantic -O3'
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gguf-tools $out/bin/gguf-tools
    install -Dm644 -t $out/share/doc/gguf-tools README.md LICENSE
    runHook postInstall
  '';

  meta = {
    description = "Work in progress library and tool to manipulate GGUF files";
    longDescription = ''
      A C library and command-line utility to manipulate GGUF (GPT-Generated
      Unified Format) files. The gguf-tools utility implements subcommands to
      show detailed file info, compare two models tensor-wise, inspect single
      tensors and (experimentally) split Mixtral MoE models.
    '';
    homepage = "https://github.com/antirez/gguf-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "gguf-tools";
  };
}
