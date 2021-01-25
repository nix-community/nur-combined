{ lib
, buildPythonApplication
, fetchFromGitHub
, mypy
, python-jsonrpc-server
}:

buildPythonApplication rec {
  pname = "mypyls";
  version = "2020-08-07";

  src = fetchFromGitHub {
    owner = "matangover";
    repo = "mypyls";
    rev = "628ed24d07a0c41824e7aec5767b185726d34615";
    sha256 = "sha256-2cuCX2pFq9rlBljNO9AEy9H5Js5CqFDDE2AL/W4SJNY=";
  };

  propagatedBuildInputs = [
    mypy
    python-jsonrpc-server
  ];

  postInstall = ''
    ln -s $out/bin/mypyls $out/bin/pyls
  '';

  meta = with lib; {
    description = "mypy based python language server";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
