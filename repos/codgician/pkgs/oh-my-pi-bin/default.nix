{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  git,
  gh,
  xdg-utils,
}:

let
  version = "16.3.15";

  baseUrl = "https://github.com/can1357/oh-my-pi/releases/download/v${version}";

  sources = {
    x86_64-linux = {
      url = "${baseUrl}/omp-linux-x64";
      hash = "sha256-iWdOqufYi050IdCIntxOXyY2slkaFAXXGK7ZqLlrXUU=";
    };
    aarch64-linux = {
      url = "${baseUrl}/omp-linux-arm64";
      hash = "sha256-zjGKOrYo27oudVP01bv7ZRlnpFuGEq3MO21QgTDX69A=";
    };
    x86_64-darwin = {
      url = "${baseUrl}/omp-darwin-x64";
      hash = "sha256-vptJYUQOLHPvZDH1zuYClB6aByvJjSNQe7NBglOU28Y=";
    };
    aarch64-darwin = {
      url = "${baseUrl}/omp-darwin-arm64";
      hash = "sha256-23JFq8Ta6DlgXB2KiSq70V4bQiq6i0i1NUvSCcSbHJ4=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi-bin";
  inherit version;

  src = fetchurl (
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "oh-my-pi-bin: unsupported system ${stdenvNoCC.hostPlatform.system}")
  );

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/omp

    # omp compiles ripgrep, glob, find and bash in-process, so unlike other
    # agent CLIs it needs no external search/shell tools. Provide `git` and
    # `gh` for the git/GitHub-backed tools and, on Linux, `xdg-utils` for the
    # browser/OAuth `xdg-open` handoff. `--suffix` keeps a user's own tools and
    # desktop URL handler ahead of these fallbacks so their config still wins.
    makeWrapper $out/libexec/omp $out/bin/omp \
      --suffix PATH : ${
        lib.makeBinPath ([ git gh ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ xdg-utils ])
      }

    runHook postInstall
  '';

  # omp is a Bun single-file executable: the JavaScript/runtime payload is
  # appended after the ELF image and located relative to the end of the file.
  # autoPatchelfHook or `patchelf --set-rpath` rewrite section data and corrupt
  # that trailer; only `--set-interpreter` is safe (it edits PT_INTERP in place).
  # The binary links solely against glibc, so fixing the interpreter is enough.
  postFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/libexec/omp
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "AI coding agent for the terminal with hash-anchored edits, LSP, DAP, Python, browser, and subagents";
    homepage = "https://github.com/can1357/oh-my-pi";
    changelog = "https://github.com/can1357/oh-my-pi/blob/v${version}/packages/coding-agent/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "omp";
  };
}
