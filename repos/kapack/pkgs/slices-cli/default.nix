{ lib, python3Packages, fetchurl ,slices-bi-client, ssh-known-hosts-edit
}:

python3Packages.buildPythonPackage rec {
  pname = "slices-cli";
  version = "0.4.0b9";
  format = "pyproject";

  src = fetchurl {
    url = "https://doc.slices-ri.eu/pypi/packages/slices_cli-${version}.tar.gz";
    hash = "sha256-ReknlF6fplq5KbIEhzS/yOctjuGbwzSqzFMpdmfpi9A=";
  };

  buildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  propagatedBuildInputs = with python3Packages; [
    packaging
    typer
    pyjwt
    tomlkit
    requests-oauthlib
    authlib
    humanize
    pylev
    pyjson5
    pytz
    pyyaml
  ] ++ [ 
    ssh-known-hosts-edit
    slices-bi-client
  ];

  pythonRelaxDeps = [
    "typer"
  ];

}
