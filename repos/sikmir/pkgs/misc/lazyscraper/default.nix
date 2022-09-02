{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "lazyscraper";
  version = "2020-05-19";

  src = fetchFromGitHub {
    owner = "ivbeg";
    repo = "lazyscraper";
    rev = "2e14bd829311cde19ef32d7f0e11c3c4a3c08e1b";
    hash = "sha256-gnhJB+ZMKQIYZNHMeRrlICgz5UhyHy72Js/I4kbp8Qo=";
  };

  propagatedBuildInputs = with python3Packages; [ click lxml requests ];

  postInstall = "mv $out/bin/lscraper.py $out/bin/lscraper";

  meta = with lib; {
    description = "Lazy helper tool to make easier scraping with simple tasks";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
