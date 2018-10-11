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
  version = "3.0.26-1";

  src = fetchFromGitHub {
    owner = "smxi";
    repo = "inxi";
    rev = version;
    sha256 = "1bpq6icj970n39xm7z14wg6xvyd0sb90qb6y5pf7cm70yj6y4xvk";
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
