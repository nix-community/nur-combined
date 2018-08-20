{ stdenv, fetchFromGitHub
, makeWrapper, perl
, dmidecode, file, hddtemp, nettools, iproute, lm_sensors, usbutils, kmod, xlibs
}:

let
  path = [
    dmidecode file hddtemp nettools iproute lm_sensors usbutils kmod
    xlibs.xdpyinfo xlibs.xprop xlibs.xrandr
  ];
in stdenv.mkDerivation rec { 
  name = "inxi-${version}";
  version = "3.0.21-1";

  src = fetchFromGitHub {
    owner = "smxi";
    repo = "inxi";
    rev = version;
    sha256 = "0vpnkw5f8i1cakxxsqbb88bvnpncs87lx110s0ry0mnz4ajq2wi7";
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
