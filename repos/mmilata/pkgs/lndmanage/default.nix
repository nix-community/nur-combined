{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "lndmanage";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "bitromortac";
    repo = pname;
    rev = "v${version}";
    sha256 = "1hy2l0g2mqjl1gwbhzddkbi15d5zw4apramsbpmr0gzp5xgilgn7";
  };

  patches = [ ./lndmanage-nodes.patch ];

  propagatedBuildInputs = with python3Packages; [
    cycler
    decorator
    googleapis_common_protos
    grpcio
    grpcio-tools
    kiwisolver
    networkx
    numpy
    protobuf
    pyparsing
    python-dateutil
    six
    pygments
  ];

  preBuild = ''
    substituteInPlace setup.py --replace '==' '>='
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = with lib; {
    description = "Channel management tool for lightning network daemon (LND) operators";
    homepage = src.meta.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mmilata ];
    platforms = platforms.all;
  };
}
