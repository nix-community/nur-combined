{
  lib,
  bash,
  ieda-unstable,
  fetchFromGitHub,
  fetchpatch,
  yosys,
  klayout,
  buildPythonPackage,
  python,
  setuptools,
  pyyaml,
  orjson,
  hatchling,
  requests,
  wheel,
}:
buildPythonPackage {
  pname = "rtl2gds";
  version = "0-unstable-2025-03-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "0xharry";
    repo = "RTL2GDS";
    rev = "771ae6822c21ca368f5d8299a6abf900d8de16c2";
    sha256 = "sha256-BpxIirim5SOTKsqRAJHt7W+YZsm5s4smQ9YIYngW20s=";
  };

  patches = [
    # This patch is needed to fix the issue with the pyproject.toml file
    # that is not specifying the entry points and package directories.
    # We should remove this patch once the upstream project fixes the issue.
    (fetchpatch {
      url = "https://github.com/Emin017/RTL2GDS/commit/dd62444742e3334011f58cd97c22a75453cd497f.patch";
      hash = "sha256-PtllEJINeZWhSoKR7CXiMJn2dmkvaGwN+CyIxbD4o7Y=";
    })
  ];

  propagatedBuildInputs = [
    python
    setuptools

    pyyaml
    orjson
    klayout
    hatchling
    requests
  ];

  nativeBuildInputs = [
    setuptools
    wheel
    ieda-unstable
    yosys
  ];

  makeWrapperArgs = [
    "--set PATH ${
      lib.makeBinPath [
        bash
        yosys
        ieda-unstable
      ]
    }"
    "--set LD_LIBRARY_PATH ${
      lib.makeLibraryPath [
        pyyaml
        orjson
        klayout
      ]
    }"
  ];

  postInstall = ''
    mkdir -p $out/lib/${python.libPrefix}/tools/
    mkdir -p $out/lib/${python.libPrefix}/foundry/

    cp -r $src/tools/* $out/lib/${python.libPrefix}/tools/
    cp -r $src/foundry/* $out/lib/${python.libPrefix}/foundry/
  '';

  doCheck = true;

  # checkPhase = ''
  #   # Run the tests
  #   cd design_zoo/gcd
  #   python -m rtl2gds -c gcd.yaml
  # '';

  meta = {
    description = "A tool to compile your RTL files into GDSII layouts.";
    homepage = "https://github.com/0xharry/RTL2GDS";
    platforms = lib.platforms.linux;
  };
}
