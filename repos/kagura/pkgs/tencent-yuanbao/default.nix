{
  callPackage,
  fetchurl,
  lib,
  stdenvNoCC,
  _7zz,
}:
let
  version = "2.40.0.623";

  # https://yuanbao.tencent.com/api/info/public/general
  source = {
    url = "https://cdn-hybrid-prod.hunyuan.tencent.com/Desktop/official/5ad2db782e249d32583761d84c409a40/yuanbao_2.40.0.623_universal.dmg";
    hash = "sha256-Jrp1TSTs8OxtLtELdE2ZxCglTeAU4JAhAPWtzgbXpH0=";
  };
  pkgName = "腾讯元宝";
in
stdenvNoCC.mkDerivation rec {
  inherit version pkgName;

  executableName = "yuanbao";
  pname = "tencent-yuanbao";

  src = fetchurl source;

  nativeBuildInputs = [
    _7zz
  ];

  unpackCmd = ''
    7zz x -snld ${src}
  '';

  sourceRoot = "./${pkgName}";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R ./${pkgName}.app $out/Applications

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
