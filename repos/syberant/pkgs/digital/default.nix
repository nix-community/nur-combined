{ lib, stdenv, fetchurl, unzip, makeWrapper, jre, coreutils }:

stdenv.mkDerivation rec {
  pname = "Digital";
  version = "0.29";

  # TODO: perhaps build from source
  src = fetchurl {
    url =
      "github.com/hneemann/Digital/releases/download/v${version}/Digital.zip";
    sha256 = "19zk8wgsv7wvbjxgkypyxrjr3fg36ddnx21qhqzzxp80c5vy4qad";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  unpackPhase = ''
    mkdir -p $out/{share/Digital,bin}
    cd $out/share/Digital
    unzip $src
  '';

  installPhase = ''
    makeWrapper $out/share/Digital/Digital/Digital.sh $out/bin/Digital \
     --set PATH "${lib.makeBinPath [ jre coreutils ]}"
  '';

  # GUI is broken on my XMonad but _JAVA_AWT_WM_NONREPARENTING=1 fixes it for me
  # This seems to be a problem with (my) XMonad so I'm not setting the variable here.

  meta = with lib; {
    description = "A digital logic designer and circuit simulator.";
    homepage = "https://github.com/hneemann/Digital";
    license = licenses.gpl3;
    maintainers = [ maintainers.syberant ];
    platforms = platforms.linux;
  };
}
