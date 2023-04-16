{
  lib,
  python3,
  fetchFromGitHub,
  fetchpatch,
  flac,
  lame,
  mktorrent,
  sox,
  ...
}:
python3.pkgs.buildPythonPackage rec {
  pname = "orpheusbetter-crawler";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "ApexWeed";
    repo = pname;
    rev = "e3e9fea721fa271621e4b3a5cbcf81e5f028f009";
    sha256 = "sha256-sgcBDCpIItU3sIjmehxYS7EgNpcPviOVl12cjKIyrRk=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/ApexWeed/orpheusbetter-crawler/pull/8/commits/fe86ddac5d82ca0665e667066790137a753f485d.patch";
      hash = "sha256-d6R22KYPMN0rUrXotuXUy5Og8JltTd+6DvuLrAoyAeo=";
    })
  ];

  postPatch = ''
    sed -i 's/mechanize==/mechanize>=/' setup.py
  '';

  propagatedBuildInputs = with python3.pkgs; [
    mechanicalsoup
    mechanize
    mutagen
    packaging
    requests
  ];

  postInstall = ''
    wrapProgram $out/bin/orpheusbetter --prefix PATH : ${lib.makeBinPath [flac lame mktorrent sox]}
  '';

  meta = with lib; {
    homepage = "https://github.com/ApexWeed/orpheusbetter-crawler";
    description = "orpheusbetter is a script which automatically transcodes and uploads these files to Orpheus.";
    maintainers = with maintainers; [pborzenkov];
  };
}
