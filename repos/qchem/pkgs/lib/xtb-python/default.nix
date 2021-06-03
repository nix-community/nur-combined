{ buildPythonPackage, lib, fetchFromGitHub, cffi, numpy, ase, qcelemental, meson, ninja, pkg-config,
  xtb, pytest
}:

buildPythonPackage rec {
  pname = "xtb-python";
  version = "20.2";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = pname;
    rev = "v${version}";
    sha256  = "0ra4d4hi34clckxy9nv0k3ignjcfa7vv1w33y854zqk9qr45z4bg";
  };

  postPatch = ''
    cp -r ${xtb.src} subprojects/.
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [
    cffi
    numpy
    ase
    qcelemental
    xtb
  ];

  # Build a C module to interface XTB.
  preBuild = ''
    meson setup build --prefix=$PWD --default-library=shared
    ninja -C build install
  '';

  checkInputs = [ pytest ];
  checkPhase = "pytest";
  doCheck = false;

  meta = with lib; {
    description = "Python wrapper for the semiempirical XTB package";
    homepage = "https://github.com/grimme-lab/xtb-python";
    license = licenses.lgpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
