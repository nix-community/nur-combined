{
  buildPythonPackage,
  fetchFromGitHub,
  httplib2,
  simplejson,
  six,
  pytz,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./instagram.json);
in
  buildPythonPackage {
    name = "instagram";
    version = source.date;
    src = fetchFromGitHub {
      owner = "foozmeat";
      repo = "python-instagram";
      inherit (source) rev sha256;
    };
    propagatedBuildInputs = [
      httplib2
      simplejson
      six
      pytz
    ];
    meta = {
      description = "Python Client for Instagram API";
      license = lib.licenses.bsd3;
    };
    passthru.updateScript = [
      ../scripts/update-git.sh
      "https://github.com/foozmeat/python-instagram"
      "python/instagram.json"
    ];
  }
