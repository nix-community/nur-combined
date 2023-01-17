{ pkgs, stdenv, lib, fetchFromGitHub }:
with pkgs.python3Packages;

let
  audible = buildPythonPackage rec {
    pname = "audible";
    version = "0.8.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-57uBhoUzAWZEAQZD0sUV5J4jNKD7OdBqoNguX35Y0Lg=";
    };

    propagatedBuildInputs = [ beautifulsoup4 httpx pbkdf2 pillow pyaes rsa ];

    doCheck = false;
  };
in
  buildPythonApplication rec {
    pname = "audible-cli";
    version = "0.2.4";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-gIG9xxyxHGQawz8nOYqzZpUF0oHHBHxaf6GTfFhubQE=";
    };

    propagatedBuildInputs = [
      aiofiles
      audible
      click
      httpx
      packaging
      pillow
      setuptools
      tabulate
      toml
      tqdm
      questionary
    ];

    doCheck = false;

    meta = with lib; {
      description = "A command line interface for audible package. With the cli you can download your Audible books, cover, chapter files.";
      homepage = "https://github.com/mkb79/audible-cli";
      license = licenses.agpl3;
      maintainers = [ maintainers.jo1gi ];
      platforms = platforms.all;
    };
  }
