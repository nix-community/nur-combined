{
  lib,
  stdenv,
  wechat,
  makeWrapper,
  frida-tools,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation {
  pname = "wechat-patched-frida";
  version = wechat.version;

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # We create a wrapper that launches wechat via Frida.
    # Note: This requires ptrace capabilities, which might be blocked 
    # if run inside a strict bubblewrap sandbox.

    install -Dm644 inject.js $out/share/wechat-frida/inject.js

    makeWrapper ${frida-tools}/bin/frida $out/bin/wechat \
      --add-flags "-l $out/share/wechat-frida/inject.js" \
      --add-flags "-f ${lib.getExe wechat}" \
      --add-flags "--no-pause"

    ln -s wechat $out/bin/wechat-patched-frida

    install -Dm644 ${wechat.src}/wechat.png \
      $out/share/icons/hicolor/256x256/apps/wechat-patched-frida.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wechat-patched-frida";
      desktopName = "WeChat (Frida Appearance)";
      genericName = "WeChat";
      exec = "wechat %U";
      icon = "wechat-patched-frida";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      comment = "WeChat with Experimental Frida UI Injection";
    })
  ];

  passthru = {
    inherit (wechat) src fhsenv;
  };

  meta = {
    description = "WeChat with experimental Frida instrumentation for UI patching";
    homepage = "https://linux.weixin.qq.com/";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "wechat";
  };
}
