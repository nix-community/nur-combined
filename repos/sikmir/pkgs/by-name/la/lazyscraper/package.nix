{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
  pname = "lazyscraper";
  version = "2020-05-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ivbeg";
    repo = "lazyscraper";
    rev = "2e14bd829311cde19ef32d7f0e11c3c4a3c08e1b";
    hash = "sha256-gnhJB+ZMKQIYZNHMeRrlICgz5UhyHy72Js/I4kbp8Qo=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    lxml
    requests
  ];

  postInstall = "mv $out/bin/lscraper.py $out/bin/lscraper";

  meta = {
    description = "Lazy helper tool to make easier scraping with simple tasks";
    homepage = "https://github.com/ivbeg/lazyscraper";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
