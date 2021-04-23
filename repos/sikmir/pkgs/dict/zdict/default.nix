{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "zdict";
  version = "3.8.2";

  src = fetchFromGitHub {
    owner = "zdict";
    repo = "zdict";
    rev = version;
    sha256 = "0x0952m0yknzpvpfc5qxwijx2fa163rqsvs8masv0n2h9fl5rr8z";
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
  };
}
