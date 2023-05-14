{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "tilelog";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "tilelog";
    rev = "v${version}";
    hash = "sha256-4B1RkuvLTFmoQtSTLIZZq1ytrmQ37wT0HQarYmIumKg=";
  };

  propagatedBuildInputs = with python3Packages; [ click publicsuffixlist pyathena pyarrow ];

  meta = with lib; {
    description = "Tilelog is used to generate tile logs for the OSMF Standard map layer";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
