{
  lib,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "timewarp";
  version = "0-unstable-2026-03-04";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "renard";
    repo = "timewarp";
    rev = "e769a5c7487f0c2c353f1950b44992bd939e16a1";
    hash = "sha256-OPtA4aIKUVZb1c7VnulLSoDdpfVuBMfeAwD3zk7RNJg=";
  };

  installPhase = ''
    runHook preInstall

    install -d $out/bin
    install -m755 -t $out/bin timewarp timewarp-ctl

    runHook postInstall
  '';

  meta = {
    description = "Run a command with a faked system time without LD_PRELOAD";
    license = lib.licenses.agpl3Plus;
    homepage = "https://github.com/renard/timewarp";
    mainProgram = "timewarp";
    platforms = [ "x86_64-linux" ];
    longDescription = ''
      Run a command with a faked system time -- without `LD_PRELOAD`.

      ## Motivation

      The standard tool for time-faking under Linux is libfaketime. It works by
      preloading a shared library (libfaketime.so) that overrides libc's
      clock_gettime, gettimeofday and time wrappers before the program starts.

      This approach has two fundamental limitations:

      1. It requires a matching ELF interpreter. LD_PRELOAD is processed by the
      dynamic linker (ld-linux.so). When a binary ships with a non-standard
      interpreter path — for example the relocated ld-linux-x86-64.so.2 baked
      in by patchelf in a self-contained tool archive — the system linker is
      never invoked and LD_PRELOAD is silently ignored. This is exactly the
      situation in the bench-tools archive that timewarp was built for.

      2. It does not work with statically linked binaries. A static binary
      carries its own libc; there is no dynamic linker to process LD_PRELOAD,
      so the preloaded library is never loaded.

      timewarp has neither limitation. It works at the syscall level, below the
      C runtime, and requires no cooperation from the target binary's linker
      setup.
    '';
  };
})
