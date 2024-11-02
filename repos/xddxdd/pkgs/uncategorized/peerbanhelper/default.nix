{
  sources,
  stdenvNoCC,
  lib,
  jre_headless,
  makeWrapper,
  unzip,
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.peerbanhelper) pname version src;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp PeerBanHelper.jar $out/opt/peerbanhelper.jar
    cp -r libraries $out/opt/libraries

    makeWrapper ${jre_headless}/bin/java $out/bin/peerbanhelper \
      --add-flags "-jar" \
      --add-flags "$out/opt/peerbanhelper.jar"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "自动封禁不受欢迎、吸血和异常的 BT 客户端，并支持自定义规则。PeerId黑名单/UserAgent黑名单/IP CIDR/假进度检测/超量下载检测/主动探测 支持 qBittorrent/Transmission";
    homepage = "https://github.com/Ghost-chu/PeerBanHelper";
    license = lib.licenses.gpl3Only;
  };
}
