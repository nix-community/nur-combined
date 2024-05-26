{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tracks_storage_server";
  version = "2024-04-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "tracks_storage_server";
    rev = "080526665a38c44e8c08e70d4ddcdda1c1911fc8";
    hash = "sha256-fN7OG52t2pHxFlCxhnMkVMpctsuwBQyuXMO9CD9eWLg=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (
        p: with p; [
          msgpack
          protobuf
          psycopg2
        ]
      );
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py *.sql $site_packages

      substitute config.py.example $site_packages/config.py \
        --replace-fail "'password" "#'password"

      makeWrapper ${pythonEnv.interpreter} $out/bin/tracks_storage_server \
        --add-flags "$site_packages/server.py"
      makeWrapper ${pythonEnv.interpreter} $out/bin/init_db \
        --add-flags "$site_packages/init_db.py"
    '';

  meta = {
    description = "Tracks storage server";
    inherit (src.meta) homepage;
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
