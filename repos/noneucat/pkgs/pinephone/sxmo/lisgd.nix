{ stdenv, fetchgit, libX11, libinput
, patches ? [] }:
let 
  patches' = patches;
in stdenv.mkDerivation rec {
  pname = "lisgd";
  version = "0.2.0";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/lisgd";
    rev = "${version}";
    sha256 = "1z1bvbd2b7rrqqxqn9lqc6n4av0vy7l7ii2j0lgjwhnvnvgchmi0";
  };

  patches = patches' ++ [
    ./0001-Default-to-PinePhone-touchscreen-evdev-device.patch  
  ];

  buildInputs = [
    libinput
    libX11
  ];

  preConfigure = ''
    sed -i "s@PREFIX = /usr@PREFIX = $out@g" Makefile 
    sed -i "s@chmod@#chmod@g" Makefile 
  '';

  meta = {
    homepage = "https://git.sr.ht/~mil/lisgd";
    description = "Libinput synthetic gesture daemon";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = stdenv.lib.platforms.linux; 
  };
}
