{ stdenv, buildPythonPackage, fetchurl
, pip, isPy36 }:

buildPythonPackage rec {
  pname = "frida";
  version = "12.1.1";
  disabled = !isPy36;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://dl.thalheim.io/nCVZnxWaZh0VIgEN8O5cdA/frida-${version}-cp36-cp36m-linux_x86_64.whl";
    sha256 = "1d61blq3d10g58l3dhy4b0mr96gp4xswnprjganhqa4nc2g9wqi7";
  };

  nativeBuildInputs = [ pip ];

  unpackPhase = ":";

  format = "other";

  installPhase = ''
      cp $src frida-${version}-cp36-cp36m-linux_x86_64.whl
      pip install --prefix=$out frida-${version}-cp36-cp36m-linux_x86_64.whl
  '';

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = https://www.frida.re/;
    license = licenses.wxWindows;
  };
}
