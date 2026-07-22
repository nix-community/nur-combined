{
  lib,
  stdenv,
  fetchurl,
  makeBinaryWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "llmster";
  # upstream versions look like "0.0.15-2" (version-build); use "+" as the
  # separator so that versionCheckHook matches `llmster --version` output
  version = "0.0.20+1";

  # Updated by ./update.sh (called from .github/workflows/update.yml);
  # nix-update cannot detect versions for llmster.lmstudio.ai.
  src = fetchurl {
    url = "https://llmster.lmstudio.ai/download/${
      lib.replaceStrings [ "+" ] [ "-" ] finalAttrs.version
    }-darwin-arm64.full.tar.gz";
    hash = "sha512-T0UbiKecXpTXmSC4g3QTRQqTa/uNdoep4sIB4vMVhmolk6otNP6YBRdLN3y6ABPygDAVEXDpkwUbTX7ewdC7cg==";
  };

  # The tarball extracts llmster, .bundle/, and llmster.zip into the top level
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # Bun-compiled executables embed runtime data after the Mach-O sections and
  # break when stripped
  dontStrip = true;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    mv llmster .bundle $out/libexec/
    makeBinaryWrapper $out/libexec/llmster $out/bin/llmster
    makeBinaryWrapper $out/libexec/.bundle/lms $out/bin/lms

    runHook postInstall
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  # llmster aborts at startup when HOME does not exist
  versionCheckKeepEnvironment = [ "HOME" ];
  doInstallCheck = true;

  meta = {
    description = "LM Studio headless daemon for servers, cloud instances, and CI";
    homepage = "https://lmstudio.ai/llmster";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "llmster";
    # upstream also ships linux-x64 and linux-arm64 tarballs, but those need
    # ELF interpreter patching (see mirkolenz/infra llmster-bin); darwin-x64
    # is not published
    platforms = [ "aarch64-darwin" ];
  };
})
