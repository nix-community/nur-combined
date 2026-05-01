{
  sources,
  version,
  lib,
  stdenv,
  cmake,
  ninja,
}:
stdenv.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  strictDeps = true;
  __structuredAttrs = true;

  cmakeFlags = [ (lib.strings.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];

  installPhase = ''
    runHook preInstall

    install -D DanmakuFactory $out/bin/DanmakuFactory

    runHook postInstall
  '';

  meta = {
    description = "支持特殊弹幕的xml转ass格式转换工具";
    homepage = "https://github.com/hihkm/DanmakuFactory";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "DanmakuFactory";
  };
}
