{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  requests,
  phonenumbers,
  pycountry,
}:
buildPythonApplication rec {
  pname = "toutatis";
  version = "unstable-2026-03-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "megadose";
    repo = "toutatis";
    rev = "d99967155e59966a560877148273ca0ff9f28508";
    hash = "sha256-VY3g3LNfeQtCuQfM4Ky1akJ7YgLrNM9RnuC1M8eOw4c=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"argparse",' ""
  '';

  build-system = [setuptools];

  dependencies = [
    requests
    phonenumbers
    pycountry
  ];

  doCheck = false;

  meta = with lib; {
    description = "Toutatis is a tool that allows you to extract information from instagrams accounts such as e-mails, phone numbers and more";
    homepage = "https://github.com/megadose/toutatis";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = [];
    mainProgram = "toutatis";
  };
}
