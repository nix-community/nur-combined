{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, pythonOlder
}:

buildPythonPackage rec {
  pname = "git-filter-repo";
  version = "2.38.0";
  format = "setuptools";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "newren";
    repo = "git-filter-repo";
    rev = "v${version}";
    hash = "sha256-keRDaMg0BbrqxlSUOS2X1y+FTuCd8AJi8q7VwO8fhKo=";
  };

  postPatch = ''
    # build in /release/
    cd release

    # fix: ERROR: Could not find a version that satisfies the requirement setuptools_scm
    substituteInPlace setup.py \
      --replace \
        'use_scm_version=dict(root="..", relative_to=__file__),' \
        'version="${version}",'
    substituteInPlace setup.cfg \
      --replace 'setup_requires = setuptools_scm' ""

    # fix: FileExistsError: File already exists: /bin/git-filter-repo
    substituteInPlace setup.cfg \
      --replace "scripts = git-filter-repo" ""
  '';

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

  # Project has no tests
  # (tests are in the t folder of src)
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
