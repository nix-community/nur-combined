{ lib
, stdenv
, fetchFromGitHub
, python2Packages
, postgresql
, openssl
}:
let
  psycopg2 = python2Packages.buildPythonPackage rec {
    pname = "psycopg2";
    version = "2.8.6";

    src = python2Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-+yP2xxEHw3/WZ8tOo2Pd65NrNIu9ZEknjrksGJaZ9UM=";
    };

    buildInputs = lib.optional stdenv.isDarwin openssl;
    nativeBuildInputs = [ postgresql ];

    doCheck = false;

    meta = with lib; {
      description = "PostgreSQL database adapter for the Python programming language";
      license = with licenses; [ gpl2 zpl20 ];
    };
  };
in
python2Packages.buildPythonApplication rec {
  pname = "tracks_storage_server";
  version = "2018-03-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "tracks_storage_server";
    rev = "58ecde50bdc41e8b71590f62b7019d641e69da88";
    hash = "sha256-rHh3iuhQhhVzGAfyNXfhBB41PzQF7rSmOMtYM10bFkU=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python2Packages.python.withPackages (p: with p; [
        msgpack
        (protobuf.overrideAttrs (old: {
          dontUsePythonImportsCheck = true;
        }))
        psycopg2
      ]);
    in
    ''
      site_packages=$out/lib/${python2Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py *.sql $site_packages

      substitute config.py.example $site_packages/config.py \
        --replace "'password" "#'password"

      makeWrapper ${pythonEnv.interpreter} $out/bin/tracks_storage_server \
        --add-flags "$site_packages/server.py"
      makeWrapper ${pythonEnv.interpreter} $out/bin/init_db \
        --add-flags "$site_packages/init_db.py"
    '';

  passthru.psycopg2 = psycopg2;

  meta = with lib; {
    description = "Tracks storage server";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    broken = true; # python2Packages.protobuf (error: mox-0.7.8 not supported for interpreter python2.7)
  };
}
