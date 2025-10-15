{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.vlmcsd) pname version src;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/vlmcs $out/bin/vlmcs
    install -Dm755 bin/vlmcsd $out/bin/vlmcsd

    runHook postInstall
  '';

  meta = {
    mainProgram = "vlmcsd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = lib.licenses.mit;
  };
})
