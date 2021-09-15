{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "zdict";
  version = "3.8.2";

  src = fetchFromGitHub {
    owner = "zdict";
    repo = pname;
    rev = version;
    hash = "sha256-H+VcqEtQWLC1qkhvjfMwQTnRZeQdF+buvt9OD6ooCXQ=";
  };

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    peewee
    requests
    setuptools
  ];

  postPatch = "sed -i 's/==.*//' requirements.txt";

  buildPhase = ''
    ${python3Packages.python.interpreter} setup.py build
  '';

  doCheck = false;

  installPhase = ''
    ${python3Packages.python.interpreter} setup.py install --skip-build --prefix=$out
  '';

  meta = with lib; {
    description = "The last online dictionary framework you need";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/issues/137678
  };
}
