{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "flatbencode";
  version = "0.2.1";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/acatton/flatbencode/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-hn2nv1EGkJ3BbMbGtKmaLUKw9XcGAKhBFe0Ev97J5E0=";
  }
  else
  # error
  fetchFromGitHub {
    owner = "acatton";
    repo = "flatbencode";
    rev = "v${version}";
    hash = "sha256-1/4w41E8IKygJTBcQOexiDytV6BvVBwIjajKz2uCfu8=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "flatbencode" ];

  meta = with lib; {
    description = "Fast, safe and non-recursive implementation of Bittorrent bencoding for Python 3";
    homepage = "https://github.com/acatton/flatbencode";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
