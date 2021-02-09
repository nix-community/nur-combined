{ lib, python3Packages, sources }:

python3Packages.buildPythonApplication {
  pname = "lazyscraper-unstable";
  version = lib.substring 0 10 sources.lazyscraper.date;

  src = sources.lazyscraper;

  propagatedBuildInputs = with python3Packages; [ click lxml requests ];

  postInstall = "mv $out/bin/lscraper.py $out/bin/lscraper";

  meta = with lib; {
    inherit (sources.lazyscraper) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
