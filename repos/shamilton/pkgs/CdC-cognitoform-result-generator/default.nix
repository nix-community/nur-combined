{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "CdC-cognitoform-result-generator";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "CdC-cognitoform-result-generator";
    rev = "dd26d5816ab32a76125ac021532eeb5638725e3f";
    sha256 = "0jai9c9vzh45jxa9zia8kxwbbz993d9xjdqd1b9y00s3rm88si8i";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    pandas
    setuptools
  ];

  doCheck = false;

  meta = with lib; {
    description = "Generates a latex formatted output from an xlsx cognitoform excel sheet, made for classes councils preparation.";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
