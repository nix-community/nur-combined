{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "westra-passes";
  version = "0-unstable-2025-10-09";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "westra_passes_for_nakarte";
    rev = "fd1cadb5a897a8e914aec2d66eb65ffc038a622c";
    hash = "sha256-59bxRZnuaOOOtolvZSTsOftZFw2X1Jk/u85Tq2uZG3M=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    shapely
    numpy
    scipy
    odfpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  postInstall = ''
    mkdir -p $out/share
    cp -r data $out/share/westra-passes
  '';

  meta = {
    description = "Mountain passes for nakarte";
    homepage = "https://github.com/wladich/westra_passes_for_nakarte";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
