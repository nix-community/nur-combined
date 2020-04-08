{ stdenv, fetchFromGitHub, pythonPackages, mopidy }:

pythonPackages.buildPythonApplication rec {
  pname = "mopidy-podcast";
  version = "2.0.3";
  src = fetchFromGitHub {
    owner = "tkem";
    repo = "mopidy-podcast";
    rev = "v${version}";
    sha256 = "1armj541af1fg9gnzyin8i0psmqqzw4cq0531q2bbgzjzsr1i12s";
  };

  propagatedBuildInputs = [
    mopidy
    pythonPackages.pykka
    pythonPackages.cachetools
    pythonPackages.uritools
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/tkem/mopidy-podcast;
    description = "Mopidy-Podcast is a Mopidy extension for browsing and playing podcasts.";
    license = licenses.asl20;
    maintainers = [];
  };
}
