{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "wik";
  version = "2023-03-12";
  format = "flit";

  src = fetchFromGitHub {
    owner = "yashsinghcodes";
    repo = "wik";
    rev = "7dd7b9ebd4070e4b3a1475948dac67b8288ce17a";
    hash = "sha256-aJnBY33JB4xsH8AIcQGVli8OuIqbTulB26t7uj2GzVk=";
  };

  nativeBuildInputs = with python3Packages; [ flit-core ];

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 requests ];

  meta = with lib; {
    description = "wik is use to get information about anything on the shell using Wikipedia";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
