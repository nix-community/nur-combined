{
  buildPythonPackage,
  fetchPypi,
  scikit-build-core,
  cmake,
  libiberty,
  elfutils,
  libdwarf,
  nanobind,
  typing-extensions,
  ninja,
  psutil,
  requests,
  prompt-toolkit,
}:

buildPythonPackage rec {
  pname = "libdebug";
  version = "0.8.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9InvU/JSIFoAwAkYwKtMVU138Wo7qZmHec7fqCU5LL4=";
  };

  build-system = [
    scikit-build-core
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];
  dontUseCmakeConfigure = true;

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail /usr/include/libiberty ${libiberty.dev}/include/libiberty \
      --replace-fail /usr/include/libdwarf-0 ${libdwarf.dev}/include/libdwarf-0
  '';

  buildInputs = [
    libiberty
    elfutils
    libdwarf
    nanobind
  ];

  dependencies = [
    typing-extensions
    psutil
    requests
    prompt-toolkit
  ];

  nativeCheckInputs = [
  ];
}
