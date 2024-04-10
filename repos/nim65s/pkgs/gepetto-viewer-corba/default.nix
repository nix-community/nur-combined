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
  python3Packages,
  qtbase,
  wrapQtAppsHook,
  jrl-cmakemodules,
}:
let
  python = python3Packages.python.withPackages (ps: [
    ps.boost
    omniorbpy
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gepetto-viewer-corba";
  version = "5.8.0";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-/bpAs4ca/+QjWEGuHhuDT8Ts2Ggg+DZWETZfjho6E0w=";
  };

  outputs = [
    "dev"
    "out"
    "doc"
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail "ARGUMENTS $" "ARGUMENTS -p${python}/${python.sitePackages} $" \
      --replace-fail '$'{CMAKE_SOURCE_DIR}/cmake '$'{JRL_CMAKE_MODULES}
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
    jrl-cmakemodules
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
