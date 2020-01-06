{ stdenv, lib, fetchFromGitHub, pkgconfig, autoreconfHook
, openssl, libopus, alsaLib, libpulseaudio
}:

with lib;

stdenv.mkDerivation rec {
  pname = "libtgvoip";
  version = "88b47b6-1";

  src = fetchFromGitHub {
    owner = "telegramdesktop";
    repo = "libtgvoip";
    rev = "88b47b6f808f2573d4eaf37e1463ecd59c43deda";
    sha256 = "0ck3y1lwi9blp09gqvakc71iiqfcy1ibg8r6zpdbafq37mkqwrxp";
  };

  patches = [ ./libtgvoip-use-pkgconfig.patch ];
  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
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
