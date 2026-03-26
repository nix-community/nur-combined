{
  stdenv,
  lib,
  fetchFromGitHub,

  # Build deps
  cmake,
  doxygen,
  libxslt,
  makeWrapper,
  pkg-config,
  shared-mime-info,

  # Runtime deps
  gmp,
  graphviz,
  libxml2,
  qt6,
  tokyocabinet,
  zlib,

  # Interpreters
  perl,
  python3,

  # Test deps
  hexdump,
  locale,

  # Flags
  withDocs ? withGUI,
  withGUI ? true,
  highDim ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "regina";
  version = "7.4.1";

  outputs = [
    "out"
    "dev"
    "man"
  ];

  src = fetchFromGitHub {
    owner = "regina-normal";
    repo = "regina";
    rev = "regina-${finalAttrs.version}";
    hash = "sha256-E5R9SZsBxatV0fLv8rE9ANC8xZz7NAbect+SwKjo5N8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    python3.pkgs.pythonImportsCheckHook
  ]
  ++ lib.optionals withDocs [
    doxygen
  ]
  ++ lib.optionals withGUI (
    [
      libxslt
      qt6.wrapQtAppsHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      shared-mime-info
    ]
  );

  buildInputs = [
    gmp
    libxml2
    perl
    python3
    tokyocabinet
    zlib
  ]
  ++ lib.optionals withGUI [
    graphviz
    qt6.qtbase
    qt6.qtsvg
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'Python COMPONENTS Interpreter Development' 'Python COMPONENTS Development'

    substituteInPlace python/regina/CMakeLists.txt \
      --replace-fail '$ENV{DESTDIR}''${Python_SITELIB}' '${placeholder "out"}/${python3.sitePackages}'
  '';

  cmakeFlags = [
    "-DREGINA_INSTALL_TYPE=XDG"
    "-DPython_EXECUTABLE=${python3.interpreter}"
  ]
  ++ lib.optionals highDim [
    "-DHIGHDIM=1"
  ]
  ++ lib.optionals (!withGUI) [
    "-DDISABLE_GUI=1"
  ];

  doCheck = true;

  preCheck = ''
    patchShebangs --build \
      ../utils/testsuite/runtest.sh python/{regina-python,testsuite/test*} utils/testsuite/{genout,testall}
  '';

  nativeCheckInputs = [
    perl
    hexdump
  ]
  ++ lib.optionals stdenv.buildPlatform.isDarwin [
    locale
  ];

  postInstall = ''
    moveToOutput "bin/regina-engine-config" "$dev"
    moveToOutput "bin/regina-helper"        "$dev"
  '';

  preFixup = ''
    qtWrapperArgs+=(
      --set-default REGINA_PYLIBDIR "$out/${python3.sitePackages}"
    )
  '';

  postFixup = ''
    substituteInPlace $dev/bin/regina-helper \
      --replace-fail "$out/bin/regina-engine-config" "$dev/bin/regina-engine-config"

    wrapProgram $out/bin/regina-python \
      --set-default REGINA_PYLIBDIR "$out/${python3.sitePackages}"
  '';

  pythonImportsCheck = [
    "regina"
  ];

  meta = {
    description = "Mathematical software for low-dimensional topology";
    license = lib.licenses.gpl2Plus;
    homepage = "https://regina-normal.github.io";
    mainProgram = "regina-gui";
    # https://github.com/regina-normal/regina/blob/regina-7.4.1/engine/data/census/CMakeLists.txt
    broken = !stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  };
})
