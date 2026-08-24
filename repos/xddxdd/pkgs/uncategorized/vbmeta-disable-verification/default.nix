{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vbmeta-disable-verification";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "libxzr";
    repo = "vbmeta-disable-verification";
    tag = "v1.0";
    hash = "sha256-ml6RZkl2DT08sfJj9L1SGR6zNgRQ15ph0PPIPgxx7+M=";
  };
  buildPhase = ''
    runHook preBuild

    cc -o vbmeta-disable-verification jni/main.c

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp vbmeta-disable-verification $out/bin/vbmeta-disable-verification

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/libxzr/vbmeta-disable-verification/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Patch Android vbmeta image and disable verification flags inside";
    homepage = "https://github.com/libxzr/vbmeta-disable-verification";
    license = lib.licenses.mit;
    mainProgram = "vbmeta-disable-verification";
  };
})
