{ stdenv, lib, fetchFromGitHub, pkgconfig
, openssl, libopus, alsaLib, libpulseaudio
}:

with lib;

stdenv.mkDerivation rec {
  pname = "libtgvoip";
  version = "303dcac-1";

  src = fetchFromGitHub {
    owner = "telegramdesktop";
    repo = "libtgvoip";
    rev = "303dcacc2ad0428fd165c71455056d3f8f884d6f";
    sha256 = "1r25nan5khg0r2a4nimil1ck1ryr9fzd01wr15wy5saiz2nwc84q";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl libopus alsaLib libpulseaudio ];
  enableParallelBuilding = true;

  meta = {
    description = "VoIP library for Telegram clients";
    longDescription = ''
      VoIP library for Telegram clients
    '';
    license = licenses.unlicense;
    platforms = platforms.linux;
    homepage = https://github.com/telegramdesktop/libtgvoip;
  };
}
