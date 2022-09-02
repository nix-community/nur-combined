{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "zdict";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "zdict";
    repo = "zdict";
    rev = version;
    hash = "sha256-uiCD2ZuVP1Pu7r/uOEctjMhsupxm++i0kiHxU9DNp9M=";
  };

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    peewee
    requests
  ];

  postPatch = "sed -i 's/==.*//' requirements.txt";

  doCheck = false;

  meta = with lib; {
    description = "The last online dictionary framework you need";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
