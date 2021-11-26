{ lib, python3Packages, fetchFromGitHub, poetry }:

python3Packages.buildPythonApplication rec {
  pname = "pnoise";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "plottertools";
    repo = pname;
    rev = version;
    hash = "sha256-3NoU+7U2Mv+0v7EfEmxoyfdSVSNSH/hM+6nio3rr8tg=";
  };

  postPatch = "sed -i 's/>=.*\"/\"/' setup.py";

  propagatedBuildInputs = with python3Packages; [ numpy ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Vectorized port of Processing noise() function";
    inherit (src.meta) homepage;
    license = licenses.lgpl2Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
