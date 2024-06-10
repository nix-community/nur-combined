{
  stdenv,
  fetchFromGitHub,
  lib,
  boost,
  cmake,
  doxygen,
  gepetto-viewer-base,
  omniorb,
  omniorbpy,
  pkg-config,
  python3Packages,
  libsForQt5,
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
    repo = "gepetto-viewer-corba";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/bpAs4ca/+QjWEGuHhuDT8Ts2Ggg+DZWETZfjho6E0w=";
  };

  outputs = [
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
    libsForQt5.qtbase
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];

  propagatedBuildInputs = [
    gepetto-viewer-base
    omniorbpy
  ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/gepetto/gepetto-viewer-corba";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
