{
  fetchurl,
  lib,
  stdenv,
  versionCheckHook,
}:
let
  platform =
    {
      "aarch64-linux" = {
        archive = "arm64";
        hash = "sha256-Uw79JQUv8VM77CfycXM9alcxiWclvKZrPpc8rGe6GNg=";
      };
      "x86_64-linux" = {
        archive = "x86_64";
        hash = "sha256-ZnrzeJHYJRKq7xTtltO7Dz7IhNbbOuHgbfOEEx2sGNs=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "ncmm is not available on ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ncmm";
  version = "1.2.6";
  src = fetchurl {
    url = "https://github.com/3899/ncmm/releases/download/v${finalAttrs.version}/ncmm_Linux_${platform.archive}.tar.gz";
    inherit (platform) hash;
  };
  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = ".";
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  installPhase = ''
    runHook preInstall
    install -Dm755 ncmm $out/bin/ncmm
    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    changelog = "https://github.com/3899/ncmm/releases/tag/v${finalAttrs.version}";
    mainProgram = "ncmm";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Command-line assistant for NetEase Cloud Music musicians";
    homepage = "https://github.com/3899/ncmm";
    license = lib.licenses.mit;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
