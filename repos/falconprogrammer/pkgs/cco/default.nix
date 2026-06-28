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
  docker_29 ? docker,
}:

let
  # The default `docker` is the insecure docker_28 on nixos-25.11; fall back to
  # docker_29 there, but keep tracking the default where it is already current.
  dockerPkg = if lib.versionAtLeast docker.version "29" then docker else docker_29;
in
stdenv.mkDerivation rec {
  pname = "cco";
  version = "0-unstable-2026-06-27";

  src = fetchFromGitHub {
    owner = "nikvdp";
    repo = "cco";
    rev = "8a24b4ff8073e4f8f016d49e6093b85d6eb99a52";
    hash = "sha256-IDiDarzVa6w+SyXz9oBVvJ69QsZ6VQyUOqo+mErya94=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/cco/seccomp

    # Install main cco script
    install -Dm755 cco $out/share/cco/cco
    install -Dm755 sandbox $out/share/cco/sandbox

    # Install runtime library modules (sourced by cco at startup)
    cp -r lib $out/share/cco/

    # Install seccomp BPF filters for Linux sandboxing
    cp seccomp/*.bpf $out/share/cco/seccomp/ 2>/dev/null || true

    # Create wrapper that sets up PATH and CCO_INSTALLATION_DIR
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
        dockerPkg
      ]} \
      --set CCO_INSTALLATION_DIR $out/share/cco

    # Also wrap sandbox script for standalone use
    makeWrapper $out/share/cco/sandbox $out/bin/cco-sandbox \
      --suffix PATH : ${lib.makeBinPath [
        bubblewrap
        coreutils
        findutils
        file
      ]} \
      --set CCO_INSTALLATION_DIR $out/share/cco

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
