{
  callPackage,
  fetchurl,
  lib,
  stdenvNoCC,
  _7zz,
}:
let
  version = "2.74.0.623";

  # https://yuanbao.tencent.com/api/info/public/general
  source = {
    url = "https://cdn-hybrid-prod.hunyuan.tencent.com/Desktop/official/f1fbfe63f8864afe036926111699dbfe/yuanbao_2.74.0.623_universal.dmg";
    hash = "sha256-YPtgXrYS+szQWmXv9m/1wViFttDoyuc/ksDb5knZco8=";
  };
  pkgName = "元宝";
in
stdenvNoCC.mkDerivation rec {
  inherit version pkgName;

  executableName = "yuanbao";
  pname = "tencent-yuanbao";

  src = fetchurl source;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [
    _7zz
  ];

  unpackCmd = ''
    7zz x -snld -xr'!*com.apple.provenance'  ${src}
  '';

  sourceRoot = "./${pkgName}";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R ./*.app $out/Applications/

    runHook postInstall
  '';

  passthru = {
    inherit version source;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Tencent Yuanbao";
    homepage = "https://yuanbao.tencent.com/";
    downloadPage = "https://yuanbao.tencent.com/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    # maintainers = with lib.maintainers; [ kagura ];
    # no direct runnable available
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
