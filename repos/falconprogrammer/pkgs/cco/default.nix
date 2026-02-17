{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  bubblewrap,
  git,
  coreutils,
  findutils,
  gnused,
  gnugrep,
  gawk,
  file,
  procps,
  docker,
}:

stdenv.mkDerivation rec {
  pname = "cco";
  version = "0-unstable-2026-02-16";

  src = fetchFromGitHub {
    owner = "nikvdp";
    repo = "cco";
    rev = "4245f7621f0c9236e8b1daeae43be6d4f003f948";
    hash = "sha256-ONPvaDeS9sLcWqiSM6VPB6ioZRqxs6iKse+YRq9fN6Q=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/cco/seccomp

    # Install main cco script
    install -Dm755 cco $out/share/cco/cco
    install -Dm755 sandbox $out/share/cco/sandbox

    # Install seccomp BPF filters for Linux sandboxing
    cp seccomp/*.bpf $out/share/cco/seccomp/ 2>/dev/null || true

    # Create wrapper that sets up PATH and CCO_INSTALL_DIR
    # Use --suffix so system bubblewrap (with AppArmor profile) takes precedence
    makeWrapper $out/share/cco/cco $out/bin/cco \
      --suffix PATH : ${lib.makeBinPath [
        bubblewrap
        git
        coreutils
        findutils
        gnused
        gnugrep
        gawk
        file
        procps
        docker
      ]} \
      --set CCO_INSTALL_DIR $out/share/cco

    # Also wrap sandbox script for standalone use
    makeWrapper $out/share/cco/sandbox $out/bin/cco-sandbox \
      --suffix PATH : ${lib.makeBinPath [
        bubblewrap
        coreutils
        findutils
        file
      ]} \
      --set CCO_INSTALL_DIR $out/share/cco

    runHook postInstall
  '';

  meta = {
    description = "A thin protective layer for Claude Code - sandboxing wrapper";
    homepage = "https://github.com/nikvdp/cco";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "cco";
    platforms = lib.platforms.linux;
    longDescription = ''
      cco (Claude Condom) is a security wrapper that sandboxes Claude Code
      execution using bubblewrap.

      Note: The native sandbox requires unprivileged user namespaces to be
      enabled. If you encounter "Permission denied" errors with bwrap, you
      may need to enable this kernel feature.
    '';
  };
}
