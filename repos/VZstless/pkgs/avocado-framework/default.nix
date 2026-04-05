{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "avocado-framework";
  version = "113.0";
  format = "setuptools";
  
  src = fetchFromGitHub {
    owner = "avocado-framework";
    repo = "avocado";
    tag = finalAttrs.version;
    hash = "sha256-vfo2PIci2DPlCLEd/F3Joa5TCo85W7OMhgq6iOJ5o2w=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    distutils
  ];

  propagatedBuildInputs = [
    python3Packages.setuptools
  ];

  dontUseMakeBuild = true;
  dontUseMakeInstall = true;

  installPhase = ''
    runHook preInstall
    python setup.py install \
      --prefix=$out \
      --single-version-externally-managed \
      --root=/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Set of tools and libraries to help with automated testing";
    homepage = "https://avocado-framework.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ VZstless ];
    mainProgram = "avocado";
  };
})
