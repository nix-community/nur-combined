{ fetchPypi
, lib
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fediblockhole";
  version = "0.4.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hCsl1dHySB4Nlyx1qaJ+8k8/XXRKufsq4xHVISa8D58=";
  };

  format = "pyproject";

  propagatedBuildInputs = with python3.pkgs; [
    hatchling
    requests
    toml
  ];

  meta = {
    description = "A tool for automatically syncing Mastodon admin domain blocks";
    homepage = "https://github.com/eigenmagic/fediblockhole";
    license = lib.licenses.agpl3Only;
  };
}
