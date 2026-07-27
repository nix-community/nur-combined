{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  gtk3,
  libgbm,
  libxkbcommon,
  nspr,
  nss,
  pango,
}:

stdenv.mkDerivation {
  pname = "upnote";
  # 업스트림은 버전 없는 롤링 URL 만 제공한다. 버전/해시의 단일 진실원천은
  #   https://download.getupnote.com/app/latest-linux.yml
  # (electron-builder 메타파일 — version + 각 아티팩트 sha512 를 base64 로 주므로 그대로 SRI 로 쓴다).
  # 갱신 절차: 그 yml 을 읽어 아래 version/hash 두 줄만 교체.
  version = "9.19.8";

  src = fetchurl {
    url = "https://download.getupnote.com/app/upnote_amd64.deb";
    hash = "sha512-tBdZ1orEZuK5Z7BUW33S+tkfHWOQDqO4F5NJkB7cPdUEnx9WkQeoOEUEnp5rO8GFzIMLp3SYf6Yy799TTiUpAA==";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    gtk3
    libgbm
    libxkbcommon
    nspr
    nss
    pango
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share $out/
    mkdir -p $out/share/upnote
    cp -r opt/UpNote/. $out/share/upnote/

    # classic-level 은 glibc/musl 프리빌드를 둘 다 동봉한다. glibc 시스템에선 musl 쪽을 절대 로드하지
    # 않지만, autoPatchelfHook 은 트리를 무차별 순회해 libc.musl-x86_64.so.1 을 못 찾고 빌드를 깬다.
    # --ignore-missing 으로 덮기보다 애초에 안 쓰는 파일을 지우는 편이 낫다(잔재도 안 남음).
    rm -f $out/share/upnote/resources/app.asar.unpacked/node_modules/classic-level/prebuilds/*/node.napi.musl.node

    # 래퍼는 wrapGAppsHook3 이 preFixup 에서 다시 감싼다(GSettings 스키마·XDG_DATA_DIRS 주입).
    #   ⚠ gappsWrapperArgs 를 여기서 직접 쓰면 안 된다 — 그 배열은 preFixup 에서야 채워지므로
    #     installPhase 시점엔 비어 있고, 결과적으로 g_settings_schema_source_lookup 이 NULL 로 죽는다.
    makeWrapper $out/share/upnote/upnote $out/bin/upnote

    substituteInPlace $out/share/applications/upnote.desktop \
      --replace-fail '/opt/UpNote/upnote' 'upnote'

    runHook postInstall
  '';

  meta = {
    description = "Cross-platform note-taking application";
    homepage = "https://getupnote.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "upnote";
  };
}
