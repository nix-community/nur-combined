{
  fetchFromGitLab,
  flutter335,
  lib,
  writeScript,

  alsa-lib,
  mpv-unwrapped,
  pkg-config,
}:
flutter335.buildFlutterApplication (finalAttrs: {
  pname = "polycule";
  version = "0.3.4-unstable-2025-11-14";
  src = fetchFromGitLab {
    owner = "polycule_client";
    repo = "polycule";
    rev = "4b294296e4d62215f52da8831a3402f51fb1b9a7";
    hash = "sha256-Sx9KN9RwiCwa3vUMjsRfYb/qymABlszwDR9+3Aj34iA=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = {
    matrix = "sha256-w/QB5nYJ9Lh77TcYKEN/DnNQjWfp+9NX0dwQ9GOzWE8=";
    media_kit = "sha256-3VtvM6brOhhx/lgPAzPcxe+I6zB0x7UWIhcEmk9krFc=";
    media_kit_libs_android_video = "sha256-nNKVF0kYOfP7ffqa/WPwATjaleB1QaJcT0aFMO7r+90=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
  ];

  postInstall = ''
    mkdir -p $out/share/{applications,dbus-1/services,metainfo,pixmaps,icons/hicolor/scalable/apps}
    cp linux/*.desktop $out/share/applications
    cp linux/*.service $out/share/dbus-1/services
    cp linux/*.metainfo.xml $out/share/metainfo
    cp assets/logo/logo-circle.svg $out/share/pixmaps/business.braid.polycule.svg
    ln -s $out/share/pixmaps/business.braid.polycule.svg $out/share/icons/hicolor/scalable/apps/business.braid.polycule.svg
  '';

  passthru.updateScript = writeScript "update-polycule" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl nix-update yq

    nix-update --version branch
    curl "https://gitlab.com/polycule_client/polycule/-/raw/main/pubspec.lock" | yq > pkgs/polycule/pubspec.lock.json
  '';

  meta = {
    description = "Geeky and efficient [matrix] client for power users";
    homepage = "https://polycule.im/";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.linux;
    mainProgram = "polycule";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
