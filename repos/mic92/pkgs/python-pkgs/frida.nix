{ stdenv
, buildPythonPackage
, fetchurl
, pip
, isPy38
}:
let
  pythonVersion = "38";
in
buildPythonPackage rec {
  pname = "frida";
  version = "12.10.4";
  disabled = !isPy38;
  wheelName = "frida-${version}-cp${pythonVersion}-cp${pythonVersion}-linux_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://dl.thalheim.io/FTyZDZ4fVNGJzc_kEuiclQ/${wheelName}";
    sha256 = "1gzfkpn1j2gf616q615k3z7n10isnbvc8j3xb9s11ddrspwmxl81";
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
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
  };
}
