{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  pcre2,
  cctools,
  git,
  gh,
  xdg-utils,
}:

let
  version = "16.4.6";

  # Upstream's darwin release CI builds `pi_natives.<platform>.node` on a
  # Homebrew host, so the embedded addon hardcodes an absolute Homebrew install
  # name for pcre2 (`/opt/homebrew/opt/pcre2/lib/libpcre2-8.0.dylib` on arm64,
  # `/usr/local/opt/...` on x64). Without that Homebrew formula the addon fails
  # to `dlopen`, and because the omp binary is signed with the hardened runtime
  # macOS strips `DYLD_*`, so a wrapper env var cannot rescue it. Instead we
  # extract the addon at build time (see postFixup), repoint its pcre2 install
  # name to the Nix store copy, and drop it in `$out/libexec` — one of the
  # locations omp searches before the broken `~/.omp` extraction.
  darwinAddon = {
    aarch64-darwin = {
      name = "pi_natives.darwin-arm64.node";
      homebrewPcre2 = "/opt/homebrew/opt/pcre2/lib/libpcre2-8.0.dylib";
    };
    x86_64-darwin = {
      name = "pi_natives.darwin-x64.node";
      homebrewPcre2 = "/usr/local/opt/pcre2/lib/libpcre2-8.0.dylib";
    };
  };

  baseUrl = "https://github.com/can1357/oh-my-pi/releases/download/v${version}";

  sources = {
    x86_64-linux = {
      url = "${baseUrl}/omp-linux-x64";
      hash = "sha256-lDfPU9nZWRhs93KVwmUGyxAcaDW1BuKAT5UfQcZ0SmE=";
    };
    aarch64-linux = {
      url = "${baseUrl}/omp-linux-arm64";
      hash = "sha256-rrlR+GCQT9fTw3Rpi4c8JzN5Y1lor/MtCw4AYBqikBw=";
    };
    x86_64-darwin = {
      url = "${baseUrl}/omp-darwin-x64";
      hash = "sha256-JHWt50flnOHVkSX7u6fE2+b4F/1tniozqgqbVrgQ3vQ=";
    };
    aarch64-darwin = {
      url = "${baseUrl}/omp-darwin-arm64";
      hash = "sha256-g+rEFTyLwOkwV4s5R9aG6ulA9bx4Ta5KUTlSiqPPTpI=";
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

  # On darwin we must run omp at build time to make it extract its embedded
  # native addon (see postFixup). The Bun binary is signed with the hardened
  # runtime and traps (`Trace/BPT trap: 5`) under the macOS build sandbox, so
  # the extraction step only works with the chroot disabled. The flake already
  # opts into `sandbox = "relaxed"` on aarch64-darwin for cases like this.
  __noChroot = stdenvNoCC.hostPlatform.isDarwin;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [ cctools ];

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
        lib.makeBinPath (
          [
            git
            gh
          ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ xdg-utils ]
        )
      }

    runHook postInstall
  '';

  # omp is a Bun single-file executable: the JavaScript/runtime payload is
  # appended after the ELF image and located relative to the end of the file.
  # autoPatchelfHook or `patchelf --set-rpath` rewrite section data and corrupt
  # that trailer; only `--set-interpreter` is safe (it edits PT_INTERP in place).
  # The binary links solely against glibc, so fixing the interpreter is enough.
  postFixup =
    lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/libexec/omp
    ''
    + lib.optionalString stdenvNoCC.hostPlatform.isDarwin (
      let
        addon =
          darwinAddon.${stdenvNoCC.hostPlatform.system}
            or (throw "oh-my-pi-bin: unsupported darwin system ${stdenvNoCC.hostPlatform.system}");
      in
      ''
        # Force omp to extract its embedded native addon (`--help` triggers it,
        # `--version` does not). It then traps trying to dlopen the Homebrew-linked
        # addon, so ignore the exit status and assert on the extracted file.
        export HOME="$TMPDIR/omp-home"
        mkdir -p "$HOME"
        $out/libexec/omp --help > /dev/null 2>&1 || true

        extracted="$HOME/.omp/natives/${version}/${addon.name}"
        [ -f "$extracted" ] || { echo "oh-my-pi-bin: addon not extracted at $extracted" >&2; exit 1; }

        # Repoint pcre2 to the Nix store copy. The extracted addon is already
        # code-signed and install_name_tool preserves a valid signature across an
        # in-place edit, so (unlike an unsigned binary) no codesign step is needed.
        install -Dm755 "$extracted" "$out/libexec/${addon.name}"
        install_name_tool -change \
          ${addon.homebrewPcre2} ${pcre2.out}/lib/libpcre2-8.0.dylib \
          "$out/libexec/${addon.name}"
      ''
    );

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
