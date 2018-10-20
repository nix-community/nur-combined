{ stdenv, fetchFromGitHub
, makeWrapper, perl
, dmidecode, file, glxinfo, hddtemp, nettools, iproute, lm_sensors, usbutils, kmod, xlibs
}:

let
  path = [
    dmidecode file glxinfo hddtemp nettools iproute lm_sensors usbutils kmod
    xlibs.xdpyinfo xlibs.xprop xlibs.xrandr
  ];
in stdenv.mkDerivation rec { 
  name = "inxi-${version}";
  version = "3.0.27-1";

  src = fetchFromGitHub {
    owner = "smxi";
    repo = "inxi";
    rev = version;
    sha256 = "015n854p2294kk2payh278hc47zvc8h1bn5w2dgv8m454j581yn4";
  };

  installPhase = ''
    install -D -m755 inxi $out/bin/inxi
    install -D inxi.1 $out/man/man1/inxi.1
    wrapProgram $out/bin/inxi \
      --prefix PATH : ${ stdenv.lib.makeBinPath path }
  '';

  buildInputs = [ perl ];
  nativeBuildInputs = [ makeWrapper ];

  meta = with stdenv.lib; {
    description = "System information tool";
    homepage = https://github.com/smxi/inxi;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
