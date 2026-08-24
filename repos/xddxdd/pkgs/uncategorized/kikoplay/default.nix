{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  makeWrapper,
  cmake,
  qt6,
  pkg-config,
  mpv,
  lua5_3_compat,
  onnxruntime,
  ela-widget-tools,
  qtwebapp,
}:
let
  kikoplayScriptSrc = fetchFromGitHub {
    owner = "KikoPlayProject";
    repo = "KikoPlayScript";
    rev = "1a95aad693a50be230c15ebbc6e3aeeb4c4d9fbe";
    hash = "sha256-kHglBw/hN9R90yk2lw0fFykrb3moUxIMLccKbXRbEGQ=";
  };
  kikoplayAppSrc = fetchFromGitHub {
    owner = "KikoPlayProject";
    repo = "KikoPlayApp";
    rev = "62082956bbb0719c4a3a544be6d26e84162370de";
    hash = "sha256-/BuEyOwZvm1LRU0UQ/xqxOqouGB06p72WYFcSSdjqiw=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kikoplay";
  version = "2.1.0";
  src = fetchFromGitHub {
    owner = "KikoPlayProject";
    repo = "KikoPlay";
    tag = "2.1.0";
    hash = "sha256-iNBnH9GLKh3IXdhgnwrinoZqnIQgugtDcTAESldnAug=";
  };
  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    ela-widget-tools
    lua5_3_compat
    mpv
    onnxruntime
    qt6.qmake
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtpositioning
    qt6.qtwayland
    qt6.qtwebengine
    qt6.qtwebsockets
    qtwebapp
  ];

  patches = [
    ./change-install-path.patch
    ./fix-mpv-dup-initialization.patch
  ];

  postPatch = ''
    substituteInPlace KikoPlay.pro \
      --replace-fail "OUTPATH" "$out" \
      --replace-fail "liblua53.a" "liblua.so.5.3" \
      --replace-fail "DEFINES += KSERVICE" ""

    for F in Extension/App/appmanager.cpp Extension/Script/scriptmanager.cpp LANServer/router.cpp Play/Subtitle/subtitlerecognizer.cpp; do
      substituteInPlace "$F" --replace-fail "/usr/share/kikoplay/" "$out/share/kikoplay/"
    done

    rm -rf lib/
  '';

  dontUseCmakeConfigure = true;
  qmakeFlags = [ "KikoPlay.pro" ];
  hardeningDisable = [ "format" ];

  qtWrapperArgs = [
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    "${lua5_3_compat}/lib:/run/opengl-driver/lib"
  ];

  postFixup = ''
    mkdir -p $out/share/kikoplay/extension/script
    cp -r ${kikoplayScriptSrc}/{bgm_calendar,danmu,library,resource} $out/share/kikoplay/extension/script/
    mkdir -p $out/share/kikoplay/extension/app
    cp -r ${kikoplayAppSrc}/app/* $out/share/kikoplay/extension/app/
  '';

  passthru = {
    inherit ela-widget-tools qtwebapp;
  };

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/KikoPlayProject/KikoPlay/releases/tag/${finalAttrs.version}";
    mainProgram = "KikoPlay";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "More than a Full-Featured Danmu Player";
    homepage = "https://kikoplay.fun";
    license = lib.licenses.gpl3Only;
    # See https://github.com/NixOS/nixpkgs/pull/354929
    broken = stdenv.hostPlatform.isDarwin;
  };
})
