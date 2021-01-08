{ stdenv, python3Packages, fetchFromGitHub }:

with python3Packages;

buildPythonApplication rec {
  pname = "bonfire";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "blue-yonder";
    repo = pname;
    rev = "v${version}";
    sha256 = "1y2r537ibghhmk6jngw0zwvh1vn2bihqcvji50ffh1j0qc6q3x6x";
  };

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "arrow>=0.13.0,<0.16" "arrow>=0.13.0" \
      --replace "keyring>=9,<21" "keyring>=9" \
      --replace "click>=3.3,<7" "click>=3.3"
  '';

  buildInputs = [ httpretty pytest pytestcov ];

  propagatedBuildInputs = [ arrow click keyring parsedatetime requests six termcolor ];

  meta = with stdenv.lib; {
    homepage = "https://pypi.python.org/pypi/bonfire";
    description = "CLI Graylog Client with Follow Mode";
    license = licenses.bsd3;
    maintainers = [ maintainers.womfoo ];
    platforms = platforms.linux;
  };
}
