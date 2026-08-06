{
  lib,
  stdenv,
  dbus,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "wechat-appearance-plugin";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ dbus ];

  buildPhase = ''
    runHook preBuild
    $CC -shared -fPIC -O2 -Wall -Wextra \
      $(pkg-config --cflags dbus-1) \
      -o libwechat_appearance.so libwechat_appearance.c \
      $(pkg-config --libs dbus-1) -lpthread
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 libwechat_appearance.so $out/lib/libwechat_appearance.so
    runHook postInstall
  '';

  meta = {
    description = "LD_PRELOAD plugin to make WeChat follow system appearance";
    homepage = "https://linux.weixin.qq.com/";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
