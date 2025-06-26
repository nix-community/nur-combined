{
  sources,
  version,
  lib,
  stdenv,
  ...
}:
stdenv.mkDerivation (_final: {
  inherit (sources) pname src;
  inherit version;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 DanmakuFactory $out/bin/DanmakuFactory

    runHook postInstall
  '';

  meta = {
    description = "支持特殊弹幕的xml转ass格式转换工具";
    homepage = "https://github.com/hihkm/DanmakuFactory";
    license = lib.licenses.mit;
    mainProgram = "DanmakuFactory";
  };
})
