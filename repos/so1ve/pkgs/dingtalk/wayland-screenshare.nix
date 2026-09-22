{
  callPackage,
  cmake,
  lib,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXtst,
  libportal,
  libsForQt5,
  ninja,
  opencv,
  pipewire,
  pkg-config,
  source ? callPackage ./screenshare-source.nix { },
  stdenv,
}:

stdenv.mkDerivation {
  pname = "dingtalk-wayland-screenshare";
  version = source.rev;
  inherit (source) src;

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
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXtst
  ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 libdingtalkhook.so "$out/lib/libdingtalkhook.so"

    runHook postInstall
  '';

  meta = {
    description = "DingTalk screen sharing implementation under Wayland";
    homepage = "https://github.com/lzl200110/dingtalk-wayland-screenshare";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
