{ mkDerivation
, lib
, fetchFromGitHub
, callPackage
, pkg-config
, cmake
, ninja
, python3
, wrapGAppsHook
, wrapQtAppsHook
, extra-cmake-modules
, qtbase
, qtimageformats
, gtk3
, kwayland
, libdbusmenu
, lz4
, xxHash
, ffmpeg
, openalSoft
, minizip
, libopus
, alsa-lib
, libpulseaudio
, range-v3
, tl-expected
, hunspell
, glibmm
, webkitgtk
, jemalloc
, rnnoise
, abseil-cpp
  # Transitive dependencies:
, util-linuxMinimal
, pcre
, libpthreadstubs
, libXdmcp
, libselinux
, libsepol
, libepoxy
, at-spi2-core
, libXtst
, libthai
, libdatrie
, xdg-utils
, libsysprof-capture
, libpsl
, brotli
, microsoft_gsl
, rlottie
}:

let
  tg_owt = callPackage ./tg_owt.nix {
    abseil-cpp = abseil-cpp.override {
      cxxStandard = "17";
    };
  };
  ver = "1.4.5";
in mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "${ver}-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${ver}";
    sha256 = "jcOLqOhIJfPA/0e0ooyeJ9xaNGelTboOgud7Rz0r+7U=";
    fetchSubmodules = true;
  };

  patches = [
    ./0001-Add-an-option-to-hide-messages-from-blocked-users-in.patch
  ];

  postPatch = ''
    substituteInPlace Telegram/CMakeLists.txt \
      --replace '"''${TDESKTOP_LAUNCHER_BASENAME}.appdata.xml"' '"''${TDESKTOP_LAUNCHER_BASENAME}.metainfo.xml"'

    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"'
    substituteInPlace Telegram/lib_webview/webview/platform/linux/webview_linux_webkit_gtk.cpp \
      --replace '"libwebkit2gtk-4.0.so.37"' '"${webkitgtk}/lib/libwebkit2gtk-4.0.so.37"'
  '';

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapGAppsHook
    wrapQtAppsHook
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtimageformats
    gtk3
    kwayland
    libdbusmenu
    lz4
    xxHash
    ffmpeg
    openalSoft
    minizip
    libopus
    alsa-lib
    libpulseaudio
    range-v3
    tl-expected
    hunspell
    glibmm
    webkitgtk
    jemalloc
    rnnoise
    tg_owt
    # Transitive dependencies:
    util-linuxMinimal # Required for libmount thus not nativeBuildInputs.
    pcre
    libpthreadstubs
    libXdmcp
    libselinux
    libsepol
    libepoxy
    at-spi2-core
    libXtst
    libthai
    libdatrie
    libsysprof-capture
    libpsl
    brotli
    microsoft_gsl
    rlottie
  ];

  cmakeFlags = [ "-DTDESKTOP_API_TEST=ON" ];

  postFixup = ''
    # This is necessary to run Kotatogram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/kotatogram-desktop \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils]} \
      --set XDG_RUNTIME_DIR "XDG-RUNTIME-DIR"
    sed -i $out/bin/kotatogram-desktop \
      -e "s,'XDG-RUNTIME-DIR',\"\''${XDG_RUNTIME_DIR:-/run/user/\$(id --user)}\","
  '';

  passthru = {
    inherit tg_owt;
    updateScript = ./update.py;
  };

  meta = with lib; {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.

      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://kotatogram.github.io;
    changelog = "https://github.com/kotatogram/kotatogram-desktop/releases/tag/k{ver}";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
