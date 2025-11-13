{
  sources,
  version,
  lib,
  stdenv,
  xmake,
  writeShellScriptBin,
  pkg-config,
  pcre2,
}:
stdenv.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [
    xmake
    (writeShellScriptBin "git" "exit 0")
    pkg-config
  ];

  buildInputs = [ pcre2.dev ];

  env.NIX_LDFLAGS = "-lpcre2-8";

  configurePhase = ''
    runHook preConfigure
    export HOME=$(mktemp -d)
    xmake global --network=private
    xmake config -m release --yes -vD --ccache=n \
      --cflags="-Wno-implicit-function-declaration -Wno-int-conversion"
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    xmake build --yes -j $NIX_BUILD_CORES -vD
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    xmake install --yes -o $out
    mv $out/bin/source $out/bin/DanmakuFactory
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
