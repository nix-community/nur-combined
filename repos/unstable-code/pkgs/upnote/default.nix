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
  libglvnd,
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
  version = "9.20.0";

  src = fetchurl {
    url = "https://download.getupnote.com/app/upnote_amd64.deb";
    hash = "sha512-EOggAsO+aaQjYV7T116KxU+gtC9/bpy5g3ZtOUk+PYtKG9tXZz6q4hRQexT1PCINeKArybMyLzCvnd3XBzbTLg==";
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

    substituteInPlace $out/share/applications/upnote.desktop \
      --replace-fail '/opt/UpNote/upnote' 'upnote'

    runHook postInstall
  '';

  # 래퍼를 preFixup 에서 만든다.
  #   ⚠ gappsWrapperArgs 는 installPhase 시점엔 비어 있다 — wrapGAppsHook3 이 preFixup 에서야 채운다.
  #     거기서 쓰면 GSettings 스키마 경로가 안 박혀 g_settings_schema_source_lookup 이 NULL 로 죽는다.
  #     그래서 dontWrapGApps 로 자동 래핑을 끄고, 채워진 뒤인 여기서 직접 조립한다.
  #
  #   LD_LIBRARY_PATH 에 libglvnd 를 넣는 이유: Chromium/ANGLE 은 네이티브 EGL 을 **dlopen** 하므로
  #     autoPatchelfHook(NEEDED 만 검사)이 못 잡는다. 없으면 기동 시 전부 실패하고 GPU 프로세스가 죽는다:
  #       Could not dlopen native EGL: libEGL.so.1 → Exiting GPU process due to errors during initialization
  #     → 소프트웨어 렌더링으로 떨어짐. NixOS 의 /run/opengl-driver/lib 에는 벤더 구현
  #     (libEGL_nvidia.so.0 / libEGL_mesa.so.0)만 있고 glvnd 디스패치인 libEGL.so.1 은 libglvnd 에 있다.
  #     벤더 선택은 자동이다 — NixOS libglvnd 는 /run/opengl-driver/share/glvnd/egl_vendor.d 를 기본으로
  #     본다(패치됨). nixpkgs 의 google-chrome 도 같은 방식으로 libglvnd 를 LD_LIBRARY_PATH 에 넣는다.
  dontWrapGApps = true;
  preFixup = ''
    makeWrapper $out/share/upnote/upnote $out/bin/upnote \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libglvnd ]}
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
