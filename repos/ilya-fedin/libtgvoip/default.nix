{ stdenv, lib, fetchFromGitHub, pkgconfig
, openssl, libopus, alsaLib, libpulseaudio
}:

with lib;

stdenv.mkDerivation rec {
  pname = "libtgvoip";
  version = "4dabb67-1";

  src = fetchFromGitHub {
    owner = "telegramdesktop";
    repo = "libtgvoip";
    rev = "4dabb67eff8756e1ee0ad6e27a0a0478ea65b6d4";
    sha256 = "0agdfjnlg04qmvcd7n03rs1vpsi9kfxl3zpcns1z6a45v8xdqy4i";
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
