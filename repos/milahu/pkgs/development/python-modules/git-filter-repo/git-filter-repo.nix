{ lib
, buildPythonPackage
, fetchPypi
, fetchurl
, pythonOlder
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "git-filter-repo";
  version = "2.38.0";
  format = "setuptools";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/hdT4Y8L1tPJtXhoyAEa59BWpuurcGcGOWoV71MScl4=";
  };

  # TODO build manpage from source with asciidoc
  # https://github.com/newren/git-filter-repo/issues/495
  /*
    a2x \
      -a date=10/10/2022 \
      -a manmanual="Git Manual" \
      -a mansource="Git 2.38.0.dirty" \
      --doctype manpage \
      --format manpage \
      Documentation/git-filter-repo.txt
  */

  # https://github.com/newren/git-filter-repo/blob/docs/man1/git-filter-repo.1
  src-manpage = fetchurl {
    url = "https://github.com/newren/git-filter-repo/raw/01ead411966a83dfcfb35f9d2e8a9f7f215eaa65/man1/git-filter-repo.1";
    sha256 = "sha256-O+Vjul7YtSGF0IXGbANnC5bhWMtvF3hQXyv26Ewx2HU=";
  };

  postInstall = ''
    echo installing manpage
    mkdir -p $out/share/man/man1
    cp ${src-manpage} $out/share/man/man1/git-filter-repo.1
  '';

  nativeBuildInputs = [
    setuptools-scm
  ];

  # Project has no tests
  doCheck = false;

  pythonImportsCheck = [
    "git_filter_repo"
  ];

  meta = with lib; {
    description = "Quickly rewrite git repository history";
    homepage = "https://github.com/newren/git-filter-repo";
    license = with licenses; [ mit /* or */ gpl2Plus ];
    maintainers = with maintainers; [ fab ];
  };
}
