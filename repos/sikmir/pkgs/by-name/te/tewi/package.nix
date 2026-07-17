{
  lib,
  fetchFromGitHub,
  python3Packages,
  geoip2fast,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tewi";
  version = "2.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anlar";
    repo = "tewi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EpjqUcbxX7bWsCf3kbm421ELmzmfEXbTbKQ63Qrs4Yg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    textual
    transmission-rpc
    geoip2fast
    pyperclip
    qbittorrent-api
  ];

  meta = {
    description = "Text-based interface for the Transmission BitTorrent daemon";
    homepage = "https://github.com/anlar/tewi";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tewi";
  };
})
