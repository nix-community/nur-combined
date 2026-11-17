{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  patchelf,
  python3,
  bash,
  gitMinimal,
  openssl,
  sqlite,
  cacert,
}:

let
  source = import ./sources/x86_64-linux.nix;
  runtimeLibraries = [
    stdenv.cc.libc
    openssl
    sqlite
  ];
in
stdenv.mkDerivation {
  pname = "nodecode-bin";
  inherit (source) version;

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
    python3
  ];
  dontBuild = true;
  # SBCL appends its Lisp core after the ELF image. Generic fixups corrupt it.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec/nodecode"
    install -m755 nodecode "$out/libexec/nodecode/nodecode"
    cp -r src "$out/libexec/nodecode/"
    python3 ${./patch-runtime.py} "$out/libexec/nodecode/nodecode" \
      ${stdenv.cc.bintools.dynamicLinker} \
      ${lib.escapeShellArg (lib.makeLibraryPath runtimeLibraries)}

    # Keep the real executable named nodecode, with src/ beside it: SBCL uses
    # /proc/self/exe to find its source and to spawn trial and gateway processes.
    makeWrapper "$out/libexec/nodecode/nodecode" "$out/bin/nodecode" \
      --suffix PATH : ${
        lib.makeBinPath [
          bash
          gitMinimal
        ]
      } \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt

    runHook postInstall
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/nodecode-home"
    export NODECODE_HOME="$HOME/.nodecode"
    export XDG_CACHE_HOME="$HOME/.cache"
    mkdir -p "$HOME"
    "$out/bin/nodecode" --version | grep -F 'nodecode ${source.version}+'
    "$out/bin/nodecode" --help | grep -F 'usage: nodecode'
    "$out/bin/nodecode" trial <<'EOF' | grep -Fx 'nodecode-trial-score 1'
    (let ((db (sqlite:connect ":memory:")))
      (unwind-protect
           (if (and (= 42 (sqlite:execute-single db "select 19 + 23"))
                    (string= (nlk:sha256-text "abc")
                             "sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"))
               1 0)
        (sqlite:disconnect db)))
    EOF
    runHook postInstallCheck
  '';

  meta = {
    description = "Self-evolving coding agent running in Common Lisp";
    homepage = "https://github.com/nodecode-ai/nodecode";
    changelog = "https://github.com/nodecode-ai/nodecode/releases/tag/v${source.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "nodecode";
    platforms = [ "x86_64-linux" ];
  };
}
