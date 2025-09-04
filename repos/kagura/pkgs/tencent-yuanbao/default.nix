{
  callPackage,
  fetchurl,
  lib,
  stdenvNoCC,
  _7zz,
}:
let
  version = "2.36.0.6214";

  # https://yuanbao.tencent.com/api/info/public/general
  source = {
    url = "https://cdn-1-prod.hunyuan.tencent.com/Desktop/official/90a3aed2a9526055a607eaddf1e59a7a/yuanbao_2.36.0.624_universal.dmg";
    hash = "sha256-1+90YSLAjUoDM0R4o6uqEvrInnIEG8aXkjVk=";
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
