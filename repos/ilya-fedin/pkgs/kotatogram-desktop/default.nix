{ mkDerivation, lib, fetchFromGitHub, pkgconfig, python3, cmake, ninja
, qtbase, qtimageformats, enchant, xdg_utils, desktop-file-utils, ffmpeg
, openalSoft, lzma, lz4, xxHash, zlib, minizip, openssl, libtgvoip
, rlottie-tdesktop, range-v3
, integrateWithSystem ? true
}:

with lib;

let
  ver = "1.1.3";
in mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "${ver}-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${ver}";
    sha256 = "0xdynzhfbcnp7jwxcxzkvvsxg0r5b8vhx28xi11icjxlrclmpdda";
    fetchSubmodules = true;
  };

  patches = optionals integrateWithSystem [
    ./Use-system-font.patch
    ./system-tray-icon.patch
    ./linux-autostart.patch
    ./Use-system-font-by-default.patch
  ];

  postPatch = ''
    substituteInPlace Telegram/lib_spellcheck/spellcheck/platform/linux/linux_enchant.cpp \
      --replace '"libenchant-2.so.2"' '"${enchant}/lib/libenchant-2.so.2"'
  '';

  nativeBuildInputs = [ pkgconfig python3 cmake ninja ];

  buildInputs = [
    qtbase qtimageformats ffmpeg openalSoft lzma lz4 xxHash
    zlib minizip openssl enchant libtgvoip rlottie-tdesktop range-v3
  ];

  enableParallelBuilding = true;

  qtWrapperArgs = [
    "--prefix PATH : ${xdg_utils}/bin"
    "--prefix PATH : ${desktop-file-utils}/bin"
  ];

  cmakeFlags = [
    "-DTDESKTOP_API_TEST=ON"
    "-DDESKTOP_APP_DISABLE_CRASH_REPORTS=ON"
    "-DTDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME=ON"
    "-DTDESKTOP_DISABLE_DESKTOP_FILE_GENERATION=ON"
    "-DTDESKTOP_DISABLE_GTK_INTEGRATION=ON"
  ];

  installPhase = ''
    install -Dm755 bin/Telegram $out/bin/kotatogram-desktop
    install -Dm644 "$src/lib/xdg/kotatogramdesktop.desktop" "$out/share/applications/kotatogramdesktop.desktop"
    install -Dm644 "$src/lib/xdg/tg.protocol" "$out/share/kservices5/tg.protocol"
    substituteInPlace "$out/share/kservices5/tg.protocol" --replace /usr/bin "$out/bin"
    for icon_size in 16 32 48 64 128 256 512; do
      install -Dm644 "$src/Telegram/Resources/art/icon''${icon_size}.png" "$out/share/icons/hicolor/''${icon_size}x''${icon_size}/apps/kotatogram.png"
    done
  '' + optionalString integrateWithSystem ''
    install -Dm644 "${./autostart.desktop}" "$out/share/KotatogramDesktop/autostart/kotatogramdesktop.desktop"
  '';

  meta = {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.
      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://kotatogram.github.io;
  };
}
