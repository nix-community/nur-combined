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
  version = "12.9.8";
  disabled = !isPy38;
  wheelName = "frida-${version}-cp${pythonVersion}-cp${pythonVersion}-linux_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://dl.thalheim.io/CvDYyyDGK1K6CSgRprSDYg/${wheelName}";
    sha256 = "03kzbp7h89m92453wq6walf2mv79fzk6lz7d3blrsxxa94hj5pzi";
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
