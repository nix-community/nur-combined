{
  sources,
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  libsForQt5,
  libportal,
  pipewire,
  opencv,
  xorg,
}:
# https://github.com/xddxdd/nur-packages/issues/71
stdenv.mkDerivation {
  inherit (sources.dingtalk-wayland-screenshare) pname version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtx11extras
    libportal
    pipewire
    opencv
    # X11 依赖 (Hook 需要操作 X11 窗口)
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
  ];
  # 修复构建错误：这是库文件，不需要 wrap
  dontWrapQtApps = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp libdingtalkhook.so $out/lib/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DingTalk screen sharing implementation under Wayland";
    homepage = "https://github.com/lzl200110/dingtalk-wayland-screenshare";
    license = lib.licenses.mit;
    mainProgram = "dingtalk";
  };
}
