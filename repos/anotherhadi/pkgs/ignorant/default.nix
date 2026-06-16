{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  termcolor,
  beautifulsoup4,
  httpx,
  trio,
  tqdm,
}:
buildPythonApplication rec {
  pname = "ignorant";
  version = "unstable-2026-03-15";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "megadose";
    repo = "ignorant";
    rev = "40b3eb734ef3d55e6d16eb314e49dbf520fa1f64";
    hash = "sha256-t/xFRII7XKeK7sIG87UbVGiKIdJ9ag7VHFHfNg8BbUs=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"argparse",' "" \
      --replace-fail '"bs4",' '"beautifulsoup4",'
  '';

  build-system = [setuptools];

  dependencies = [
    termcolor
    beautifulsoup4
    httpx
    trio
    tqdm
  ];

  doCheck = false;

  meta = with lib; {
    description = "ignorant allows you to check if a phone number is used on different sites like snapchat, instagram.";
    homepage = "https://github.com/megadose/ignorant";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = [];
    mainProgram = "ignorant";
  };
}
