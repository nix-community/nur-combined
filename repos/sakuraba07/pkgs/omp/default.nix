{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "18.11.3";

  # Prebuilt, single-file executables published on each GitHub release.
  # Upstream releases almost daily and does not publish source tarballs
  # suitable for a from-scratch Nix build (Bun + Rust N-API + Bazel), so
  # this package tracks the same binaries their own install script fetches.
  sources = {
    x86_64-linux = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      hash = "sha256-Afu18IsM4NcL0LHWZVpszVnO/K4PECPgK7MPmnC8LQo=";
    };
    aarch64-linux = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-arm64";
      hash = "sha256-w5z0qzYzpwA6N8YZdEg4ElqZII02ynSOWcTmKBUXDLo=";
    };
    x86_64-darwin = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-x64";
      hash = "sha256-QvUa+bnQFaTEIig7gDN4/OypprBRaAl5dIWt4pjQezo=";
    };
    aarch64-darwin = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
      hash = "sha256-1RgxDWR9RnosXD8tOONEiadhmW12Y5XAOzfGGiID0Cs=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "omp";
  inherit version;

  src =
    fetchurl
      sources.${stdenvNoCC.hostPlatform.system}
        or (throw "omp: unsupported platform ${stdenvNoCC.hostPlatform.system}");

  dontUnpack = true;
  # This is a Bun `--compile` self-extracting executable: the application
  # bundle is appended after the ELF sections. `strip` treats that trailing
  # data as garbage and discards it, which silently downgrades `omp` to a
  # bare Bun runtime (verified: --version reports Bun's own version instead
  # of omp's after stripping).
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  meta = {
    description = "AI coding agent for the terminal, forked from Pi with hash-anchored edits, LSP, browser control, and subagents";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "omp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [
      {
        name = "sakuraba07";
        github = "sakuraba07";
        githubId = 207140744;
      }
    ];
  };
}
