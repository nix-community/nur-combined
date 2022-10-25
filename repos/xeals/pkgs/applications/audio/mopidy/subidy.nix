{ lib
, fetchFromGitHub
, python3Packages

, mopidy
}:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-subidy";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Prior99";
    repo = pname;
    rev = version;
    sha256 = "0c5ghhhrj5v3yp4zmll9ari6r5c6ha8c1izwqshvadn40b02q7xz";
  };

  propagatedBuildInputs = [ mopidy python3Packages.py-sonic ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Prior99/mopidy-subidy";
    description = "Mopidy extension for playing music from Subsonic servers";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
