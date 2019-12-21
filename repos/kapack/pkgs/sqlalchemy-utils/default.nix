{ stdenv, python37Packages, fetchFromGitHub }:

python37Packages.buildPythonPackage rec {
    pname = "sqlalchemy-utils";
    version = "0.33.0";
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "kvesteri";
      repo = "sqlalchemy-utils";
      rev = "3b34e4a8e06d1818ab55c81365c886ac1d473643";
      sha256 = "0wijjv902wcax9799kgkfkiszrmqwr6ykjl0glb70igajdccm7sc";
    };

    buildInputs = with python37Packages; [
    ];

    propagatedBuildInputs = with python37Packages; [
      sqlalchemy
      six
    ];

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = "https://github.com/kvesteri/sqlalchemy-utils";
      description = "Various utility functions and datatypes for SQLAlchemy.";
      # license = licenses.lgpl3;
    };
}
