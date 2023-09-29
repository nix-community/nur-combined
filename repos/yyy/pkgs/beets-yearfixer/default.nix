{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pname = "beets-yearfixer";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "adamjakab";
    repo = "BeetsPluginYearFixer";
    rev = "v${version}";
    hash = "sha256-KpYazPkj1beAPppcgO3NhN08RF97NL1WwZu523x1qo8=";
  };

  nativeBuildInputs = [ beets ];

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "beetsplug.yearfixer" ];

  meta = {
    description = "The beets-yearfixer plugin finds the original_year for each of your songs by querying the MusicBrainz database and finding the first release date that is associated with it.";
    homepage = "https://github.com/adamjakab/BeetsPluginYearFixer";
    license = lib.licenses.mit;
  };
}
