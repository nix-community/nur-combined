{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "mitzasql";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "vladbalmos";
    repo = "mitzasql";
    rev = version;
    hash = "sha256-C/KecK8PJDn/MyUxtxFLjVnkra6pW9QoLY34FWkwQ+8=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pygments ==2.7.4" "pygments" \
      --replace "mysql-connector-python ==8.0.22" "mysql-connector-python" \
      --replace "urwid ==2.1.2" "urwid" \
      --replace "appdirs ==1.4.4" "appdirs"
  '';

  propagatedBuildInputs = with python3Packages; [ appdirs pygments mysql-connector urwid ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  doCheck = false; # MySQL server required

  meta = with lib; {
    description = "MySQL command line / text based interface client";
    homepage = "https://vladbalmos.github.io/mitzasql/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
