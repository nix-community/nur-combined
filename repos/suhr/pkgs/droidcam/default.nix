{ stdenv, fetchFromGitHub
, ffmpeg, libjpeg_turbo, gnome3, alsaLib, speex
, pkgconfig
}:

let
  jpeg = libjpeg_turbo.override { enableStatic = true; };
in
  stdenv.mkDerivation rec {
    pname = "droidcam";
    version = "1.3";

    src = fetchFromGitHub {
      owner = "aramg";
      repo = "droidcam";
      rev = "v${version}";
      sha256 = "06ly609szf87va3pjchwivrnp9g93brgzpwfnb2aa97qllam8lbn";
    };

    buildInputs = [ ffmpeg jpeg gnome3.gtk alsaLib speex ];
    nativeBuildInputs = [ pkgconfig ];

    preBuild = ''
      cd linux
    '';

    makeFlags = [
      "JPEG_INCLUDE=${jpeg.dev}/include"
      "JPEG_LIB=${jpeg.out}/lib"
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp droidcam droidcam-cli $out/bin
    '';

    meta = with stdenv.lib; {
      broken = true;

      description = "Linux client for DroidCam app";
      homepage = "https://github.com/aramg/droidcam";
      license = licenses.gpl2;
      maintainers = [ maintainers.suhr ];
      platforms = platforms.linux;
    };
  }
