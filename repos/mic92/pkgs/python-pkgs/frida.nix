{ stdenv
, buildPythonPackage
, fetchurl
, pip
, isPy37
}:
let
  pythonVersion = "37";
in
buildPythonPackage rec {
  pname = "frida";
  version = "12.8.20";
  disabled = !isPy37;
  wheelName = "frida-${version}-cp${pythonVersion}-cp${pythonVersion}m-linux_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://dl.thalheim.io/kVPuNTRXw8nLfHVJBokbGg/${wheelName}";
    sha256 = "1nksqf25x7s86i69vlpfhd0f4ag4ghdy3v8p6hv4xljxic4ab6fl";
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
