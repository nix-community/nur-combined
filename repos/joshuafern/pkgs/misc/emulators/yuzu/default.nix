{ stdenv, mkDerivation, fetchFromGitHub
, cmake, pkgconfig, SDL2, qtbase, qtwebengine, python2, alsaLib, libpulseaudio, libjack2, sndio
, boost171, fmt, lz4, zstd, libopus, openssl, libzip, rapidjson
, useVulkan ? true, vulkan-loader, vulkan-headers
}:

mkDerivation rec {
  pname = "yuzu";
  version = "unstable-2020-04-25";

  src = fetchFromGitHub {
    owner = "yuzu-emu";
    repo = "yuzu-mainline"; # They use a separate repo for mainline “branch”
    fetchSubmodules = true;
    rev = "76b65f7f33a60ab7068854328b8411dc5ae538c6";
    sha256 = "1jvqq40c4sdmzzb5ia3nfmhfdk80rpp0hspfrsbx0cwmx9298l2i";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ SDL2 qtbase qtwebengine python2 alsaLib libpulseaudio libjack2 sndio boost171 fmt lz4 zstd libopus openssl libzip rapidjson ]
  ++ stdenv.lib.optionals useVulkan [ vulkan-loader vulkan-headers ];
  cmakeFlags = [ "-DYUZU_USE_QT_WEB_ENGINE=ON" "-DUSE_DISCORD_PRESENCE=ON" ]
  ++ stdenv.lib.optionals (!useVulkan) [ "-DENABLE_VULKAN=No" ];

  # Trick the configure system
  preConfigure = ''
    sed -n 's,^ *path = \(.*\),\1,p' .gitmodules | while read path; do
      mkdir "$path/.git"
    done
  '';

  # Fix vulkan detection
  postFixup = stdenv.lib.optionals useVulkan ''
    wrapProgram $out/bin/yuzu --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    wrapProgram $out/bin/yuzu-cmd --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
  '';

  meta = with stdenv.lib; {
    broken = true;
    homepage = "https://yuzu-emu.org";
    description = "An experimental Nintendo Switch emulator";
    license = with licenses; [ 
      gpl2Plus
      # Icons
      cc-by-nd-30 cc0
    ];
    maintainers = with maintainers; [ ivar joshuafern ];
    platforms = platforms.linux;
  };
}
