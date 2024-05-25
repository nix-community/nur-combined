{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "wik";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yashsinghcodes";
    repo = "wik";
    rev = "37207e7cf2955c494a55701cb81d388cc349b6ea";
    hash = "sha256-oSHL3jYFuvJY1W7N9/CvFClFakz9f35RHg77AbMRfsI=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    requests
  ];

  meta = {
    description = "wik is use to get information about anything on the shell using Wikipedia";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
