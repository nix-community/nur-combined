{
  lib,
  stdenv,
  fetchurl,
  squashfsTools,
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

let
  # snap-id 는 패키지 불변값(리비전이 올라도 안 바뀐다). 갱신 대상은 version/revision/hash 셋.
  snapId = "QulQD1qbrCvkV9QD4YLF1ZZczAXSi8Fy";
  revision = "263";
  # snap 의 .desktop 이 Icon 에 박아둔 런타임 경로. 리터럴 `${SNAP}` 을 indented string 안에서 쓰면
  #   이스케이프가 지저분해지므로("'''${" 는 `''` + 보간으로 파싱된다) 여기서 한 번만 만든다.
  snapIconPath = "\${SNAP}/meta/gui/icon.png";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "upnote";
  version = "9.22.2";

  # ⚠️ deb 가 아니라 **snap** 을 쓴다. 이유는 재현성이다.
  #   deb 는 버전 없는 롤링 URL(https://download.getupnote.com/app/upnote_amd64.deb) 하나뿐이라,
  #   업스트림이 파일을 갈아치우는 순간 옛 해시에 묶인 소비자는 **새로 빌드할 방법이 사라진다**
  #   (fixed-output 해시는 그대로인데 그 바이트열이 세상에서 없어진다). 2026-08-31 다운스트림
  #   nix-configurations 의 home-manager switch 가 실제로 이렇게 죽었다.
  #   snap 은 URL 에 리비전이 박히고 과거 리비전이 그대로 남는다(2026-09-01 실측: rev 100/200/250/
  #   262/263 전부 200). 즉 폴링이 늦어도 옛 리비전이 계속 받아진다 — 노출 창이 0 이 된다.
  #
  #   같은 빌드인지는 실물 대조로 확정했다(2026-09-01, deb 9.22.2 vs snap rev 263):
  #     메인 Electron 바이너리 sha256 동일(221,097,208 바이트) · Chrome/150.0.7871.224 Electron/43.4.1 동일
  #     resources.pak / icudtl.dat / libffmpeg.so / v8_context_snapshot.bin / snapshot_blob.bin 동일
  #     app.asar 의 package.json·파일목록(604개) 동일
  #   app.asar 바이트만 다른데, UpNote 가 앱 코드를 난독화(문자열배열 셔플)해 배포하므로 빌드마다
  #   시드가 달라지기 때문이다. 크기 차이 0.05% 수준으로 기능 차가 아니다.
  #
  #   갱신 절차: ./update.sh (snap API 의 stable/amd64 채널을 폴링해 아래 세 값을 교체).
  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/${snapId}_${revision}.snap";
    hash = "sha256-KucmJp3gDmYYkdq4xn8oFyojhjB6V1s99ZY2WSwxKX4=";
  };

  nativeBuildInputs = [
    squashfsTools
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

  # snap 은 squashfs 이미지다. snapd 런타임은 쓰지 않고 앱 트리만 꺼낸다(nixpkgs 의 spotify 와 같은 방식).
  unpackPhase = ''
    runHook preUnpack

    unsquashfs -no-progress -dest squashfs-root "$src"
    cd squashfs-root

    # 리비전과 버전이 어긋나면 여기서 죽인다. snap URL 에는 **리비전만** 있고 버전이 없어서,
    #   update.sh 가 엉뚱한 리비전을 박아도 해시는 그 파일의 것이라 통과해 버린다 — 그걸 막는 관문이다.
    if ! grep -qx "version: ${finalAttrs.version}" meta/snap.yaml; then
      echo "snap 메타의 버전이 파생과 다르다:"
      grep '^version: ' meta/snap.yaml
      echo "파생은 ${finalAttrs.version} 을 기대한다 — revision(${revision})이 잘못됐을 수 있다."
      exit 1
    fi

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # 데스크탑 엔트리·아이콘은 snap 의 meta/gui 에 있다(deb 의 usr/share 대응물).
    #   ⚠️ deb 는 hicolor 8종(16~512)을 주지만 snap 은 512 하나뿐이다. 축소는 DE 가 한다.
    install -Dm644 meta/gui/icon.png $out/share/icons/hicolor/512x512/apps/upnote.png
    install -Dm644 meta/gui/upnote.desktop $out/share/applications/upnote.desktop
    #   Icon 이 snap 런타임 경로(SNAP 변수)를 가리키므로 테마 이름으로 바꾼다.
    #   Exec 은 snap 쪽이 이미 `upnote %U` 라 아래 래퍼 이름과 맞는다(deb 는 /opt/UpNote/upnote 였다).
    substituteInPlace $out/share/applications/upnote.desktop \
      --replace-fail '${snapIconPath}' 'upnote'

    # snap 스캐폴딩은 전부 버린다:
    #   command.sh / desktop-*.sh  = snapd 런처 스크립트(SNAP_* 환경변수 전제)
    #   gnome-platform / data-dir  = content interface 마운트포인트(빈 디렉터리)
    #   meta                       = snap 메타데이터(위에서 필요한 것만 뽑았다)
    #   usr / lib                  = **core20(Ubuntu 20.04) 번들 라이브러리**. 이게 핵심이다 —
    #     nss/nspr/dbus/expat 등을 옛 glibc 로 링크된 채 들고 있어서, 남겨두면 autoPatchelfHook 이
    #     그걸 붙잡는다. deb 에는 애초에 없던 것들이고 없이도 동작했으므로, 버리고 buildInputs 의
    #     nixpkgs 라이브러리로 링크시키는 게 deb 와의 동작 동일성도 지킨다.
    rm -rf command.sh desktop-common.sh desktop-gnome-specific.sh desktop-init.sh \
           gnome-platform data-dir meta usr lib

    mkdir -p $out/share/upnote
    cp -r . $out/share/upnote/

    # deb 빌드에만 있던 파일을 복원한다. electron-updater 는 이 값으로 리눅스 갱신 경로를 고르는데,
    #   snap 빌드는 snapd 가 갱신하는 전제라 이 파일을 안 넣는다. 없는 채로 두면 updater 가 남은
    #   경로(AppImage 자가교체)로 떨어지는데, 그건 이 패키징에서 한 번도 검증된 적이 없다.
    #   어차피 store 는 읽기전용이라 어느 쪽도 성공하지 못하므로, **deb 시절과 같은 실패 모양**을
    #   유지하는 쪽이 안전하다(동작 변화 없음이 이 소스 교체의 목표다).
    echo deb > $out/share/upnote/resources/package-type

    # classic-level 은 glibc/musl 프리빌드를 둘 다 동봉한다. glibc 시스템에선 musl 쪽을 절대 로드하지
    # 않지만, autoPatchelfHook 은 트리를 무차별 순회해 libc.musl-x86_64.so.1 을 못 찾고 빌드를 깬다.
    # --ignore-missing 으로 덮기보다 애초에 안 쓰는 파일을 지우는 편이 낫다(잔재도 안 남음).
    #   ⚠️ deb 는 asar 헤더에 등재만 하고 파일은 누락시켰지만 snap 은 실제로 담고 있다 — 즉 이 줄은
    #     deb 시절보다 지금 더 필요하다.
    rm -f $out/share/upnote/resources/app.asar.unpacked/node_modules/classic-level/prebuilds/*/node.napi.musl.node

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
})
