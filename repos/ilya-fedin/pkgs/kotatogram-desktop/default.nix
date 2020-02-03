{ mkDerivation, lib, fetchFromGitHub, pkg-config, python3, cmake, ninja
, qtbase, qtimageformats, enchant, xdg_utils, ffmpeg, openalSoft, lzma
, lz4, xxHash, zlib, minizip, openssl, libtgvoip, range-v3
, integrateWithSystem ? true
}:

with lib;

let
  ver = "1.1.6";
in mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "${ver}-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${ver}";
    sha256 = "166cy8vcw5h6xdfbvw591h8jhr4myf6f8r1cdgl6pdrhlm4wdz1k";
    fetchSubmodules = true;
  };

  patches = optionals integrateWithSystem [
    ./system-tray-icon.patch
  ];

  postPatch = ''
    substituteInPlace Telegram/lib_spellcheck/spellcheck/platform/linux/linux_enchant.cpp \
      --replace '"libenchant-2.so.2"' '"${enchant}/lib/libenchant-2.so.2"'
  '';

  nativeBuildInputs = [ pkg-config python3 cmake ninja ];

  buildInputs = [
    qtbase qtimageformats ffmpeg openalSoft lzma lz4 xxHash
    zlib minizip openssl enchant libtgvoip range-v3
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${xdg_utils}/bin"
  ];

  cmakeFlags = [
    "-DTDESKTOP_API_TEST=ON"
    "-DTDESKTOP_DISABLE_GTK_INTEGRATION=ON"
    "-DDESKTOP_APP_USE_PACKAGED_RLOTTIE=OFF"
  ];

  meta = {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.

      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://kotatogram.github.io;
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
