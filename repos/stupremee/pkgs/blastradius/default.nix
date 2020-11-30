{ lib, python38, python38Packages, graphviz }:

python38.pkgs.buildPythonPackage rec {
  pname = "BlastRadius";
  version = "0.1.23";

  src = python38.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-cBS/+2/yUrDj2RAxTCQHPlrJeDhcIXpXkHMOx+7+9Aw=";
  };

  propagatedBuildInputs = [ graphviz ]
    ++ (with python38Packages; [ requests beautifulsoup4 jinja2 flask pyhcl ]);

  meta = with lib; {
    homepage = "https://28mm.github.io/blast-radius-docs/";
    description =
      "Blast Radius is a tool for reasoning about Terraform dependency graphs through interactive visualizations.";
    license = licenses.mit;
  };
}
