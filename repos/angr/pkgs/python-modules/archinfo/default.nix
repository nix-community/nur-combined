{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, nose
, nose2
, pkgs
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "unstable-2020-09-29";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "0f2a5311b22deb93e944baa31dbb5c1c0b23360f";
    sha256 = "sha256-gxZYtw0mLZohSleTQFZfXRVwY6QKsXLZc7P9RMcz3xo=";
  };

  checkInputs = [ nose nose2 ];
  checkPhase = ''
    nose2 -s tests/
  '';

  meta = with pkgs.lib; {
    description = "A collection of classes that contain architecture-specific information";
    homepage = "https://github.com/angr/archinfo";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
