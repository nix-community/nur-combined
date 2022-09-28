{ stdenv, lib, fetchFromGitHub
, deadbeef, glib, gtk3, sqlite
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "deadbeef-waveform-seekbar-plugin";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "cboxdoerfer";
    repo = "ddb_waveform_seekbar";
    rev = "19f6b1493236ad5f83b6f0e1baa73720aecf326d";
    sha256 = "1yv2c40xn633nx710rxw4yf3fqac4p23j3aw2d7n4f1npw97mq01";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ deadbeef glib gtk3 sqlite ];

  buildFlags = [ "gtk3" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/deadbeef
    cp gtk3/ddb_misc_waveform_GTK3.so $out/lib/deadbeef

    runHook postInstall
  '';

  meta = with lib; {
    description = "Waveform Seekbar plugin for DeaDBeeF audio player";
    homepage = https://github.com/cboxdoerfer/ddb_waveform_seekbar;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.suhr ];
    platforms = platforms.linux;
  };
}
