{ lib
, buildPythonApplication
, fetchFromGitHub
, mypy
, python-jsonrpc-server
}:

buildPythonApplication rec {
  pname = "mypyls";
  version = "2020-06-25";

  src = fetchFromGitHub {
    owner = "matangover";
    repo = "mypyls";
    rev = "78df3e7936cb94065c9ca2b2dc1249971ca2ea99";
    sha256 = "QePLdSUv0V6zXEa5UFf5l0mLOrltiu9uWlgN4HSblwU=";
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
