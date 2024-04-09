{
  stdenv,
  fetchFromGitHub,
  lib,
  boost,
  cmake,
  doxygen,
  gepetto-viewer,
  omniorb,
  omniorbpy,
  pkg-config,
  python3,
  qtbase,
  wrapQtAppsHook,
}:
let
  python = python3.withPackages (p: [ omniorbpy ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gepetto-viewer-corba";
  version = "5.8.0";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-N05nGHf2dxI3A+tZblnt3j0Bh5CnNMm5pSTD+iC5omg=";
  };

  outputs = [
    "dev"
    "out"
    "doc"
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail "ARGUMENTS $" "ARGUMENTS -p${python}/${python.sitePackages} $"
  '';

  buildInputs = [
    boost
    omniorb
    python
    qtbase
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    wrapQtAppsHook
    pkg-config
  ];

  propagatedBuildInputs = [ gepetto-viewer ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/gepetto/gepetto-viewer-corba";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
