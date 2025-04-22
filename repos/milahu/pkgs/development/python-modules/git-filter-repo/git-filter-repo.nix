{ lib
, buildPythonApplication
, fetchFromGitHub
, fetchurl
, pythonOlder
, setuptools
, setuptools-scm
, wheel
}:

buildPythonApplication rec {
  pname = "git-filter-repo";
  version = "2.45.0";
  pyproject = true;

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "newren";
    repo = "git-filter-repo";
    # this version has no manpage
    # so we fetch the manpage separately
    rev = "v${version}";
    hash = "sha256-fbY2S7RPkuv53TIH751os7OczjQR0834bnTeI5nuUg8=";
    # this version has no pyproject.toml
    #rev = "71d71d4be238628bf9cb9b27be79b8bb824ed1a9";
    #hash = "sha256-m9NI7bLR5F+G7f3Dyi4sP6n4qz2i8cdBRuIn0OcpHAw=";
  };

  # TODO build manpage from source with asciidoc
  # this also requires git sources
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
    url = "https://github.com/newren/git-filter-repo/raw/71d71d4be238628bf9cb9b27be79b8bb824ed1a9/man1/git-filter-repo.1";
    sha256 = "sha256-biz3IffXN0ilnFyWKV4JQGMfNwJKYemnSIkmuYinVNM=";
  };

  postInstall = ''
    echo installing manpage
    mkdir -p $out/share/man/man1
    cp ${src-manpage} $out/share/man/man1/git-filter-repo.1
  '';

  # Project has no tests
  # (tests are in the t folder of src)
  doCheck = false;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  pythonImportsCheck = [ "git_filter_repo" ];

  meta = with lib; {
    description = "Quickly rewrite git repository history (filter-branch replacement";
    homepage = "https://github.com/newren/git-filter-repo";
    license = with licenses; [ gpl2Only mit ];
    maintainers = with maintainers; [ fab ];
    mainProgram = "git-filter-repo";
  };
}
