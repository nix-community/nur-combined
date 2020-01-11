{ stdenv
, buildPythonPackage
, fetchurl
, pip
, isPy37
}:
let
  pythonVersion = "37";
in buildPythonPackage rec {
  pname = "frida";
  version = "12.8.6";
  disabled = !isPy37;
  wheelName = "frida-${version}-cp${pythonVersion}-cp${pythonVersion}m-linux_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://dl.thalheim.io/nCVZnxWaZh0VIgEN8O5cdA/${wheelName}";
    sha256 = "15v6hp4d8m1c9sxjwb3k8z9cq2y1clyzz5ixd189gmv90cgfifps";
  };

  nativeBuildInputs = [ pip ];

  unpackPhase = ":";

  format = "other";

  installPhase = ''
    cp $src ${wheelName}
    pip install --prefix=$out ${wheelName}
  '';

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = https://www.frida.re/;
    license = licenses.wxWindows;
  };
}
