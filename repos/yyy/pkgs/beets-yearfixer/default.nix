{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  inherit (generated) pname version src;

  nativeBuildInputs = [ beets ];

  propagatedBuildInputs = [ requests ];

  # nativeCheckInputs = [ pytestCheckHook ];

  # pythonImportsCheck = [ "beetsplug.yearfixer" ];

  meta = {
    description = "The beets-yearfixer plugin finds the original_year for each of your songs by querying the MusicBrainz database and finding the first release date that is associated with it.";
    homepage = "https://github.com/adamjakab/BeetsPluginYearFixer";
    license = lib.licenses.mit;
  };
}
