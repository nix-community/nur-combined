{
  lib,
  fetchFromGitHub,
  python3Packages,
  geoip2fast,
}:

python3Packages.buildPythonApplication rec {
  pname = "tewi";
  version = "0.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anlar";
    repo = "tewi";
    tag = "v${version}";
    hash = "sha256-64BuxGL/P9iwz0qSYhwzRJ54BYRB0HvqNU0Qb76Idcc=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    textual
    transmission-rpc
    geoip2fast
    pyperclip
  ];

  meta = {
    description = "Text-based interface for the Transmission BitTorrent daemon";
    homepage = "https://github.com/anlar/tewi";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tewi";
    broken = true; # textual is broken
  };
}
