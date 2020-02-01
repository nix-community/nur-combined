{ stdenv
, fetchgit
, python3
, python3Packages
}:

python3.pkgs.buildPythonPackage rec {
  pname = "ttystatus";
  version = "0.36";


  src = fetchgit {
    url = "git://git.liw.fi/ttystatus/";
    rev = "refs/tags/${pname}-${version}";
    sha256 = "1vwr086yi5wky1zc7jqq49fl8yvzqnp9a7rrg67arc55j4awsn5l";
  };

  buildInputs = with python3Packages; [ sphinx ];

  # error: invalid command 'test'
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = http://liw.fi/ttystatus/;
    description = "Progress and status updates on terminals for Python";
    license = licenses.gpl3;
    maintainers = [];
  };

}
