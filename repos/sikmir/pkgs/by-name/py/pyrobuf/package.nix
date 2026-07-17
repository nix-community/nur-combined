{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchpatch,
}:

python3Packages.buildPythonPackage {
  pname = "pyrobuf";
  version = "0.9.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "appnexus";
    repo = "pyrobuf";
    rev = "811a9325eed1c0070ceb424020fe81eeef317e0c";
    hash = "sha256-7NEzRM9B/9f5ODNzDKws7t/9gqbJK7T9AuET+pT26P0=";
  };

  # https://github.com/appnexus/pyrobuf/pull/165
  patches = [
    (fetchpatch {
      url = "https://github.com/appnexus/pyrobuf/commit/af98f882e00c4bfa621f2e70f4ca7a4f30c6c306.patch";
      hash = "sha256-+EVjmQs45j9siGcw0T++Kt7CGaAW6Z79xj3PDXPFj5E=";
    })
    (fetchpatch {
      url = "https://github.com/appnexus/pyrobuf/commit/c3d1972111e74dbe89b2feda375d2a50e9668df8.patch";
      hash = "sha256-igp021IXYoMZprrroILtqqHkMGAiypbR9I3zq21B8BU=";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail ", 'pytest-runner'" ""
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = with python3Packages; [
    cython
  ];

  dependencies = with python3Packages; [ jinja2 ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = {
    description = "A Cython based protobuf compiler";
    homepage = "https://github.com/appnexus/pyrobuf";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
