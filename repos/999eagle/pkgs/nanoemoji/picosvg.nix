{
  python3,
  fetchFromGitHub,
  fetchpatch,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "picosvg";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-J06ijF1c3ZKPqKiQha6yqfj8EjFZoZzA6i6UCCrexi8=";
  };

  patches = [
    # see https://github.com/googlefonts/picosvg/issues/299
    # this patch fixed a failing test case after the update to skia-pathops 0.8
    # as soon as skia-pathops in nixpkgs is updated to 0.8, this patch should be removed
    (fetchpatch {
      url = "https://github.com/googlefonts/picosvg/commit/4e971ed6cd9afb412b2845d29296a0c24f086562.patch";
      hash = "sha256-OZEipNPCSuuqcy4XggBiuGv4HN604dI4N9wlznyAwF0=";
      revert = true;
    })
  ];

  nativeBuildInputs = with python3.pkgs; [
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    absl-py
    lxml
    skia-pathops
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest
  ];

  doCheck = !python3.stdenv.isAarch64;
}
